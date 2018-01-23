% Define atoms for a simple building structure
%
% y = BuildingdStructure(corners,bh,res,matWall,matRoof)
% corners:  Building corner 2D coordinates (ordered clockwise) [m]
% bh:       Building height [m]
% res:      Tile size / resolution [m]
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
function y=BuildingStructure(corners,bh,res,matWall,matRoof)

% Corners always defined clock wise!
N = size(corners,1);    % Nrof corners
n = 0;

CC=sqrt(3); % Atom overlap to avoid gaps

% Adjust resolution to match building if required
minWall = min(vnorm(corners(:,:)-corners([end 1:end-1],:),2));
res = min([res,minWall/3,bh/3])*CC;

% Define 2D structure of walls
for ii=0:N-1,
    
    % Define corners in complex numbers
    corner1 = corners(mod(ii-1,N)+1,:)*[1;1j];
    corner2 = corners(mod(ii-0,N)+1,:)*[1;1j];
    corner3 = corners(mod(ii+1,N)+1,:)*[1;1j];
    
%     figure(1);
%     plot([corner1,corner2,corner3],'r-.')
%     pause(0)
%     plot([corner1,corner2,corner3],'g-.')

    % Build wall between corner1 and corner2
    nw = max(0,ceil((abs(corner2-corner1)-res)/res*CC))+1;
    dw = (abs(corner2-corner1)-res)/(nw-1);
    pw = res/2+(0:(nw-1))*dw;
    dd = (corner2-corner1)/abs(corner2-corner1);
    ps = corner1+pw*dd;
    pc = ps-dd*1j*res/2*0.99;
    
    %delta2D(n+(1:nrofDelta),1)    = wallDelta;
    surface2D(n+(1:nw),1)  = ps;
    center2D(n+(1:nw),1)   = pc; % Center half delta inside surface
    corner2D(n+(1:nw),1:2) = zeros(nw,2);
    n=n+nw;
    
    
    % Build corner @ corner2
    alfa = angle((corner2-corner1)/(corner3-corner2));
    surface2D(n+1,1) = corner2;
    center2D(n+1,1)  = corner2+dd*exp(-1j*(alfa/2+pi/2))*res/sqrt(2);
    corner2D(n+1,1:2)  = [alfa 0]; % Corner!
    n=n+1;
    assert(~sum(isnan(center2D(:)))>0,'Ploink...')
   
end

% Extend walls entire height of building.
nh = max(0,ceil((bh-res)/res*CC))+1;
dh = (bh-res)/(nh-1);
ph = res/2+(0:nh-1)*dh;
center   = zeros(0,3);
surface  = zeros(0,3);
corner   = zeros(0,2); % Corner opening. Corner orientation (vs z-axis)
material = [];
for ih=1:nh
    center   = [center;   real(center2D)  imag(center2D)  ph(ih)*ones(n,1)];
    surface  = [surface;  real(surface2D) imag(surface2D) ph(ih)*ones(n,1)];
    corner   = [corner;   corner2D];
    material = [material; repmat(matWall,n,1)];
end

% Corner vs roof
ind=find(~corner2D(:,1));
n=numel(ind);
center   = [center;   real(center2D(ind))  imag(center2D(ind))  repmat(bh-res/2,n,1)];
surface  = [surface;  real(surface2D(ind)) imag(surface2D(ind)) repmat(bh,      n,1)];
corner   = [corner;   repmat(pi/2,n,2)];
material = [material; repmat(matWall,n,1)];

% Define 2D structure of roof (or floors)
corner1 = [min(corners(:,1)),min(corners(:,2))]*[1;1j];
corner2 = [max(corners(:,1)),max(corners(:,2))]*[1;1j];
if angle(corner2-corner1)>0 % Roof Box not empty
    nx = max(0,ceil((real(corner2-corner1)-res)/res*CC));
    ny = max(0,ceil((imag(corner2-corner1)-res)/res*CC));
    dx = (real(corner2-corner1)-res)/nx;
    dy = (imag(corner2-corner1)-res)/ny;
    [px,py]=meshgrid(res/2+(0:nx)*dx,res/2+(0:ny)*dy);
    center2Droof = corner1+px(:)+1j*py(:);
    center2Droof(~InsidePolygon(center2Droof,center2D))=[]; % Remove pts outside Roof Box
end

% Mount roof on top in 3D
n = numel(center2Droof);
center   = [center;   real(center2Droof)  imag(center2Droof)  repmat(bh-res/2,n,1)];
surface  = [surface;  real(center2Droof)  imag(center2Droof)  repmat(bh      ,n,1)];
corner   = [corner;   zeros(n,2)];
material = [material; repmat(matRoof,n,1)];


% Compose structure
nAtom = size(center,1);
y = Atoms;
y.normal   = surface-center;
y.surface  = surface;
y.material = material;
y.corner   = corner; 
y.res      = res*ones(nAtom,1);


