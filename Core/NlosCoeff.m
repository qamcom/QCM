% -------------------------------------------------------------------------
% materialIndex:
% freqs:    Frequencies to analyze [Hz]
% elem:     Array element positions (vs phase center)
% radius0:  Distance from POV0 to bounce. [m]
% radius1:  Distance from bounce to POV1. [m]
% elevationS0: Incident angle from POV0 vs surface normal [rad]
% elevationS1: Incident angle from POV1 vs surface normal [rad]
% azimuthS01: Angle difference of paths projected on surface [rad]
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

function [y,meta] = NlosCoeff(freqs,times,array0,array1,dp0,dp1,rotation0,rotation1,...
    speed,materials,corners,radius0,radius1,elevation0,elevation1,azimuth0,azimuth1,...
    offAzimuth0,offElevation0,offAzimuth1,offElevation1,pol0,pol1,res,rain,raySelThreshold,bb)
Nf = numel(freqs);
Nr = numel(elevation1);

elemCoeff0      = array0.element.ElementCoeff(freqs,offAzimuth0,offElevation0);
elemCoeff1      = array1.element.ElementCoeff(freqs,offAzimuth1,offElevation1);
distanceCoeff   = DistanceCoeff(freqs,radius0+radius1);
atmosphereCoeff = AtmosphereCoeff(freqs,radius0+radius1,rain);

tmp0 = repmat(bb,Nr,1).*elemCoeff0.*elemCoeff1.*distanceCoeff.*atmosphereCoeff;

% First polarisation mode
retransCoeff = RetransCoeff(freqs,materials,corners,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1,radius0,radius1,res);
tmp = tmp0.*retransCoeff;
c00 = squeeze(rms(tmp,2));

% Expand to antenna array.
[y00,ind00] = ExpandArray(tmp,freqs,times,raySelThreshold,speed,...
    radius0,offElevation0,offAzimuth0,array0,rotation0,...
    radius1,offElevation1,offAzimuth1,array1,rotation1);

% More polarisation modes?

if dp0
    
    % Second polarisation mode (add 90 degress to pov0 polarisation)
    retransCoeff = RetransCoeff(freqs,materials,corners,elevation0,elevation1,azimuth0,azimuth1,pol0+pi/2,pol1,radius0,radius1,res);
    tmp = tmp0.*retransCoeff;
    c10   = squeeze(rms(tmp,2));
    
    % Expand to antenna array.
    [y10,ind10] = ExpandArray(tmp,freqs,times,raySelThreshold,speed,...
        radius0,offElevation0,offAzimuth0,array0,rotation0,...
        radius1,offElevation1,offAzimuth1,array1,rotation1);
end

if dp1
    
    % Third polarisation mode (add 90 degress to pov1 polarisation)
    retransCoeff = RetransCoeff(freqs,materials,corners,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1+pi/2,radius0,radius1,res);
    tmp = tmp0.*retransCoeff;
    c01 = squeeze(rms(tmp,2));
    
    % Expand to antenna array.
    [y01,ind01] = ExpandArray(tmp,freqs,times,raySelThreshold,speed,...
        radius0,offElevation0,offAzimuth0,array0,rotation0,...
        radius1,offElevation1,offAzimuth1,array1,rotation1);
end

if dp0 && dp1
    
    % Forth polarisation mode (add 90 degress to both pov0 and pov1 polarisations)
    retransCoeff = RetransCoeff(freqs,materials,corners,elevation0,elevation1,azimuth0,azimuth1,pol0+pi/2,pol1+pi/2,radius0,radius1,res);
    tmp = tmp0.*retransCoeff;
    c11 = squeeze(rms(tmp,2));
    
    % Expand to antenna array.
    [y11,ind11] = ExpandArray(tmp,freqs,times,raySelThreshold,speed,...
        radius0,offElevation0,offAzimuth0,array0,rotation0,...
        radius1,offElevation1,offAzimuth1,array1,rotation1);
end

if dp0 && dp1
    y = cat(2,cat(1,y00,y10),cat(1,y01,y11));
    c = cat(3,cat(2,c00,c10),cat(2,c01,c11));
    ind = unique([ind00(:);ind10(:);ind01(:);ind11(:)]);
elseif dp0
    y = cat(1,y00,y10);
    c = cat(2,c00,c10);
    ind = unique([ind00(:);ind10(:)]);
elseif dp1
    y = cat(2,y00,y01);
    c = cat(3,c00,c01);
    ind = unique([ind00(:);ind01(:)]);
else
    y = y00;
    c = c00;
    ind = ind00(:);
end

y      = single(y);
meta.P = 20*log10(rms(y(:)));

% Collect metadata
if ~isempty(ind)
    meta.rays        = size(c,1);
    meta.sel         = ind;
    meta.coeff       = c(ind,:,:);
    meta.radius      = radius0(ind)+radius1(ind);
    meta.atomAoA0    = azimuth0(ind)/pi*180;
    meta.atomEoA0    = elevation0(ind)/pi*180;
    meta.atomAoA1    = azimuth1(ind)/pi*180;
    meta.atomEoA1    = elevation1(ind)/pi*180;
    meta.atomPol0    = pol0(ind)/pi*180;
    meta.atomPol1    = pol1(ind)/pi*180;
    meta.ant0AoA     = offAzimuth0(ind)/pi*180;
    meta.ant0EoA     = offElevation0(ind)/pi*180;
    meta.ant1AoA     = offAzimuth1(ind)/pi*180;
    meta.ant1EoA     = offElevation1(ind)/pi*180;
    meta.elemCoeff0      = 20*log10(rms(elemCoeff0(:)));
    meta.elemCoeff1      = 20*log10(rms(elemCoeff1(:)));
    meta.distanceCoeff   = 20*log10(rms(distanceCoeff(:)));
    meta.atmosphereCoeff = 20*log10(rms(atmosphereCoeff(:)));
end