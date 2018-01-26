% Class to represent a material
% Model selected when defined.
%
% Constructor
% m=Material(tag,shading)
% tag:  label refer to availbale material models. Eg 'CMU', 'Street', 'Wall' etc
% shading: If zero thsi matrial will be excluded when finfing atoms in shade (in ray tracing)
%
% Methods
% y = m.SurfaceCoeff(freqs,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1,radius0,radius1,res)
% y = m.CornerCoeff(freqs,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1,radius0,radius1,res)
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

classdef Material < matlab.mixin.Heterogeneous
    
   properties
      Description char = 'Material'
      shading  % Include as shading.
   end
   properties (Abstract, SetAccess = private)
      Type
      color    % Plot color
   end
   methods (Abstract)
      y = SurfaceCoeff(m,freqs,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1,radius0,radius1,res);
      y = CornerCoeff(m,freqs,corner,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1,radius0,radius1,res);
   end
   methods (Static, Sealed, Access = protected)
      function defaultObject = getDefaultScalarElement
         defaultObject = DefaultMaterial;
      end
   end
    
   
    methods
        
%         % Constructor
%         function m=Material(tag,shading,gain)
%             if nargin
%             switch tag
%                 case 'Scatterer', m.color = 4; m = ScatteringMaterial;
%                 case 'Street',    m.color = 3; m = GenericMaterial();
%                 case 'Wood',      m.color = 2; m = GenericMaterial();
%                 case 'CMU',       m.color = 1; m = GenericMaterial();
%             end
%             m.tag     = tag;
%             m.shading = shading;
%             end 
%         end
%         
      
    end
    
end
