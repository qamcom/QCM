% Check if points x are inside polygon p
% Both x and p are 2D ccordinates eg x-coordinate x(point,1) y-coordinate = x(point,2)
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

function y=InsidePolygon(x,p)

% Do stuf in complex plane for speed and convenience
if size(x,2)==2; x=x*[1;1j]; end
if size(p,2)==2; p=p*[1;1j]; end

% Walk around perimeter (polygon) and add up angles
% If point is inside, the walk will be a full 360 path around that point.
% If point is outside, teh walk should end up in a zero net angle path...
arg = angle((x-p(end)).*conj(x-p(1)));
for ii=1:numel(p)-1
    tmp = angle((x-p(ii)).*conj(x-p(ii+1)));
    if ~sum(isnan(tmp)), arg = arg+tmp; end
end
y = abs(arg)>pi;
