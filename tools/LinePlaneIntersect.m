% Find point of intersection btw lines and a plane
%
% [d,r] = LinePlaneIntersect(L0,Ln,P0,Pn)
% L0 is a point on the line. Ln is the direction of the line
% P0 is a point on the plane. Pn i sthe normal of the plane
% d is the relative distance to th eplane, on the line. Pt of intersect = L0+d*Ln
% r is the distance from pt of intersect, to P0, i.e. norm(L0+d*Ln-P0)
%
% https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection
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

function [d,r]=LinePlaneIntersect(L0,Ln,P0,Pn)

N = max([size(L0,1),size(Ln,1),size(P0,1),size(Pn,1)]);
if size(L0,1)==1, L0=repmat(L0,N,1); end
if size(Ln,1)==1, Ln=repmat(Ln,N,1); end
if size(P0,1)==1, P0=repmat(P0,N,1); end
if size(Pn,1)==1, Pn=repmat(Pn,N,1); end


% Line p=d*Ln+L0
% Plane dot(p-P0,Pn)=0
% Point x resides on both line and plane if
% dot(d*Ln+L0-P0,Pn)=0
% or 
d = dot(P0-L0,Pn,2)./dot(Ln,Pn,2); % Relative Distance on line where they meet 
x = repmat(d,1,3).*Ln+L0;          % Point in 3D where they meet.

r = vnorm(x-P0,2);                 % Distance to Plane center (P0)
