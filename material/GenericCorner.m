% Diffraction coeff around a corner
%
% y=GenericCorner(freqs,r0,r1,e0,e1,a0,a1,p0,p1,dLoss,res)
% freqs:    Frequency vector [Hz]
% r0,r1:    Ray distance to source [m]
% e0,e1:    Elevation "phase center" vs "ray source"
% a0,a1:    Azimuth "phase center" vs "ray source"
% p0,p1:    Polarisation vs corner [rad]
% dLoss:    Diffraction loss max [dB]
% rExp:     Diffraction strength drop off
% res:      Atom size [m]
%
% y:        Ray (amplitude) coeff. Matrix y(ray-index,freq-index)
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

function y=GenericCorner(freqs,c,r0,r1,e0,e1,a0,a1,p0,p1,dLoss,dExp,res)

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
