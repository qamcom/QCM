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

classdef ArrayGroup
    
    properties (SetAccess = private)
        tag;        % Identifier string
        n;          % Nrof arrays
        arrays;     % Array class (list)
        positions;  % Array position in Group (x y x) [m]
        elevations; % Array elevation in Group [rad]  
        azimuths;   % Array azimuth in Group   [rad]
        rotations;  % Array rotation around bore sight [rad]
        nbit=[];    % Phase shifter bitwidth
        nelem=0;
        dualpol;
    end
    
    
    methods
        
        function x = ArrayGroup(tag,arrays,positions,elevations,azimuths,rotations,dualpol)
            x.tag        = tag;          
            x.n          = numel(arrays);    
            x.arrays     = arrays;
            for k=1:x.n
                x.nelem = x.nelem+x.arrays{k}.nelem;
            end
            x.positions  = positions;  
            x.elevations = elevations; 
            x.azimuths   = azimuths;   
            x.rotations  = rotations;   
            x.dualpol    = dualpol;   
        end     
                
        function y=subarray(x)
            y=[];
            for k=1:x.n
                sa = x.arrays{k}.subarray;
                y = [y,zeros(size(y,1),size(sa,2));zeros(size(sa,1),size(y,2)),sa];
            end
        end
           
    end
end



