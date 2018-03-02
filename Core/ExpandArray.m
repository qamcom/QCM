% Expand coeff for phase center into individual antenna elements,a nd small
% scale time samples
% Using spherical wave front model
% Also prune weak rays before expanding
%
% y = ExpandArray(freqs,times,x,threshold,speed,r0,e0,a0,array0,r1,e1,a1,array1)
% x(ray,freqbin): Complex Coeff for phase center. Incl element gain, pathloss, reflection loss etc
% freqs:    Frequency vector [Hz]
% threshold:Keep rays stronger than threshold (vs strongest) [dB]
% speed:    Doppler speed (apporaching) [m/s] per ray
% r0,r1:    Ray distance to source [m]
% e0,e1:    Elevation "phase center" vs "ray source"
% a0,a1:    Azimuth "phase center" vs "ray source"
% array0,array1: Endpoints. Array class
%
% y(elm0Ind,elm1Ind,freqInd,timeInd):    Channel coeff. 
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

function [y,raySel] = ExpandArray(x,freqs,times,raySelThreshold,speed,...
    radius0,elevation0,azimuth0,array0,rotation0,...
    radius1,elevation1,azimuth1,array1,rotation1)

% Keep only significant rays
rayPower    = 20*log10(rms(double(x),2));
raySel      = find(rayPower>max(rayPower)-raySelThreshold);
Nr          = numel(raySel);
Nt          = numel(times);
Nf          = numel(freqs);


if Nr==0
    
    y = zeros(array0.nelem,array1.nelem,Nf,Nt);
    
else
    
    x           = x(raySel,:);
    radius0     = radius0(raySel);
    radius1     = radius1(raySel);
    elevation0  = elevation0(raySel);
    elevation1  = elevation1(raySel);
    azimuth0    = azimuth0(raySel);
    azimuth1    = azimuth1(raySel);
    speed       = speed(raySel);
    
    % Add doppler shift (translate spectrum of each selected ray)
    doppler     = mean(speed(:)*freqs(:)'/sys.c,2); % [Hertz]
    if sys.enableDopplerSpread
        df          = mean(diff(freqs));
        di          = doppler/df;
        x           = Skew(x,di);
    end
    
    % Expand time samples. Small scale temporal extrapolation
    % x(ray,freq) => x(ray,freq,time)
    A = repmat(x,[1,1,Nt]);
    F = repmat(doppler,1,Nf)+repmat(freqs,Nr,1);
    P = multiprod(F,1j*times*2*pi,[2,3],[1,2]);
    x = permute(A.*exp(P),[1,2,4,5,3]);
    
    % Array coeff per endpoint. Small scale Spatial extrapolation(spherical wave)
    arrayCoeff0 = array0.ArrayCoeff(freqs,radius0,elevation0,azimuth0,rotation0);
    arrayCoeff1 = array1.ArrayCoeff(freqs,radius1,elevation1,azimuth1,rotation1);
    
    % Map rays on all array element combinations. Then sum over rays.
    % These two rows are a huge part of all ops in QCM... 
    % Candidate for GPU and/or Cluster acceleration
    arrayCoeff  = multiprod(arrayCoeff0,permute(arrayCoeff1,[1,2,4,3]),[3,4]);
    y = permute((sum(multiprod(x,arrayCoeff,[3,4]),1)),[3,4,2,5,1]);
    
end