% Generate a groove of trees
% tt = PlantTrees(corners,hh,hs,h0,matTrunk,matFoliage,fig)
%
% corners   corners of polygon enclosing groove
% hh        mean tree height 
% hs        std tree height 
% h0        groove ground level
% matTrunk
% matFoliage
% fig      
%
% tt        Atoms class instance
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
function tt = PlantTrees(corners,hh,hs,h0,matTrunk,matFoliage,fig)
D2H = 2/3;
CC  = 3;

c = corners*[1;1j];

c0 = c;
ind = min(find(isnan(c)));
if ~isempty(ind), c0 = c(1:ind-1); end; % Keep outer shape only
pos = mean(c0)*0;
c = c-pos;


center2D=[];
corner1 = complex(min(real(c0)),min(imag(c0)));
corner2 = complex(max(real(c0)),max(imag(c0)));
%if angle(corner2-corner1)>0 % Groove not empty
    nx = max(0,ceil((real(corner2-corner1))/hh*CC));
    ny = max(0,ceil((imag(corner2-corner1))/hh*CC));
    dx = (real(corner2-corner1))/nx;
    dy = (imag(corner2-corner1))/ny;
    [px,py]=meshgrid((0:nx)*dx,(0:ny)*dy);
    px = px+randn(size(px))*hh/30;
    py = py+randn(size(py))*hh/30;
    center2D  = corner1+px(:)+1j*py(:);
    center2Di = center2D(InsidePolygon(center2D,c+pos));
%end
if numel(center2Di)<2, center2Di=mean(c0); end;

% figure(33); clf;
% hold on;
% plot(c+pos,'g')
% plot(center2D,'m.')
% plot(center2Di,'mo')
% axis equal

if exist('fig','var') && fig==1 
    [xx,yy,zz]=sphere(5);
    hold on;
    for ii=1:numel(center2Di)
        cc   =center2Di(ii);
        h(ii,1)=hh+randn(1)*hs;
        r(ii,1)=h(ii)*D2H/2;
        ss=surf(xx*r(ii)+real(cc+pos),yy*r(ii)+imag(cc+pos),(zz-1)*r(ii)+h(ii),23*ones(size(xx)));
        ss.FaceAlpha=0.5;
        plot3(real(cc+pos)+[0 0],imag(cc+pos)+[0 0],[0,h(ii)-r(ii)],'k.-','LineWidth',4)
    end
else
    for ii=1:numel(center2Di)
        h(ii,1)=hh+randn(1)*hs;
        r(ii,1)=h(ii)*D2H/2;
    end
end
%axis equal

p(:,1) = real(pos+center2Di);
p(:,2) = imag(pos+center2Di);
p(:,3) = h0;

                
                
                rng(rng0);
                nn = nn+numel(r);
                
                % Add tree to universe
                tt = TreeStructure(p,r,h,matTrunk,matFoliage);
