% Finds all atom in sight of POV.
% Uses a cache to re-use results and save runtime.
%
% [indLOS,indNLOS] = u.FindLOS(POV)
% u is an handle to a Universe class (this class)
% POV:      [x,y,z] Coordinate sof point-of-view [m]
% indLOS:   Indece of all atoms in line-of-sight vs POV
% indNLOS:  Indece of all atoms in NOT line-of-sight vs POV
%
%
% -------------------------------------------------------------------------
%     This is a part of the Qamcom Channel Model (QCM)
%     Copyright (C) 2017  Björn Sihlbom, QAMCOM Research & Technology AB
%     mailto:bjorn.sihlbom@qamcom.se, http://www.qamcom.se, https://github.com/qamcom/QCM 
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% -------------------------------------------------------------------------

function [indLOS,indNLOS] = FindLOS(u,POV)

POV=round(POV/sys.largeScaleResolution)*sys.largeScaleResolution;

ind = [];
if ~isempty(u.los) && u.los.N>0
    ind = FindPt(u.los.pov,POV);
else
    u.los.N = 0;
end


if isempty(ind)
    
    % All atoms
    a = u.GetAtoms;
    
    % Atoms and Surfaces vs LOS point (Put POV in origo)
    losS=[a.surface(:,1)-POV(1),a.surface(:,2)-POV(2),a.surface(:,3)-POV(3)];
    
    % Max range
    indRange = find(vnorm(losS,2)<sys.maxRadius);
    
    if ~isempty(indRange)
        
        % Atoms in range
        a = u.GetAtoms(indRange);
        
        % Atoms and Surfaces vs LOS point (Put POV in origo)
        losS=[a.surface(:,1)-POV(1),a.surface(:,2)-POV(2),a.surface(:,3)-POV(3)];
        
        
        indAtom = find(~a.corner(:,1)&[a.material.shading]'==1); % Corners & Flat ground cast no shade...
        
        
        N = size(a.surface,1);
        
        
        losC = losS-a.normal;
        rtpC = Polar3D(losC);
        rtpS = Polar3D(losS);
        
        % Sort shading atoms, so closest comes first
        % Tese are most likely to cast shade onmany others
        % Quickly reducing remaining atoms to trace during first iteratiosn
        [~,sortC] = sort(rtpC(indAtom,1));
        sortC=indAtom(sortC(:))';
        
        % Tuning
        CC = 2;
        CR = 10;
        
        % Pruning atoms with surface points in shade
        ptmask = ones(N,1);
        for ii=sortC,
            if (ptmask(ii) || ~sys.quickTrace)
                
                
                
                if sys.bubbleTrace
                    
                    % Shading atom center
                    phiC0    = rtpC(ii,3);
                    thetaC0  = rtpC(ii,2);
                    radiusC0 = rtpC(ii,1);
                    size0    = a.res(ii);
                    
                    % Shaded atoms
                    critAoA = find(abs(rtpS(:,3)-phiC0).*sin(rtpS(:,2))*radiusC0 <= size0/CC);
                    critEoA = (abs(rtpS(critAoA,2)-thetaC0)*radiusC0 <= size0/CC);
                    critR   = (rtpS(critAoA,1)>=radiusC0+size0/CR);
                    ptmask(critAoA(critEoA&critR)) = 0;
                                        
                else
                    
                    % POV is in origo.
                    % Shading atom surface losS(ii,:) with normal losN(ii,:)
                    
                    % Rays will intersect plane defined by shading atom.
                    % dd is the relative distance. <1 means atom is closer than plane.
                    % rr is the distance btw pt of intersect, and atom surface center
                    [dd,rr] = LinePlaneIntersect([0 0 0],losS,losS(ii,:),a.normal(ii,:));
                    size0 = a.res(ii);
                    ptmask(dd<1&rr<size0/2) = 0;
                    
                    
                end
                
                
                
            end
        end
        indLOS = indRange(ptmask==1)';
        indLOS = indLOS(:);
    else
        indLOS = [];
    end
    % Store in cache
    ind = u.los.N+1;
    u.los.ind{ind}=indLOS(:);
    u.los.pov(ind,1:3)=round(POV);
    u.los.N=ind;
    
else
    
    % Load from cache
    indLOS = u.los.ind{ind};
    
end

indNLOS = setdiff(1:u.nrofAtoms,indLOS);

