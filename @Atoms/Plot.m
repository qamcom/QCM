% Plot atoms
%
% Plot(a,forceColor)
% a is an handle to a Atom class (this class)
% forceColor: Optional, Overrides atom colors
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

function Plot(a,forceColor)

hold on;

EdgeAlpha = 0.99;
FaceAlpha = 0.9;

% Plot Surfaces
if sys.plotSurfacePatches
    [x,y,z,c] = a.SurfacePatches;
    if nargin==2, c = forceColor; end
    patch(x,y,z,c,'FaceAlpha',FaceAlpha,'EdgeAlpha',EdgeAlpha);
    %patch(x,y,z,c,'FaceAlpha',FaceAlpha,'EdgeColor','none');
end

% Plot Corners
if sys.plotCornerPatches
    [x,y,z,c] = a.CornerPatches;
    if nargin==2, c = forceColor; end
    patch(x,y,z,c,'FaceAlpha',FaceAlpha,'EdgeAlpha',EdgeAlpha);
end
[x,y,z] = a.CornerLines;
if nargin==1
    line(x,y,z,'Color','k','LineWidth',2);
else
    line(x,y,z,'Color',forceColor,'LineWidth',2);
end

if sys.plotAtomNormals
    error('Not implemented.')
end

% Plot Spheres (no surface, no corner)
if sys.plotShadingSpheres
    ind = find([a.material.shading]'&(a.corner(:,1)==0));
else
    ind = find(~vnorm(a.normal,2));
end
N = numel(ind);
M = 16;
[xx,yy,zz]=sphere(M-1);
posx = a.surface(ind,1)-a.normal(ind,1);
posy = a.surface(ind,2)-a.normal(ind,2);
posz = a.surface(ind,3)-a.normal(ind,3);
res  = a.res(ind)/2;
if nargin>1&&ischar(forceColor), forceColor=color2rgb(forceColor); end;
for ii=1:N
    if nargin==1
        surf(xx*res(ii)+posx(ii),yy*res(ii)+posy(ii),zz*res(ii)+posz(ii),repmat(permute(color2rgb('g'),[1,3,2]),M,M),'FaceAlpha',FaceAlpha,'EdgeAlpha',EdgeAlpha);
        %surf(xx*res(ii)+posx(ii),yy*res(ii)+posy(ii),zz*res(ii)+posz(ii),repmat(permute(color2rgb('g'),[1,3,2]),M,M),'FaceAlpha',FaceAlpha,'EdgeColor','none');
    else
        surf(xx*res(ii)+posx(ii),yy*res(ii)+posy(ii),zz*res(ii)+posz(ii),repmat(permute(forceColor,[1,3,2]),M,M),'FaceAlpha',FaceAlpha,'EdgeAlpha',EdgeAlpha);
        %surf(xx*res(ii)+posx(ii),yy*res(ii)+posy(ii),zz*res(ii)+posz(ii),repmat(permute(color2rgb(forceColor),[1,3,2]),M,M),'FaceAlpha',FaceAlpha,'EdgeColor','none');
    end 
end




