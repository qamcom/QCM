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

function ElementTest(element,fig)

element

e =-pi/2:pi/300:pi/2;
a =-pi:pi/300:pi;
[ee,aa] = meshgrid(e,a);

C=20*log10(abs(reshape(element.ElementCoeff(60e9,aa(:),ee(:)),size(ee))));
Ce=20*log10(abs(element.ElementCoeff(60e9,0,e(:))));
Ca=20*log10(abs(element.ElementCoeff(60e9,a(:),0)));
C(C<-100)=-inf;
Ce(Ce<-100)=-inf;
Ca(Ca<-100)=-inf;

figure(fig); clf;
subplot(2,2,[1 2]);
contourf(a/pi*180,e/pi*180,C',-50:0);
colorbar
xlabel('Azimuth')
ylabel('Elevation')
title('Gain vs bore sight')

subplot(2,2,3);
plot(e(:)/pi*180,Ce(:));
title('Elevation pattern');
xlabel('degrees')
ylabel('dBi')
grid on;

subplot(2,2,4);
plot(a(:)/pi*180,Ca(:));
title('Azimuth pattern');
xlabel('degrees')
ylabel('dBi')
grid on;


