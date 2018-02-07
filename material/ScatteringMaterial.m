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

classdef ScatteringMaterial < Material
    
    properties
        freqs               = 0;   % Frequency vector. Scalar of any value if frequency invariant.
        
        % Values below vectors of same size as freqs
        scatteringLoss      = 30; % dB
                
    end
    
    % Abstract in parent class
    properties (SetAccess = private)
        tag     = 'Default';
        color   = '1';
        shading = 0;
    end
    
    methods
        
        % Constructor
        function m=ScatteringMaterial(tag,loss)
            if nargin
                m.tag            = tag;
                m.scatteringLoss = loss;
            end
        end
        
        % Abstract in parent class
        % Reflection, Penetration and Scattring coeff of a surface
        %
        % y=SurfaceCoeff(freqs,r0,r1,e0,e1,a0,a1,p0,p1,res)
        % freqs:    Frequency vector [Hz]
        % r0,r1:    Ray distance to source [m]
        % e0,e1:    Elevation "phase center" vs "ray source"
        % a0,a1:    Azimuth "phase center" vs "ray source"
        % p0,p1:    Polarisation vs corner [rad]
        % res:      Atom size [m]
        %
        % y:        Ray (amplitude) coeff. Matrix y(ray-index,freq-index)
        %
        function y=SurfaceCoeff(m,freqs,r0,r1,e0,e1,a0,a1,p0,p1,res)
            
            Nr = numel(r0);
            
            % get from properties: pLoss,sLoss,rLoss,rExp
            % sLoss:    Scattering loss floor [dB]
            if numel(m.freqs)<=1,
                fbin = ones(size(freqs));
            else
                [~,fbin]=min(abs(repmat(m.freqs(:),1,numel(freqs))-repmat(freqs,numel(m.freqs,1))));
            end
            sLoss = m.scatteringLoss(fbin);
                       
            % Scattering.
            if sys.forceNoScattering
                scatteringCoeff = 0;
            else
                scatteringCoeff = 10.^(-sLoss/20);
            end
             
            % Scattering independent of polarisation?
            y = repmat(scatteringCoeff,Nr,1);
            
        end
        
        % Abstract in parent class
        % Diffraction coeff around a corner
        %
        % y=CornerCoeff(freqs,c,r0,r1,e0,e1,a0,a1,p0,p1,res)
        % freqs:    Frequency vector [Hz]
        % c:        Corners
        % r0,r1:    Ray distance to source [m]
        % e0,e1:    Elevation "phase center" vs "ray source"
        % a0,a1:    Azimuth "phase center" vs "ray source"
        % p0,p1:    Polarisation vs corner [rad]
        % res:      Atom size [m]
        %
        % y:        Ray (amplitude) coeff. Matrix y(ray-index,freq-index)
        function y=CornerCoeff(m,freqs,c,r0,r1,e0,e1,a0,a1,p0,p1,res)
            y=0;
        end
    end
end