% A group of atoms.
% Each atom is defined by:
%   normal:     3D vector perpendicular to atom surface. Length=res/2
%   surface:    3D coordinate of atom surface center
%   material:   instance of classdef Material
%   corner:     2 angles. Corner opening, and corner orientation
%   res:        Atom size (1D: res=corner length, 2D: res^2 = area, 
function y=ShrinkPolygon(corners,ratio)

if nargin<2, ratio=0.9; end

% Surface X
i0=1; p0=corners(i0,:);
i1=2; p1=corners(i1,:);
Xp = p1-p0;
Xp = Xp/norm(Xp);

% Max dist from X axis => Surface Y
[d,t] = DistanceToLine(corners,p0,p1);
[~,i2]=max(d); p2=corners(i2,:);
p3 = p0+t(i2)*(p1-p0);
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
corners = corners*T;
z0 = mean(corners(:,3));
cc = corners([1:end,1],1:2)*[1;1j];


beta=0; res=inf;
N = size(corners,1);
for ii=0:N-1
    % Define corners in complex numbers
    corner1 = corners(mod(ii-1,N)+1,1:2)*[1;1j];
    corner2 = corners(mod(ii-0,N)+1,1:2)*[1;1j];
    corner3 = corners(mod(ii+1,N)+1,1:2)*[1;1j];  
    res  = min(res,abs(corner2-corner1)/2);   
    alfa = angle((corner2-corner1)/(corner3-corner2));
    beta = beta+alfa;
end

if beta<0
    corners=flipud(corners);
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
    center2D(ii+1,1) = corner2+ratio*ddn*exp(-1j*( alfa/2+pi/2))*res/sqrt(2);
    assert(~sum(isnan(center2D(:)))>0,'Ploink...')
   
end

%figure(101);clf; plot(center2D,'g*'); hold on; plot(cc,'r'); axis equal
assert(max(diff(corners(:,3)))<res/100,'Surface not a plane!')

% To 3D (surface coord)
n = numel(center2D);
y = [real(center2D)  imag(center2D)  z0+zeros(n,1)]/T;

