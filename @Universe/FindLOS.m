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

function [indLOS,indNLOS] = FindLOS(u,POV,range)


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
    s = u.GetStructures;
    
    if isempty(a.res)
        indLOS = [];
    else
        % Atoms vs LOS point (Put POV in origo)
        losS = VectorAdd(a.surface,-POV);
        
        % Max range
        indRange = find(vnorm(losS,2)<range);
        
        if ~isempty(indRange)
            
            % Atoms in range
            a = u.GetAtoms(indRange);
            ptmask = FindCore(a,s,POV,range);
            indLOS = indRange(ptmask==1);
            indLOS = indLOS(:);
            
        else
            indLOS = [];
        end
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


end

function ptmask = FindCore(a,s,POV,range)


% Atoms vs LOS point (Put POV in origo)
losS = VectorAdd(a.surface,-POV);

N = size(a.surface,1);

% Pruning atoms with surface points in shade
ptmask = ones(N,1)==1;


% Sort shading structures, so closest comes first
% Tese are most likely to cast shade onm any others
% Quickly reducing remaining atoms to trace during first iterations
p0   = VectorAdd(reshape([s.p0],3,[])',-POV);
r0 = vnorm(p0,2);
[~,sortS] = sort(r0);


for ii = sortS(r0<range)'
    points   = s(ii).points;
    surfaces = s(ii).surfaces;
    for ss = 1:length(surfaces)
        surface = surfaces{ss};
        p = VectorAdd(points(surface.pi,:),-POV);
        behind = BehindPolygon(p,losS(ptmask,:));
        ptmask(ptmask)=~behind;
    end
end


end