% Define simple building structure
%
% y = BuildingdStructure(corners,bh,matWall,matRoof)
% corners:  Building corner 2D coordinates (ordered clockwise) [m]
% bh:       Building height [m]
% matWall:  Classdef Material handle. For wall atoms
% matRoof:  Classdef Material handle. For roof atoms
% y:        classdef Structure instance
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
function s = BuildingStructure(corners,bh,matWall,matRoof)

N = size(corners,1);
p = [[corners zeros(N,1)];[corners bh+zeros(N,1)]]; % Defining points
for n=1:N
    s{n}.pi   = [n,N+n,N+mod(n,N)+1,mod(n,N)+1]; % Wall surface polygon point index
    s{n}.material = matWall;
    c{n}.pi   = [n,N+n];     % Wall2Wall corner line point index
    c{N+n}.pi = [N+n,N+mod(n,N)+1]; % Wall2Roof corner line point index
    c{n}.si   = [n,mod(n-2,N)+1]; % Wall2Wall 2 corner surface index
    c{N+n}.si = [n,N+1];     % Wall2Roof 2 corner surface index
    c{n}.material   = matWall; % Wall2Wall 2 corner 
    c{N+n}.material = matRoof; %  Wall2Roof 2 corner 
end
s{N+1}.pi = N+(1:N); % Roof surface polygon point index
s{N+1}.material = matRoof; % Roof surface polygon point index
s = Structure(p,s,c,[]);


% y = Atoms;
% 
% % Corners always to be defined clock wise!
% n = 0;
% N = size(corners,1);    % Nrof corners
% beta = 0;
% for ii=0:N-1
%     
%     % Define corners in complex numbers
%     corner1 = corners(mod(ii-1,N)+1,:)*[1;1j];
%     corner2 = corners(mod(ii-0,N)+1,:)*[1;1j];
%     corner3 = corners(mod(ii+1,N)+1,:)*[1;1j];
%       
%     % Build corner @ corner2
%     alfa = angle((corner2-corner1)/(corner3-corner2));
%     beta = beta + alfa;
% end
% if beta<0
%     corners = flipud(corners);
% end
% 
% 
% 
% 
% CC=sqrt(3); % Atom overlap to avoid gaps
% 
% % Adjust resolution to match building if required
% lenWall = vnorm(corners(:,:)-corners([end 1:end-1],:),2);
% corners(find(lenWall<1),:)=[];
% minWall = min(vnorm(corners(:,:)-corners([end 1:end-1],:),2));
% maxWall = max(vnorm(corners(:,:)-corners([end 1:end-1],:),2));
% res = min([res,maxWall/10,minWall/4,bh/3])*CC;
% 
% 
% 
% n = 0;
% N = size(corners,1);    % Nrof corners
% for ii=0:N-1
%     
%     % Define corners in complex numbers
%     corner1 = corners(mod(ii-1,N)+1,:)*[1;1j];
%     corner2 = corners(mod(ii-0,N)+1,:)*[1;1j];
%     corner3 = corners(mod(ii+1,N)+1,:)*[1;1j];
%     
% %     figure(1);
% %     plot([corner1,corner2,corner3],'r-.')
% %     pause(0)
% %     plot([corner1,corner2,corner3],'g-.')
% 
%     % Build wall between corner1 and corner2
%     nw = max(0,ceil((abs(corner2-corner1)-res)/res*CC))+1;
%     dw = (abs(corner2-corner1)-res)/(nw-1);
%     pw = res/2+(0:(nw-1))*dw;
%     dd = (corner2-corner1)/abs(corner2-corner1);
%     ps = corner1+pw*dd;
%     pc = ps-dd*1j*res/2*0.99;
%     
%     %delta2D(n+(1:nrofDelta),1)    = wallDelta;
%     surface2D(n+(1:nw),1)  = ps;
%     center2D(n+(1:nw),1)   = pc; % Center half delta inside surface
%     corner2D(n+(1:nw),1:2) = zeros(nw,2);
%     n=n+nw;
%     
%     
%     % Build corner @ corner2
%     alfa = angle((corner2-corner1)/(corner3-corner2));
%     surface2D(n+1,1) = corner2;
%     center2D(n+1,1)  = corner2+dd*exp(-1j*(alfa/2+pi/2))*res/sqrt(2);
%     corner2D(n+1,1:2)  = [alfa 0]; % Corner!
%     n=n+1;
%     if sum(isnan(center2D(:)))>0
%         warning('Ploink...')        
%         return;
%     end
%    
% end
% 
% % Extend walls entire height of building.
% nh = max(0,ceil((bh-res)/res*CC))+1;
% dh = (bh-res)/(nh-1);
% ph = res/2+(0:nh-1)*dh;
% center   = zeros(0,3);
% surface  = zeros(0,3);
% corner   = zeros(0,2); % Corner opening. Corner orientation (vs z-axis)
% material = [];
% for ih=1:nh
%     center   = [center;   real(center2D)  imag(center2D)  ph(ih)*ones(n,1)];
%     surface  = [surface;  real(surface2D) imag(surface2D) ph(ih)*ones(n,1)];
%     corner   = [corner;   corner2D];
%     material = [material; repmat(matWall,n,1)];
% end
% 
% % Corner vs roof
% ind=find(~corner2D(:,1));
% n=numel(ind);
% center   = [center;   real(center2D(ind))  imag(center2D(ind))  repmat(bh-res/2,n,1)];
% surface  = [surface;  real(surface2D(ind)) imag(surface2D(ind)) repmat(bh,      n,1)];
% corner   = [corner;   repmat(pi/2,n,2)];
% material = [material; repmat(matWall,n,1)];
% 
% % Define 2D structure of roof (or floors)
% corner1 = [min(corners(:,1)),min(corners(:,2))]*[1;1j];
% corner2 = [max(corners(:,1)),max(corners(:,2))]*[1;1j];
% if angle(corner2-corner1)>0 % Roof Box not empty
%     nx = max(0,ceil((real(corner2-corner1)-res)/res*CC));
%     ny = max(0,ceil((imag(corner2-corner1)-res)/res*CC));
%     dx = (real(corner2-corner1)-res)/nx;
%     dy = (imag(corner2-corner1)-res)/ny;
%     [px,py]=meshgrid(res/2+(0:nx)*dx,res/2+(0:ny)*dy);
%     center2Droof = corner1+px(:)+1j*py(:);
%     center2Droof(~InsidePolygon(center2Droof,center2D))=[]; % Remove pts outside Roof Polygon
% end
% 
% % Mount roof on top in 3D
% n = numel(center2Droof);
% center   = [center;   real(center2Droof)  imag(center2Droof)  repmat(bh-res/2,n,1)];
% surface  = [surface;  real(center2Droof)  imag(center2Droof)  repmat(bh      ,n,1)];
% corner   = [corner;   zeros(n,2)];
% material = [material; repmat(matRoof,n,1)];
% 
% 
% % Compose structure
% nAtom = size(center,1);
% y.normal   = surface-center;
% y.surface  = surface;
% y.material = material;
% y.corner   = corner; 
% y.res      = res*ones(nAtom,1);
% 
% 
