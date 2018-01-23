% Define atoms for a simple building structure
%
% y = BuildingdStructure2(corners,bh,res,matWall,matRoof)
% bw:       Building width (short wall N/S direction) [m]
% bd:       Building depth (long wall E/W direction) [m]
% bh:       Building body height upto roof [m]
% rh:       Building roof height (total height = bh+rh) [m]
% res:      Ground tile size / resolution [m]
% matWall:  Classdef Material handle. For wall atoms
% matRoof:  Classdef Material handle. For roof atoms
% y:        classdef Atoms instance
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
function y=BuildingStructure2(bw,bd,bh,rh,res,matWall,matRoof)

y = Atoms;
CC=sqrt(2);

% 2 // N-S walls incl roof triangles
resxx = min([bh/2,rh/2,bw/2,res]);
nw = max(0,ceil((bw   -resxx)/resxx*CC))+1;
nh = max(0,ceil((bh+rh-resxx)/resxx*CC))+1;
dw = ((bw   -resxx))/(nw-1);
dh = ((bh+rh-resxx))/(nh-1);
xx = -bw/2+ resxx/2 + (0:(nw-1))*dw;
zz =        resxx/2 + (0:(nh-1))*dh;

[xx,zz]=meshgrid(xx,zz); MM=2.1;
wallpoly = [-bw/2+resxx/MM,0; -bw/2+resxx/MM,bh; 0,bh+rh-resxx/MM; bw/2-resxx/MM,bh; bw/2-resxx/MM,0;-bw/2+resxx/MM,0];
inside = InsidePolygon([xx(:),zz(:)],wallpoly);
xx=xx(inside);
zz=zz(inside);
Nxx = numel(xx);

y.surface = [xx(:), bd/2*ones(Nxx,1),zz(:)];
y.normal  = repmat([0 1 0]*resxx/2,Nxx,1);

y.surface = [y.surface;[xx(:),-bd/2*ones(Nxx,1),zz(:)]];
y.normal  = [y.normal; repmat([0 -1 0]*resxx/2,Nxx,1)];

y.res     = [y.res;    resxx*ones(Nxx*2,1)];
y.corner  = [y.corner; zeros(Nxx*2,2)];
y.material= [y.material; repmat(matWall,Nxx*2,1)];

% 2 // E-W walls
resyy = min([bh/2,bd/2,res]);
nd = max(0,ceil((bd-resyy)/resyy*CC))+1;
nh = max(0,ceil((bh-resyy)/resyy*CC))+1;
dd = ((bd-resyy))/(nd-1);
dh = ((bh-resyy))/(nh-1);
yy = -bd/2+ resyy/2 + (0:(nd-1))*dd;
zz =        resyy/2 + (0:(nh-1))*dh;

[yy,zz]=meshgrid(yy,zz);
Nyy = numel(yy);
y.surface = [y.surface;[ bw/2*ones(Nyy,1),yy(:), zz(:)]];
y.normal  = [y.normal; repmat([ 1 0 0]*resyy/2,Nyy,1)];
y.surface = [y.surface;[-bw/2*ones(Nyy,1),yy(:), zz(:)]];
y.normal  = [y.normal; repmat([-1 0 0]*resyy/2,Nyy,1)];
y.res     = [y.res;    resyy*ones(Nyy*2,1)];
y.corner  = [y.corner; zeros(Nyy*2,2)];
y.material= [y.material; repmat(matWall,Nyy*2,1)];



% Vertical corners
reszz = min([bh/2,res]);
nh = ceil(bh/reszz);
zz = reszz/2+(0:(nh-1))*(bh-reszz)/(nh-1);
% NE corner
y.surface = [y.surface;[ bw/2*ones(nh,1),bd/2*ones(nh,1), zz(:)]];
y.normal  = [y.normal;repmat([ 1 1 0]/sqrt(2)*reszz/2,nh,1)];
% SE corner
y.surface = [y.surface;[ bw/2*ones(nh,1),-bd/2*ones(nh,1), zz(:)]];
y.normal  = [y.normal;repmat([ 1 -1 0]/sqrt(2)*reszz/2,nh,1)];
% SW corner
y.surface = [y.surface;[-bw/2*ones(nh,1),-bd/2*ones(nh,1), zz(:)]];
y.normal  = [y.normal;repmat([-1 -1 0]/sqrt(2)*reszz/2,nh,1)];
% NW corner
y.surface = [y.surface;[-bw/2*ones(nh,1), bd/2*ones(nh,1), zz(:)]];
y.normal  = [y.normal;repmat([-1  1 0]/sqrt(2)*reszz/2,nh,1)];
y.res     = [y.res;    reszz*ones(nh*4,1)];
y.corner  = [y.corner; repmat([pi/2,0],4*nh,1)];
y.material= [y.material; repmat(matWall,nh*4,1)];

% Slanted roof E&W
rs = hypot(bw/2,rh);
an = angle(complex(rh,bw/2));
resss = min([rs/2,bd/2,res]);
nd = ceil(bd/resss*CC);
ns = ceil(rs/resss*CC);
rr = (resss/2+(0:(ns-1))*(rs-resss)/(ns-1));
xx = rr(end:-1:1)*sin(an);
zz = rr*cos(an);
yy = -bd/2+resss/2+(0:(nd-1))*(bd-resss)/(nd-1);
[xx,yy]=meshgrid(xx,yy);
zz = repmat(zz,nd,1);
Nss = numel(xx);

% E side
nnE = [rh,0,bw/2]; nnE=nnE/norm(nnE)*resss/2;
y.surface = [y.surface;[xx(:),yy(:),bh+zz(:)]];
y.normal  = [y.normal; repmat(nnE,Nss,1)];

% W side
nnW = [-rh,0,bw/2]; nnW=nnW/norm(nnW)*resss/2;
y.surface = [y.surface;[-xx(:),yy(:),bh+zz(:)]];
y.normal  = [y.normal; repmat(nnW,Nss,1)];

y.res     = [y.res;    resss*ones(Nss*2,1)];
y.corner  = [y.corner; zeros(Nss*2,2)];
y.material= [y.material; repmat(matRoof,Nss*2,1)];


% Corners vs slanted roof
resyy = min([bd/2,res]);
ny = ceil(bd/resyy);
yy = -bd/2+resyy/2+(0:(ny-1))*(bd-resyy)/(ny-1);
an = angle(complex(rh,bw/2));
% E side
nnE = [-cos(an/2),0,sin(an/2)]*resyy/2;
y.surface = [y.surface;[-bw/2*ones(ny,1),yy(:),bh*ones(ny,1)]];
y.normal  = [y.normal; repmat(nnE,ny,1)];
nnW = [ cos(an/2),0,sin(an/2)]*resyy/2;
y.surface = [y.surface;[ bw/2*ones(ny,1),yy(:),bh*ones(ny,1)]];
y.normal  = [y.normal; repmat(nnW,ny,1)];
y.res     = [y.res;    resyy*ones(ny*2,1)];
y.corner  = [y.corner; repmat([an,pi/2],ny*2,1)];
y.material= [y.material; repmat(matRoof,ny*2,1)];

% Roof triangle corners
rs = hypot(rh,bw/2);
an = angle(complex(rh,bw/2));
resxx = min([rs/2,res]);
nx = ceil(rs/resxx);
rr = resxx/2+(0:(nx-1))*(rs-resxx)/(nx-1);
xx = rr(end:-1:1)*sin(an);
zz = bh+rr*cos(an);
nnE = [ cos(an),0,sin(an)]*resxx/2;
ccE = [-sin(an),0,cos(an)];
nnSE = RotateAroundAxis(nnE,ccE,-pi/4);
nnNE = RotateAroundAxis(nnE,ccE, pi/4);
ccW = [ sin(an),0,cos(an)];
nnW = [-cos(an),0,sin(an)]*resxx/2;
nnSW = RotateAroundAxis(nnW,ccW, pi/4);
nnNW = RotateAroundAxis(nnW,ccW,-pi/4);

% S/W side
y.surface = [y.surface;[-xx(:),-bd/2*ones(nx,1),zz(:)]];
y.normal  = [y.normal; repmat(nnSW,nx,1)];
ac = Line2Corner(ccW,nnSW);
y.corner  = [y.corner; repmat([pi/2,ac],nx,1)];
% N/W side
y.surface = [y.surface;[-xx(:),bd/2*ones(nx,1),zz(:)]];
y.normal  = [y.normal; repmat(nnNW,nx,1)];
ac = Line2Corner(ccW,nnNW);
y.corner  = [y.corner; repmat([pi/2,ac],nx,1)];
% S/E side
y.surface = [y.surface;[xx(:),-bd/2*ones(nx,1),zz(:)]];
y.normal  = [y.normal; repmat(nnSE,nx,1)];
ac = Line2Corner(ccE,nnSE);
y.corner  = [y.corner; repmat([pi/2,ac],nx,1)];
% N/E side
y.surface = [y.surface;[xx(:),bd/2*ones(nx,1),zz(:)]];
y.normal  = [y.normal; repmat(nnNE,nx,1)];
ac = Line2Corner(ccE,nnNE);
y.corner  = [y.corner; repmat([pi/2,ac],nx,1)];
y.res     = [y.res;    resxx*ones(nx*4,1)];
y.material= [y.material; repmat(matRoof,nx*4,1)];

% Top corner
resyy = min([bd/2,res]);
ny = ceil(bd/resyy);
an = atan(rh/(bw/2));
cc = [1 0 0];
nn = [1e-10 0 1]*resyy/2;
ac = Line2Corner(cc,nn);
yy = -bd/2+resyy/2+(0:(ny-1))*(bd-resyy)/(ny-1);
y.surface = [y.surface;  [zeros(ny,1),yy(:),(bh+rh)*ones(ny,1)]];
y.normal  = [y.normal;   repmat(nn,ny,1)];
y.res     = [y.res;      resyy*ones(ny,1)];
y.corner  = [y.corner;   repmat([2*an,ac+pi/2],ny,1)];
y.material= [y.material; repmat(matRoof,ny,1)];


% figure(1), clf;
% hold on;
% ind = find(y.corner(:,1)==0);
% for ii=ind(:)'
%     plot3(y.surface(ii,1),y.surface(ii,2),y.surface(ii,3),'r*')
%     plot3(y.surface(ii,1)+[0,y.normal(ii,1)],y.surface(ii,2)+[0,y.normal(ii,2)],y.surface(ii,3)+[0,y.normal(ii,3)],'r.:')
% end
% ind = find(y.corner(:,1)~=0);
% for ii=ind(:)'
%     plot3(y.surface(ii,1),y.surface(ii,2),y.surface(ii,3),'g*')
%     plot3(y.surface(ii,1)+[0,y.normal(ii,1)],y.surface(ii,2)+[0,y.normal(ii,2)],y.surface(ii,3)+[0,y.normal(ii,3)],'g.:')
% end
% xlabel('X'); ylabel('Y'), zlabel('Z');
% axis equal
% pause(0);
