% Check if LOS btw POV pairs. Returns a soft value if partly shaded
%
% LOS = CheckLOS(u,POV0s,POV1s)
% u is an handle to a Universe class (this class)
% POV0s, POV1s: [x,y,z] Coordinates of point-of-view [m]
% inds: Atom indece to exclude from search
% LOS:      Matrix with scalar amplitude values (1=no shading, 0=no LOS at all)
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

function LOS = CheckLOS(u,POV0s,POV1s,inds0,inds1)


N0  = size(POV0s,1);
N1  = size(POV1s,1);



% All atoms
LOS = ones(N0,N1);
a=u.GetAtoms;

if ~isempty(a.normal)
    
    % Keep atoms casting shade only
    ind = find([a.material.shading]' & ~a.corner(:,1));
    a=u.GetAtoms(ind);
    
    % Walk thru all comb's
    
    for n0=1:N0
        POV0=POV0s(n0,:);
        
        for n1=1:N1
            POV1=POV1s(n1,:);
            
            C=1;
            % Atoms in LOS box (ie in box with POV in opposite corners)
            LOSbox = ...
                a.surface(:,1)+a.res*C >= min(POV0(1),POV1(1)) & ...
                a.surface(:,1)-a.res*C <= max(POV0(1),POV1(1)) & ...
                a.surface(:,2)+a.res*C >= min(POV0(2),POV1(2)) & ...
                a.surface(:,2)-a.res*C <= max(POV0(2),POV1(2)) & ...
                a.surface(:,3)+a.res*C >= min(POV0(3),POV1(3)) & ...
                a.surface(:,3)-a.res*C <= max(POV0(3),POV1(3));
            
            % Remove endpoint atoms
            if exist('inds0','var'), LOSbox(inds0(n0))=0; end
            if exist('inds1','var'), LOSbox(inds1(n1))=0; end
            
            % See if any obstructions in LOS box
            if sum(LOSbox)
                center  = a.surface(LOSbox,:)-a.normal(LOSbox,:);
                res     = a.res(LOSbox,:);
                [dd,xx] = DistanceToLine(center,POV0,POV1);
                d = min(dd(xx>sys.largeScaleResolution/2)./res(xx>sys.largeScaleResolution/2))*2;
                
                LOS(n0,n1)=(isempty(d)||(d>=1));
            end
            
        end
    end
end


