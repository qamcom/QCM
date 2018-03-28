% Plots 3D picture of universe, illustrating structures and materials
%
% u.Plot(x,forceColor)
% u is an handle to a Universe class (this class)
% x is a vector of POV coordinates to plot as well
% forceColor: Optional, Overrides atom colors
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
function Plot(u,x0,x1,forceColor,pbox)


if sys.plotAtoms
    
    a=u.GetAtoms;
    
    % Collect POV coordinates
    if nargin>1
        pov = zeros(0,3);
        for ii=1:numel(x0)
            pov(end+1,1:3)=x0{ii}.position;
        end
        if nargin>2
            for ii=1:numel(x1)
                pov(end+1,1:3)=x1{ii}.position;
            end
        end
    else
        pov=[];
    end
    
    % Select in atoms to actually plot
    clf;
    border=0.2;
    if ~isempty(a.res)
        if exist('pbox','var')&&~isempty(pbox)
            inrange = zeros(size(a.surface,1),1);
            dx = (pbox(2,1)-pbox(1,1));
            dy = (pbox(2,2)-pbox(1,2));
            bx = max(((1+2*border)*dy-dx)/2,border*dx);
            by = max(((1+2*border)*dx-dy)/2,border*dy);
            inrange = inrange|(a.surface(:,1)>pbox(1,1)-bx&a.surface(:,1)<pbox(2,1)+bx&a.surface(:,2)>pbox(1,2)-by&a.surface(:,2)<pbox(2,2)+by);
            a=a.Prune(find(inrange));
        elseif size(pov,1)
            inrange = zeros(size(a.surface,1),1);
            for ii=1:size(pov,1)
                inrange=inrange|(vnorm(VectorAdd(a.surface,-pov(ii,:)),2)<sys.maxRadius);
            end
            a=a.Prune(find(inrange));
        end
        
        
        % Render Universe and POV for LOS
        if exist('forceColor','var')&&~isempty(forceColor)
            a.Plot(forceColor);
        else
            a.Plot;
        end
    end
    
end
% Plot endpoints
if nargin>1
    for ii=1:numel(x0)
        x0{ii}.plot;
    end
end

if nargin>2
    for ii=1:numel(x1)
        x1{ii}.plot;
    end
end

s=u.GetStructures;
for k=1:length(s)
    s(k).Plot;
end

xlabel('X'); ylabel('Y'); zlabel('Z');
hold off;
axis equal
