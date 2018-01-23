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

function plotcircle(xc,yc,r,c)
a=ishold;
hold on;
N=max([length(xc),length(yc),length(r)]);
if length(xc)==1, xc(1:N)=xc; end;
if length(yc)==1, yc(1:N)=yc; end;
if length(r)==1, r(1:N)=r; end;
theta = linspace(0,2*pi);
for n=1:N
    x = r(n)*cos(theta) + xc(n);
    y = r(n)*sin(theta) + yc(n);
    plot(x,y,c)
end
if ~a, hold off; end;
