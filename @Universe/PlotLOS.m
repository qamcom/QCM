% Plots 3D picture of universe, illustrating line-of-sight
%
% u.PlotLOS(POV0,POV1)
% u is an handle to a Universe class (this class)
% POV0, POV1: [x,y,z] Coordinates of point-of-view [m]
%
% POV1 is optional. 
% Atoms painted white:  In sight of both POV (or POV0 if POV1 not passed)
% Atoms painted red|green: In sight of one POV, and not the other
% Blue atome are not in line-of-sight of any POV
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

function PlotLOS(u,POV0,POV1)

clf;

s=u.GetStructures;
for k=1:length(s)
    s(k).Plot(0);
end

[indLOS0,indNLOS0] = u.FindLOS(POV0,sys.maxRadius);
if ~exist('POV1','var') || isempty(POV1)
    indLOS1  = indLOS0;
    indNLOS1 = indNLOS0;
    POV1     = POV0;
else
    [indLOS1,indNLOS1] = u.FindLOS(POV1,sys.maxRadius);
end
indLOS   = intersect(indLOS0,indLOS1);
indNLOS  = union(indNLOS0,indNLOS1);
indLOS00 = setdiff(indLOS0,indLOS);
indLOS11 = setdiff(indLOS1,indLOS);


hold on;
if numel(indLOS)
    a = u.GetAtoms(indLOS);
    a.Plot('w');
end
if numel(indLOS00)
    a = u.GetAtoms(indLOS00);
    a.Plot('r');
end
if numel(indLOS11)
    a = u.GetAtoms(indLOS11);
    a.Plot('g');
end

plot3(POV0(:,1),POV0(:,2),POV0(:,3),'r*')
plot3(POV1(:,1),POV1(:,2),POV1(:,3),'g*')

if u.CheckLOS(POV0,POV1,sys.maxRadius)
    POV=[POV0;POV1];
    plot3(POV(:,1),POV(:,2),POV(:,3),'r')
    plot3(POV(:,1),POV(:,2),POV(:,3),'g--')
end

title('Atoms in LOS of both endpoints')

xlabel('X'); ylabel('Y'); zlabel('Z');
hold off;
axis equal
