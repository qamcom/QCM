% Rotate vectors x around axis n, by phi
%
% y = RotateAroundAxis(x,u,phi)
% x:    3D points to rotate
% u:    Vector around which to rotate pts (starts in origo)
% phi:  How much to rotate [rad]
%
% https://en.wikipedia.org/wiki/Rotation_matrix#In_three_dimensions
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

function y=RotateAroundAxis(x,u,phi)

ux = u(1);
uy = u(2);
uz = u(3);

R = [cos(phi)+ux^2*(1-cos(phi)) ux*uy*(1-cos(phi))-uz*sin(phi) ux*uz*(1-cos(phi))+uy*sin(phi);...
     uy*ux*(1-cos(phi))+uz*sin(phi) cos(phi)+uy^2*(1-cos(phi)) uy*uz*(1-cos(phi))-ux*sin(phi);...
     uz*ux*(1-cos(phi))-uy*sin(phi) uz*uy*(1-cos(phi))+ux*sin(phi) cos(phi)+uz^2*(1-cos(phi))];
 
 y=(R*x.').';
