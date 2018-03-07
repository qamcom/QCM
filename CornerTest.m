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

function CornerTest

rng(1); % Random seed
addpath(genpath('./'));

Nit = 1;
RR  = ([5 10 20]);
rr  = [2,4,8];

% Freq bins
freqs = 60e9+(-10:10)*1e6; % [Hz]

% Antenna array
lambda = sys.c/60e9;
Nv=1; Nh=1; spacingV=0.7; spacingH=0.7;

% Get array coordinates
[xp,yp]=meshgrid(spacingV*(-(Nv-1)/2:(Nv-1)/2),spacingH*(-(Nh-1)/2:(Nh-1)/2));
elempos = [xp(:),yp(:)]*lambda; % Array config H,V

pol     = pi/2;     % Polarisation (Radians Vs Normal-of-view vector)
dualpol = 0;        % 1 == Also analyze perpendicular polarisation mode

antSysRX = AntennaSystem('RX',{Array('RX',elempos,Element('isotropic'),pol)},   [0 0 0],0,0,0,dualpol);
antSysTX = AntennaSystem('TX',{Array('TX',elempos,Element('isotropic'),pol)},[0 0 0],0,0,0,dualpol);




% Materials
matGround = GenericMaterial('CMU',1);


% Distance
for ir = 1:numel(rr)
    
    resGround = rr(ir); % Ground tile size
    
    figure(ir); clf;
    
    % Resolution
    pp=0;
    for iR  = 1:numel(RR)
        
        R=RR(iR)*resGround/min(rr);
        WALLSIZE = max(R*4,resGround*10);
        
        pp=pp+1;
        
        PP=[];
        for it=1:Nit
            
            
            
            
            % -------------------------------------------------------------------------
            % Setup without screen
            
            a1 = 0;
            e1 = pi;
            a0 = 0;
            e0 = 0;
            
            
            % Start a universe
            universe0  = Universe('Test');
            
            clear x0;
            clear x1;
            
            rng(it);
            
            origo = VectorAdd([0,WALLSIZE/2 0],0*resGround*rand(1,3).*[0,1,0]);
%             
%             pov1  = Cartesian3D([R,e1,a1]);
%             pov1  = VectorAdd(pov1,origo);
%             
%             pov0  = Cartesian3D([R,e0,a0]);
%             pov0  = VectorAdd(pov0,origo);
%             
%             
%             % Define var's for point-ov-view:s
%             % x = PointOfView(tag,agroup,position,elevation,azimuth)
%             x1 = PointOfView('TX',antSysTX,pov1, pi/2,0);
%             x0 = PointOfView('RX',antSysRX,pov0,-pi/2,0);
%             
%             %             figure(2); clf;
%             %             universe.Plot({x0 x1});
%             %             axis equal;
%             %             pause(0.1)
%             %
%             
             times = 0; rain=0;
%             link = universe.Channel(x0,x1,freqs,times,rain);
%             P0 = link.P
%             
%             
%             % -------------------------------------------------------------------------
%             % Setup with screen
%             universe.delete;
            
            
            
            % Start a universe
            universe  = Universe('Test');
            ground    = GroundStructure(WALLSIZE,WALLSIZE,resGround,matGround);
            universe.AddAtoms('Screen',ground);
            
            cc = Atoms;
            nh = 1;%floor(WALLSIZE/resGround/2)*2+1;
            yy = WALLSIZE/2;%resGround/2+(0:(nh-1))*(WALLSIZE-resGround)/(nh-1);
            
            cc.surface = [ zeros(nh,1),       yy(:), zeros(nh,1)];
            cc.normal  = [ -ones(nh,1), zeros(nh,1), zeros(nh,1)];
            cc.res     = resGround*ones(nh,1);
            cc.corner  = repmat([pi,pi/2],nh,1);
            cc.material= repmat(matGround,nh,1);
            universe.AddAtoms('Edge',cc);
            
            
            
            a1 = 0;
            e1 = pi;
            A0 = -pi/2:pi/16:pi/2;
            E0 = -pi/2:pi/356:pi/2;
            
            
            clear x0;
            clear x1;
            pov1  = Cartesian3D([R,e1,a1]);
            pov1  = VectorAdd(pov1,origo);
            x1{1} = PointOfView('TX',antSysTX,pov1,-e1-pi/2,0);
            nn=0;
            for en0=1:numel(E0)
                for an0=1:numel(A0)
                    e0=E0(en0);
                    a0=A0(an0);
                    nn=nn+1;
                    % Define var's for point-ov-view:s
                    pov0  = Cartesian3D([R,e0,a0]);
                    pov0  = VectorAdd(pov0,origo);
                    x0{en0,an0} = PointOfView(sprintf('RX-e%d-a%d',en0,an0),antSysRX,pov0,-e0-pi/2,a0);
                end
            end
            
            figure(3); clf;
            universe.Plot(x0,x1);
            axis equal;
            pause(0.1)
            
            % figure(10);
            % universe.PlotLOS(x0{1}.pov,x1{1}.pov);
            
            
            rain  = 0; % mm/h
            
            for en0=1:numel(E0)
                for an0=1:numel(A0)
                    link0 = universe0.Channel(x0{en0,an0},x1{1},freqs,times,rain);
                    link  = universe.Channel(x0{en0,an0},x1{1},freqs,times,rain);
                    PP(en0,an0,it) = link.P-link0.P;
                end
            end
            
        end
        figure(100); clf;
        E0deg = E0/pi*180;
        A0deg = A0/pi*180;
        PdB = 10*log10(mean(10.^(PP/10),3));
        imagesc('XData',A0deg,'YData',E0deg,'CData',PdB)
        colorbar
        ylabel('Elevation deg')
        xlabel('Azimuth deg')
        
        pause(2);
        
    end
end

