% Material model "CMU" 
% See class Material for interface
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

classdef CMU_Material < handle
    
    methods
        
        function  m=CMU_Material
        end

        function y = SurfaceCoeff(m,freqs,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1,radius0,radius1,res)
            
            Np = numel(elevation0);
            Nf = numel(freqs);
            
            % These should depend on frequency, elevation and polarisation
            penetrationLoss = repmat(30,Np,Nf); % dB
            scatteringLoss  = repmat(50,Np,Nf); % dB
            reflectionLoss  = repmat(3,Np,Nf);  % dB
            
            reflectionExponent = 30; % No dimension. Determines strengh outside perfect reflection
            
            y=GenericSurface(freqs,radius0,radius1,elevation0,elevation1,azimuth0,azimuth1,...
                pol0,pol1,penetrationLoss,scatteringLoss,reflectionLoss,reflectionExponent,res);
            
        end
        
        function y = CornerCoeff(m,freqs,corner,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1,radius0,radius1,res)
            
            Np = numel(elevation0);
            Nf = numel(freqs);
            
            diffractionLoss  = repmat(40,Np,Nf); % [dB]
            diffractionExponent = 30; % No dimension.
            
            y=GenericCorner(freqs,corner,radius0,radius1,elevation0,elevation1,...
                azimuth0,azimuth1,pol0,pol1,diffractionLoss,diffractionExponent,res);
            
        end
    end
end
