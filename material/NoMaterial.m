% Class to represent a generic material
%
% Constructor
% m = GenericMaterial(tag)
% tag:  label refer to available generic material model configs. Eg 'CMU', 'Street', 'Wall' etc
%
% Methods
% y = m.SurfaceCoeff(freqs,radius0,radius1,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1,res)
% y = m.CornerCoeff(freqs,corner,radius0,radius1,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1,res)
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

classdef NoMaterial < Material
    
    
    % Abstract in parent class
    properties (SetAccess = private)
        tag     = 'Null';
        color   = nan;
        shading = nan;
    end
    
    methods
        
        
        function y=SurfaceCoeff(m,freqs,r0,r1,e0,e1,a0,a1,p0,p1,res)
            y = nan;            
        end
        
        function y=CornerCoeff(m,freqs,c,r0,r1,e0,e1,a0,a1,p0,p1,res)
            y = nan;
        end
    end
end