% A Structure is a group of surfaces, corners and clouds.
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

classdef Structure
    
    properties
        points;
        surfaces;
        corners;
        clouds;
        p0;
    end
    
    methods
        
        function s = Structure(points,surfaces,corners,clouds)
            if nargin
                s.points   = points;
                s.surfaces = surfaces;
                s.corners  = corners;
                s.clouds   = clouds;
            end
        end
        
        function Plot(s,plotCorners)
            
            cm=colormap;
            
            % Surfaces
            N=numel(s.surfaces);
            for n=1:N
                sn = s.surfaces{n};
                xyz = s.points(sn.pi,:);
                rgb = cm(sn.material.color,:);
                patch('XData',xyz(:,1),'YData',xyz(:,2),'ZData',xyz(:,3),'FaceColor',rgb,'FaceAlpha',.1,'EdgeColor','none');
            end
            
            % Corners
            if nargin<2 || plotCorners
                N=numel(s.corners);
                for n=1:N
                    cn = s.corners{n};
                    xyz = s.points(cn.pi,:);
                    rgb = cm(cn.material.color,:);
                    line('XData',xyz(:,1),'YData',xyz(:,2),'ZData',xyz(:,3),'Color',rgb,'LineWidth',2);
                end
            end
            
            % Clouds
            N=numel(s.clouds);
            if N
                M = 16;
                [xx,yy,zz]=sphere(M-1);
            end
            for n=1:N
                cn  = s.clouds{n};
                xyz = s.points(cn.pi,:);
                rgb = cm(cn.material.color,:);
                rad = cn.radius;
                for ii=1:size(xyz,1)
                    surf(xx*rad+xyz(ii,1),yy*rad+xyz(ii,2),zz*rad+xyz(ii,3),repmat(permute(rgb,[1,3,2]),M,M),'FaceAlpha',0.5,'EdgeColor','none');
                end
            end
            
        end
        
    end
    
end
