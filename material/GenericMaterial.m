% Class to represent a generic material
%
% Constructor
% m = GenericMaterial(tag)
% tag:  label refer to available generic material model configs. Eg 'CMU', 'Street', 'Wall' etc
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

classdef GenericMaterial < Material
    
    properties
        freqs              % Frequency vector. Scalar of any value if frequency invariant.
        % Values below vectors of same size as freqs
        penetrationLoss    % dB
        scatteringLoss     % dB
        reflectionLoss     % dB
        reflectionExponent % No dimension. Determines strengh outside perfect reflection
        diffractionLoss    % dB
        diffractionExponent% No dimension. Determines strengh outside perfect reflection
    end
    
    methods
        
               
       
        % Reflection, Penetration and Scattring coeff of a surface
        %
        % y=SurfaceCoeff(freqs,r0,r1,e0,e1,a0,a1,p0,p1,pLoss,res)
        % freqs:    Frequency vector [Hz]
        % r0,r1:    Ray distance to source [m]
        % e0,e1:    Elevation "phase center" vs "ray source"
        % a0,a1:    Azimuth "phase center" vs "ray source"
        % p0,p1:    Polarisation vs corner [rad]
        % res:      Atom size [m]
        %
        % y:        Ray (amplitude) coeff. Matrix y(ray-index,freq-index)
        %
        function y=SurfaceCoeff(freqs,r0,r1,e0,e1,a0,a1,p0,p1,res)
            
            % get from properties: pLoss,sLoss,rLoss,rExp
            % pLoss:    Penetration loss [dB]
            % sLoss:    Scattering loss floor [dB]
            % rLoss:    Reflection loss min [dB]
            % rExp:     Reflection strength drop off
            
            Nf = numel(freqs);
            
            % Penetration (only with paths on different sides of atom surface)
            penetrationRequired = xor(e0>pi/2,e1>pi/2);
            penetrationCoeff    = 10.^(repmat(penetrationRequired,1,Nf).*(-pLoss)/20);
            
            if sys.forceNoPenetration
                penetrationCoeff(penetrationRequired,:)=0;
            end
            
            % Polarisation must align with reflection plane for perfect reflection.
            % Penetration is not polarisation selective though....
            polarisationCoeff   = repmat(max(penetrationRequired, sin(p0).*sin(p1)),1,Nf);
            
            % Reflection adjusted for diff from perfect reflection.
            % Scattering becomes dominant when reflection is weak.
            % Make sure we're on the same side (Penetration handled elsewhere)
            e0(e0>pi/2) = pi-e0(e0>pi/2);
            e1(e1>pi/2) = pi-e1(e1>pi/2);
            
            % Two paths vs Surface
            P0 = [ones(size(e0)),e0,a0];
            P1 = [ones(size(e1)),e1,a1];
            C0 = Cartesian3D(P0);
            C1 = Cartesian3D(P1);
            
            % Perfect Reflection. #0 mirrored on surface normal
            CR = -C0; % C0 defined as vector out-of surface.
            CR(:,3)=-CR(:,3);
            
            % Big Circle Diff of Retransmitted path (#1) vs Perfect Reflection path
            D  = AngleDiff(CR,C1);
            resP  = res.*sqrt(abs(cos(e0).*cos(e1))); % Projected atom size
            Dt = resP.*(r0+r1)./(r0.*r1);
            % %figure(99); hist([D,Dt]/pi*180,100);
            D = max(0,D-Dt/2);
            
            % Reflection
            if sys.forceNoReflection
                reflectionCoeff = 0;
            else
                %reflectionCoeff = repmat((max(0,cos(D(:))).^rExp),1,Nf).*10.^(-rLoss/20);
                reflectionCoeff = repmat(D(:)==0,1,Nf).*10.^(-rLoss/20);
            end
            
            % Scattering.
            if sys.forceNoScattering
                scatteringCoeff = 0;
            else
                scatteringCoeff = 10.^(-sLoss/20);
            end
            
            
            % Empirical/adhoc Geometry normalisation / Calibration with "WallTest.m"
            Offset = 14;
            resPn = resP.*(r0+r1)./(r0.*r1); % Normalized atom size
            geometryCoeff = resPn*10^(Offset/20);
            
            % Scattering independent of polarisation?
            y = penetrationCoeff.*(reflectionCoeff.*polarisationCoeff+repmat(geometryCoeff,1,Nf).*scatteringCoeff);
            
        end
        
        % Diffraction coeff around a corner
        %
        % y=CornerCoeff(freqs,r0,r1,e0,e1,a0,a1,p0,p1,res)
        % freqs:    Frequency vector [Hz]
        % r0,r1:    Ray distance to source [m]
        % e0,e1:    Elevation "phase center" vs "ray source"
        % a0,a1:    Azimuth "phase center" vs "ray source"
        % p0,p1:    Polarisation vs corner [rad]
        % res:      Atom size [m]
        %
        % y:        Ray (amplitude) coeff. Matrix y(ray-index,freq-index)
        function y=CornerCoeff(freqs,c,r0,r1,e0,e1,a0,a1,p0,p1,res)
            
            % get from properties: dLoss,dExp
            % dLoss:    Diffraction loss max [dB]
            % rExp:     Diffraction strength drop off
            
            Nf = numel(freqs);
            
            penetrationCoeff = ~or(e0>(pi+c)/2,e1>(pi+c)/2);
            
            
            % Ray projected thru Atom corner. Incoming and outgoing ray
            % Power proportional to projected atom corner length. Coeff for amplitude
            areaCoeff = sqrt(res.*sqrt(abs(cos(e0).*cos(e1)))); % 1D
            
            % Reflection adjusted for diff from perfect(no) diffraction.
            % Projected atom area
            resP = res.*sqrt(abs(cos(e0).*cos(e1)));
            
            % Perfect Diffraction. Eg no change of direction
            Ed = pi-e0;
            Ad = pi-a0;
            
            % Maximum diff to host a perfect diffraction (no deviation in elevation)
            Et = resP.*(r0+r1)./(r0.*r1);
            
            % Diff hysteresis. (Perfect Diffraction somewhere on corner segment)
            e1 = Ed+sign(e1-Ed).*max(0,abs(e1-Ed)-Et);
            
            % Two paths vs Surface
            P0 = [ones(size(e0)),e0,a0];
            P1 = [ones(size(e1)),e1,a1];
            C0 = Cartesian3D(P0);
            C1 = Cartesian3D(P1);
            
            % Perfect Reflection. #0 mirrored on surface normal
            CD = -C0; % C0 defined as vector out-of surface.
            
            % Big Circle Diff of Retransmitted path (#1) vs Perfect Reflection path
            D = AngleDiff(CD,C1);
            
            % Source: fig 6 in http://www.interdigital.com/research_papers/2014_02_18_60ghz_officebuilding_charac
            diffractCoeff = repmat((max(0,cos(D(:))).^dExp),1,Nf).*10.^(-dLoss/20);
            
            % Total diffracted signal...
            y = repmat(penetrationCoeff.*areaCoeff,1,Nf).*diffractCoeff;
        end
    end
end