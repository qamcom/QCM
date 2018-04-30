% Return index of points that are hidden behind a sphere
% Viewpoint is origo
%
% ind=BehindSphere(p,r,x)
%
% p:   Sphere center
% r:   Sphere radius
% x:   Points 3D coordinates (potentially behind p)
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

function behind = BehindSphere(p,r,x)

alfa   = AngleDiff(p,x); % Relative Angle of rays 
D      = vnorm(p,2);     % Distance to sphere
beta   = atan(r/D);      % Angle of sphere
behind = (vnorm(x,2)>D+r/2) & (alfa<=beta);


