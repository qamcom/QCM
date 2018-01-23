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

function [y,meta]=LosCoeff(freqs,array0,array1,dp0,dp1,rotation0,rotation1,speed,radius,offAzimuth0,offElevation0,offAzimuth1,offElevation1,polDiff,LOS,rain,raySelThreshold,bb)

% Phase center los coeff 
tmp = bb.*array0.element.ElementCoeff(freqs,offAzimuth0,offElevation0).*...
      array1.element.ElementCoeff(freqs,offAzimuth1,offElevation1).*...
      DistanceCoeff(freqs,radius).*...
      AtmosphereCoeff(freqs,radius,rain)*LOS;
  
% First orthogonal polarisation mode
tmp0   = tmp.*cos(polDiff);

% Expand to antenna array.
y0 = ExpandArray(freqs,tmp0,raySelThreshold,speed,...
    radius,offElevation0,offAzimuth0,array0,rotation0,...
    radius,offElevation1,offAzimuth1,array1,rotation1);

% More polarisation modes?
if dp0 || dp1
    
    % Second orthogonal polarisation mode
    tmp1   = tmp.*sin(polDiff);
    y1 = ExpandArray(freqs,tmp1,raySelThreshold,speed,...
        radius,offElevation0,offAzimuth0,array0,rotation0,...
        radius,offElevation1,offAzimuth1,array1,rotation1);
end

if dp0 && dp1
    y = cat(5,cat(4,y0,y1),cat(4,y1,y0));
    c = squeeze(rms([tmp0;tmp1],2));
elseif dp0
    y = cat(4,y0,y1);
    c = squeeze(rms([tmp0,tmp1],2));
elseif dp1
    y = cat(5,y0,y1);
    c = squeeze(rms([tmp0,tmp1],2));
else
    y = y0;
    c = squeeze(rms(tmp0,2));
end
    
y = single(y);

% Collect metadata
meta.LOS     = LOS;
meta.coeff   = c;
meta.radius  = radius;
meta.polDiff = polDiff/pi*180;
meta.ant0AoA = offAzimuth0/pi*180;
meta.ant0EoA = offElevation0/pi*180;
meta.ant1AoA = offAzimuth1/pi*180;
meta.ant1EoA = offElevation1/pi*180;
meta.P       = 20*log10(rms(y(:)));

