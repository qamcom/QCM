% Attenuation coeff vs rays and frequencies
% 
% y=AtmosphereCoeff(freqs,radius,rain)
% freqs:    Frequency vector [Hz]
% radius:   Ray distance [m]
% rain:     Rain intensity [mm/h]
% y:        Ray (amplitude) coeff. Matrix y(ray-index,freq-index)
%
% Source
% http://www.ofcom.org.uk/static/archive/ra/topics/research/rcru/project28/results.htm
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


function y=AtmosphereCoeff(freqs,radius,rain)

% Digitized From paper linked above
% rain = [125 25 5 0.25];
% afitm = [47 13.4 4.58 0.5];
% bfitm = [-52 -14.3 -5 -0.58];
% cfitm = [-0.06314 -0.0329 -0.02347 -0.01475];

% Fit model from digitized data
afit = 181.5-61404./(rain+343);
bfit = -afit;
cfit = -0.095+7./(rain+89);
dBkm_rain = afit+bfit*10.^(cfit*freqs/1e9);

% Air attenuation (02 oscillations etc)
dBkm_air  = AirCoeff(freqs);

% Combined
dBkm      = dBkm_rain(:)'+dBkm_air(:)';

% Amplitude of combined attenuation
y = single(10.^(-(radius(:)/1000)*dBkm/20));



