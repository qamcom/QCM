% Find perpendicular distance to line
%
% [dd,xx] = DistanceToLine(x,p0,p1)
%
% x0:       Points in 3D [x,y,z]
% x1,x2:    Line definition (2 points)
%
% http://mathworld.wolfram.com/Point-LineDistance3-Dimensional.html
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

function [d,t]=DistanceToLine(x0,x1,x2)

N=max([size(x0,1),size(x1,1),size(x2,1)]);

x12   = VectorAdd(x2,-x1);
x01   = VectorAdd(x1,-x0);
d12   = vnorm(x12,2);

if size(x01,1)==1, x01=repmat(x01,N,1); end
if size(x12,1)==1, x12=repmat(x12,N,1); end

d = CrossMag(x12,x01)./d12;
t = -sum(x01.*x12,2)./d12;

% t measured from closest endpoint
t(t>d12/2) = d12-t(t>d12/2);