% Project pts on plane.
% Plane and pts anchored in same point
%
% y = VectorOnPlane(x,n)
% x:    3D vectors to project on plane. One end in origo
% n:    Normal of plane
%
% http://math.stackexchange.com/questions/633181/formula-to-project-a-vector-onto-a-plane
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

function y=VectorOnPlane(x,n)

% Expand size if scalar
N=max(size(x,1),size(n,1));
if size(x,1)==1, x=repmat(x,N,1); end
if size(n,1)==1, n=repmat(n,N,1); end

n  = n./repmat(vnorm(n,2),1,3);
y  = x-repmat(dot(n,x,2),1,3).*n;
