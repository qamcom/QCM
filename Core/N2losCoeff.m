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

function [y,meta] = N2losCoeff(freqs,times,array0,array1,dp0,dp1,rotation0,rotation1,speed,materials0,materials1,corners0,corners1,radius0,radius1,radius01,elevation0,elevation1,azimuth0,azimuth1,elevation01,elevation10,azimuth01,azimuth10,offAzimuth0,offElevation0,offAzimuth1,offElevation1,pol0,pol1,res0,res1,los01,rain,raySelThreshold,bb)
Nf = numel(freqs);
Nr = numel(elevation1);

elemCoeff0        = array0.element.ElementCoeff(freqs,offAzimuth0,offElevation0);
elemCoeff1        = array1.element.ElementCoeff(freqs,offAzimuth1,offElevation1);
distanceCoeff     = DistanceCoeff(freqs,radius0+radius01(:)+radius1);
atmosphereCoeff   = AtmosphereCoeff(freqs,radius0+radius01+radius1,rain);

% Phase center n2los coeff is a superposition of all nlos rays
tmp0 = repmat(bb,Nr,1).*elemCoeff0.*elemCoeff1.*distanceCoeff.*atmosphereCoeff.*repmat(los01,1,Nf);

% First polarisation mode
retransCoeff0  = RetransCoeff(freqs,materials0,corners0,elevation0,elevation01,azimuth0,azimuth01,pol0,pi/4,radius0,radius01,res0);
retransCoeff1  = RetransCoeff(freqs,materials1,corners1,elevation1,elevation10,azimuth1,azimuth10,pol1,pi/4,radius0,radius01,res1);
tmp = tmp0.*retransCoeff0.*retransCoeff1;
c00 = squeeze(rms(tmp,2));

% Expand to antenna array.
[y00,ind00] = ExpandArray(tmp,freqs,times,raySelThreshold,speed,...
    radius0,offElevation0,offAzimuth0,array0,rotation0,...
    radius1,offElevation1,offAzimuth1,array1,rotation1);

% More polarisation modes?

if dp0,
    
    % Second polarisation mode (add 90 degress to pov0 polarisation)
    retransCoeff0p  = RetransCoeff(freqs,materials0,corners0,elevation0,elevation01,azimuth0,azimuth01,pol0+pi/4,pi/4,radius0,radius01,res0);
    tmp = tmp0.*retransCoeff0p.*retransCoeff1;
    c10 = squeeze(rms(tmp,2));
    
    % Expand to antenna array.
    [y10,ind10] = ExpandArray(tmp,freqs,times,raySelThreshold,speed,...
        radius0,offElevation0,offAzimuth0,array0,rotation0,...
        radius1,offElevation1,offAzimuth1,array1,rotation1);
end

if dp1,
    
    % Third polarisation mode (add 90 degress to pov1 polarisation)
    retransCoeff1p  = RetransCoeff(freqs,materials1,corners1,elevation1,elevation10,azimuth1,azimuth10,pol1+pi/4,pi/4,radius0,radius01,res1);
    tmp = tmp0.*retransCoeff0.*retransCoeff1p;
    c01 = squeeze(rms(tmp,2));
    
    % Expand to antenna array.
    [y01,ind01] = ExpandArray(tmp,freqs,times,raySelThreshold,speed,...
        radius0,offElevation0,offAzimuth0,array0,rotation0,...
        radius1,offElevation1,offAzimuth1,array1,rotation1);
end

if dp0 && dp1,
    
    % Forth polarisation mode (add 90 degress to both pov0 and pov1 polarisations)
    tmp = tmp0.*retransCoeff0p.*retransCoeff1p;
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
meta.sel         = ind;
if ~isempty(ind)
    meta.rays        = size(c,1);
    meta.coeff       = c(ind,:,:);
    meta.radius      = radius0(ind)+radius1(ind)+radius01(ind);
    meta.speed       = speed(ind);
    meta.LOS         = los01(ind);
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


