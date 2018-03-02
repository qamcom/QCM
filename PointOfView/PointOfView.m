% A group of arrays, with individual positions, and orientations
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

classdef PointOfView
    
    properties
        tag;       % Identifier string
        antsys;    % Array group class
        position;  % Point Of View coordinate (x y z) [m] 
        elevation; % Elevation vs horizon. Positive up. Neg dn [degrees]
        azimuth;   % Azimuth. Zero East/Right/Along X-axis. Positive vs North. Neg vs South
        velocity;  % Speed vector (x y z) [m/s]
        algorithm; % Assoc. Algorithm model
        hardware;  % Assoc. Hardware model
    end
    
    methods
        
        function x = PointOfView(tag,antsys,position,elevation,azimuth,velocity,algorithm,hardware)
            if nargin<6, velocity = [0 0 0]; end
            x.tag       = tag;
            x.antsys    = antsys; % Array group class
            x.position  = position;
            x.elevation = elevation;
            x.azimuth   = azimuth;
            if exist('velocity','var')
                x.velocity  = velocity;
            else
                x.velocity = [0 0 0];
            end
            if exist('algorithm','var')
                x.algorithm  = algorithm;
            end
            if exist('hardware','var')
                x.hardware  = hardware;
            end
        end
        
        % Get individual array orientations etc
        function [pov,dov,nov,pol,rot,array,vel] = xyz(p,index)
            
            % Default
            dov = [1 0 0];
            nov = [0 0 1];
            pov = [0 0 0];
            
            % Array Group
            as  = p.antsys; 
           
            % Array relative position
            if nargin>1
                
                pov   = as.positions(index,:);
                e     = as.elevations(index);
                a     = as.azimuths(index);
                rot   = as.rotations(index);
                pol   = as.arrays{index}.pol;
                array = as.arrays{index};
                
                % Rotate individual array in Elevation, Azimuth and Rot
                dov = RotateVectorY(dov,e);
                nov = RotateVectorY(nov,e);
                dov = RotateVectorZ(dov,a);
                nov = RotateVectorZ(nov,a);
                nov = RotateAroundAxis(nov,dov,rot);
            end
            
            % Rotate entire group in Elevation & Azimuth
            pov = RotateVectorY(pov,p.elevation);
            dov = RotateVectorY(dov,p.elevation); 
            nov = RotateVectorY(nov,p.elevation); 
            
            % Rotate in azimuth
            pov = RotateVectorZ(pov,p.azimuth); 
            dov = RotateVectorZ(dov,p.azimuth); 
            nov = RotateVectorZ(nov,p.azimuth);
                        
            % Array absolute position
            pov = pov + p.position;
            
            % Velocity
            vel = p.velocity;
            
        end

        
        function plot(x)
            
            cp=2;
            cn=2;

            [pov,dov,nov] = x.xyz;
            plot3(pov(1),pov(2),pov(3),'k*','MarkerSize',4), hold on;
            plot3([pov(1) pov(1)+2*cp*dov(1)],[pov(2) pov(2)+2*cp*dov(2)],[pov(3) pov(3)+2*cp*dov(3)],'k','LineWidth',4)
            plot3([pov(1) pov(1)+2*cn*nov(1)],[pov(2) pov(2)+2*cn*nov(2)],[pov(3) pov(3)+2*cn*nov(3)],'k:','LineWidth',4)
            text(pov(1),pov(2),pov(3),x.tag,'Color','black','FontSize',10,'HorizontalAlignment','center','Units','data' );

            for index=1:x.antsys.n
                [pov,dov,nov,~,~,a] = x.xyz(index);
                a.Plot(pov,dov,nov);
            end
            
        end
        
        % radius(ray)            Ray distance to source
        % elevation(ray)         Ray elevation vs antenn array (vs NOV)
        % azimuth(ray)           Ray azimuth vs antenna array (vs DOV)
        % elem(element,1)        Antenna element horizontal position (Horizontal arrays)
        % elem(element,2)        Antenna element vertical position (Vertical arrays)
        % Calculates coeff per antenna element
        % y(freq,elem)
        function y = ArrayCoeff(p,freqs,radius,elevation,azimuth)
            error;
            for n=1:x.narray
                if n==1
                    y = ArrayCoeff(p.array(n),freqs,radius,elevation,azimuth);    
                else
                    y = [y, ArrayCoeff(p.array(n),freqs,radius,elevation,azimuth)];    
                end
            end
        end
       
    end
end
