% -------------------------------------------------------------------------
% https://en.wikipedia.org/wiki/Hata_Model
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

function y = StochasticCoeff(f,d,h0,h1,scenario)

hB=max(h0,h1); % BTS height
hM=min(h0,h1); % MS height

nr = length(d);
nf = length(f); 

f=f/1e6; % MHz below...
d=d/1e3; % km below

hM = min(10,max(1,hM));
hB = min(200,max(30,hB));

Ch=0; Chd=0; Chf=0;
switch scenario
    case 'hata-urban-smallcity'
        Ch  = 0.8+hM*(1.1*log10(f)-0.7);
        Chf = -1.56*log10(f);
    case 'hata-urban-largecity'
        if mean(f)<200
            Chd = 8.29*log10(1.54*hM).^2-1.1;            
        else
            Chd = 3.2*log10(11.75*hM).^2-4.97;
        end
end  

Luf = 69.55+26.16*log10(f);
Lud = -13.82*log10(hB)-Chd+(44.9-6.55*log10(hB)).*log10(d(:));
Lu  = repmat(Luf-Chf,nr,1)+repmat(Lud,1,nf)-Ch;

switch scenario
    case 'hata-urban-smallcity'
        L = Lu;
    case 'hata-urban-largecity'
        L = Lu;
    case 'hata-suburban'
        Lsuf = -2*log10(f/28).^2-5.4;
        L = repmat(Lsuf,nr,1)+Lu;
    case 'hata-rural'
        L0f  = -4.78*log10(f).^2+18.33*log10(f)-40.94;
        L = repmat(L0f,nr,1)+Lu;
end

y = 10.^(-L/20);