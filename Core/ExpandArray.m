% Expand coeff for phase center into individual antenna elements
% Using spherical wave front model
% Also prune weak rays before expanding
% 
% y = ExpandArray(freqs,x,threshold,speed,r0,e0,a0,array0,r1,e1,a1,array1)
% freqs:    Frequency vector [Hz]
% threshold:Keep rays stronger than threshold (vs strongest) [dB]
% speed:    Doppler speed (apporaching) [m/s]
% x(ray,freqbin): Complex Coeff for phase center. Incl element gain, pathloss, reflection loss etc
% r0,r1:    Ray distance to source [m]
% e0,e1:    Elevation "phase center" vs "ray source"
% a0,a1:    Azimuth "phase center" vs "ray source"
% array0,array1: Endpoints. Array class 
%
% y:        Channel coeff. y(freq-index,elm0,elm1)
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

function [y,raySel] = ExpandArray(freqs,x,raySelThreshold,speed,...
    radius0,elevation0,azimuth0,array0,rotation0,...
    radius1,elevation1,azimuth1,array1,rotation1)

% Keep only significant rays
rayPower    = 20*log10(rms(double(x),2));
raySel      = find(rayPower>max(rayPower)-raySelThreshold);
if isempty(raySel)
    y = zeros(numel(freqs),array0.nelem,array1.nelem);
    return;
end
x           = x(raySel,:);
radius0     = radius0(raySel);
radius1     = radius1(raySel);
elevation0  = elevation0(raySel);
elevation1  = elevation1(raySel);
azimuth0    = azimuth0(raySel);
azimuth1    = azimuth1(raySel);
speed       = speed(raySel);

% Add doppler shift (translate spectrum of each selected ray)
if sys.enableDopplerSpread
    doppler     = mean(speed(:)*freqs(:)'/sys.c,2); % [Hertz]
    df          = mean(diff(freqs));
    di          = doppler/df;
    x           = Skew(x,di);
end

% Array coeff per endpoint
arrayCoeff0 = array0.ArrayCoeff(freqs,radius0,elevation0,azimuth0,rotation0);
arrayCoeff1 = array1.ArrayCoeff(freqs,radius1,elevation1,azimuth1,rotation1);

% Map rays on all array element combinations
arrayCoeff  = multiprod(arrayCoeff0,permute(arrayCoeff1,[1,2,4,3]),[3,4]);
y           = permute((sum(multiprod(x,arrayCoeff,[3,4]),1)),[2,3,4,1]);

