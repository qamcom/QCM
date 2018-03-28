% Return index of points that are hidden behind a polygon
% Viewpoint is origo
%
% ind=BehindPolygon(p,x)
%
% p:   3D polygon. Atleast 3 points. p(index,1:3) 
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


function behind=BehindPolygon(p,x)

% Align Polygon plane
Xp = p(2,:)-p(1,:); Xp=Xp/norm(Xp);
Yp = p(3,:)-p(2,:); Yp=Yp/norm(Yp);
Zp = cross(Xp,Yp);
Tp = [Xp;Yp;Zp].';
pT = p*Tp; 
xT = x*Tp;

% Z=z0 crossing
z0  = mean(pT(:,3));     % Plane altitude
k   = z0./xT(:,3);       % Relative distance from origo to planepoly vs x
ind = find(k>0&k<1);     % Range criteria
xcT = k(ind).*xT(ind,:); % Intersect points

% 2D intersect
behind      = zeros(size(x,1),1)==1;
behind(ind) = inpolygon(xcT(:,1),xcT(:,2), pT(:,1), pT(:,2));

% figure(100); hold off
% plot3(p(:,1),p(:,2),p(:,3),'go');
% x0=zeros(size(x));
% hold on;
% patch('XData',p(:,1),'YData',p(:,2),'ZData',p(:,3),'FaceAlpha',.5,'FaceColor','g');
% plot3(x(:,1),x(:,2),x(:,3),'k.');
% if 0
% line([x0(:,1),x(:,1)]',[x0(:,2),x(:,2)]',[x0(:,3),x(:,3)]','Color','g');
% end
% line([x0(behind,1),x(behind,1)]',[x0(behind,2),x(behind,2)]',[x0(behind,3),x(behind,3)]','Color','r');
% plot3(x(behind,1),x(behind,2),x(behind,3),'ro');
% drawnow;
% pause(0.1);
% 
