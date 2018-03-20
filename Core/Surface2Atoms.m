% A group of atoms.
% Each atom is defined by:
%   normal:     3D vector perpendicular to atom surface. Length=res/2
%   surface:    3D coordinate of atom surface center
%   material:   instance of classdef Material
%   corner:     2 angles. Corner opening, and corner orientation
%   res:        Atom size (1D: res=corner length, 2D: res^2 = area, 
function y=Surface2Atoms(corners,mat,res)

corners = flipud(corners); % Clockwise!

origo = min(corners);

corners = VectorAdd(corners,-origo);
CC=sqrt(2); % Atom overlap to avoid gaps


% Max diff => Surface X
r = vnorm(corners,2);
[~,i0]=min(r); i0=1; p0=corners(i0,:);
[~,i1]=max(r); i1=2; p1=corners(i1,:);
Xp = p1-p0;
Xp = Xp/norm(Xp);

% Max dist from X axis => Surface Y
[d,t] = DistanceToLine(corners,p0,p1);
[~,i2]=max(d); p2=corners(i2,:);
p3 = p0-t(i2)*(p1-p0);
Yp = p2-p3; 
Yp = Yp/norm(Yp);

% Surface Z
Zp = cross(Xp,Yp);
Zp = Zp/norm(Zp);

% Surface Y
Yp = cross(Zp,Xp);

% Transform matrix
T=[Xp;Yp;Zp].';

% To plane coord system
corners  = corners*T;

cc = corners([1:end,1],1:2)*[1;1j];

N = size(corners,1);
for ii=0:N-1
    % Define corners in complex numbers
    corner1 = corners(mod(ii-1,N)+1,1:2)*[1;1j];
    corner2 = corners(mod(ii-0,N)+1,1:2)*[1;1j];
    res  = min(res,abs(corner2-corner1)/2);   
end

% Define smaller polygon to bound grid centers
for ii=0:N-1
    
    % Define corners in complex numbers
    corner1 = corners(mod(ii-1,N)+1,1:2)*[1;1j];
    corner2 = corners(mod(ii-0,N)+1,1:2)*[1;1j];
    corner3 = corners(mod(ii+1,N)+1,1:2)*[1;1j];  

    dd  = (corner2-corner1);
    ddn = dd/abs(dd);
    alfa = angle((corner2-corner1)/(corner3-corner2));
    center2D(ii+1,1) = corner2+0.9*ddn*exp(-1j*(alfa/2+pi/2))*res/sqrt(2);
    assert(~sum(isnan(center2D(:)))>0,'Ploink...')
   
end

assert(max(diff(corners(:,3)))<res/100,'Surface not a plane!')


% Define 2D structure 
corner1 = [min(corners(:,1)),min(corners(:,2))]*[1;1j];
corner2 = [max(corners(:,1)),max(corners(:,2))]*[1;1j];
if angle(corner2-corner1)>0 % Roof Box not empty
    nx = max(0,ceil((real(corner2-corner1)-res)/res*CC));
    ny = max(0,ceil((imag(corner2-corner1)-res)/res*CC));
    dx = (real(corner2-corner1)-res)/nx;
    dy = (imag(corner2-corner1)-res)/ny;
    [px,py]=meshgrid(res/2+(0:nx)*dx,res/2+(0:ny)*dy);
    center2Droof = corner1+px(:)+1j*py(:);
    center2Droof(~InsidePolygon(center2Droof,center2D))=[]; % Remove pts outside Roof Polygon
end

% clf; hold on;
% plot(center2Droof,'.')
% plot(center2D    ,'r*')
% plot(cc,'k')
% axis equal
% 
% To 3D (surface coord)
n = numel(center2Droof);
center   = [real(center2Droof)  imag(center2Droof)  -ones(n,1)];
surface  = [real(center2Droof)  imag(center2Droof)  zeros(n,1)];
normal   = surface-center;
corner   = zeros(n,2);
material = repmat(mat,n,1);

% Compose structure. Global coord
nAtom = size(center,1);
y = Atoms;
y.normal   = normal/T;
y.surface  = surface/T+origo;
y.material = material;
y.corner   = corner; 
y.res      = res*ones(nAtom,1);













