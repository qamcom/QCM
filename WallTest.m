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

function WallTest

rng(1); % Random seed
addpath(genpath('./'));

Nit = 30;
RR  = ([5 10 20]);
rr  = [2,4,8];

% Freq bins
freqs = 60e9; % [Hz] One freq bin per per 150kHz

% Antenna array
lambda = sys.c/60e9;
Nv=1; Nh=1; spacingV=0.7; spacingH=0.7;
element = Element('horn11');

% Get array coordinates
[xp,yp]=meshgrid(spacingV*(-(Nv-1)/2:(Nv-1)/2),spacingH*(-(Nh-1)/2:(Nh-1)/2));
elempos = [xp(:),yp(:)]*lambda; % Array config H,V

pol     = pi/2;     % Polarisation (Radians Vs Normal-of-view vector)
dualpol = 0;        % 1 == Also analyze perpendicular polarisation mode
array   = Array('Horn11',elempos,element,pol);

antSys = AntennaSystem('Horn11',{array},[0 0 0],0,0,0,dualpol);




% Materials
matGround = GenericMaterial('CMU',1);

rain  = 0; % mm/h

% Distance
for ir = 1:numel(rr)
    
    resGround = rr(ir); % Ground tile size
    
    figure(ir); clf;
    
    % Resolution
    pp=0;
    for iR  = 1:numel(RR)
        
        R=RR(iR)*resGround/min(resGround);
        WALLSIZE = max(R*4,resGround*10);
        
        pp=pp+1;
        
        PP=[];
        for it=1:Nit
            
            
            
            
            % -------------------------------------------------------------------------
            % Setup without screen
            
            a1 = pi;
            e1 = pi/2;
            a0 = 0;
            e0 = pi/2;
            
            
            % Start a universe
            universe  = Universe('Test');
            
            clear x0;
            clear x1;
            
            rng(it);
            origo = VectorAdd([WALLSIZE/2 WALLSIZE/2 0],resGround*rand(1,3).*[1,1,0]);
            
            pov1  = Cartesian3D([R,e1,a1]);
            pov1  = VectorAdd(pov1,origo);
            
            pov0  = Cartesian3D([R,e0,a0]);
            pov0  = VectorAdd(pov0,origo);
      
            
            % Define var's for point-ov-view:s
            % x = PointOfView(tag,agroup,position,elevation,azimuth)
            x1 = PointOfView('TX',antSys,pov1,0,0);
            x0 = PointOfView('RX',antSys,pov0,0,pi);
            
%             figure(2); clf;
%             universe.Plot(x0,x1);
%             axis equal;
%             pause(0.1)
% %             
            
            times = 0;
            link = universe.Channel(x0,x1,freqs,times,rain);
            P0 = link.P;
            
            
            % -------------------------------------------------------------------------
            % Setup with screen
            universe.delete;
            
            a1 = pi;
            e1 = pi/4;
            A0 = 0;%[-pi/2:pi/10:pi/2];
            E0 = [0:pi/128:pi/2];
            
            
            % Start a universe
            universe  = Universe('Test');
            ground    = GroundStructure(WALLSIZE,WALLSIZE,resGround,matGround);
            universe.AddAtoms('Ground',ground);
            
            
            
            
            clear x0;
            clear x1;
            pov1  = Cartesian3D([R,e1,a1]);
            pov1  = VectorAdd(pov1,origo);
            x1{1} = PointOfView('TX',antSys,pov1,-e1,0);
            nn=0;
            for en0=1:numel(E0)
                for an0=1:numel(A0)
                    e0=E0(en0);
                    a0=A0(an0);
                    nn=nn+1;
                    % Define var's for point-ov-view:s
                    pov0  = Cartesian3D([R,e0,a0]);
                    pov0  = VectorAdd(pov0,origo);
                    x0{en0,an0} = PointOfView('RX',antSys,pov0,-e0-pi/2,0);
                end
            end
            
%             figure(3); clf;
%             universe.Plot(x0,x1);
%             axis equal;
%             pause(0.1)
            
            % figure(10);
            % universe.PlotLOS(x0{1}.pov,x1{1}.pov);
            
            
            rain  = 0; % mm/h
            
            for en0=1:numel(E0)
                for an0=1:numel(A0)
                    link = universe.Channel(x0{en0,an0},x1{1},freqs,times,rain);
                    PP(en0,an0,it) = link.P;
                end
            end
            
        end
        
        PPP(ir,iR)=10*log10(mean(10.^((PP(:)-P0)/10)));
        figure(ir);
        subplot(1,numel(RR),pp)
        plot(E0/pi*180,PP(:,:)-P0,'r.')
        PPa = 10*log10(mean(10.^((PP-P0)/10),3));
        hold on; plot(E0/pi*180,PPa,'g'), hold off;
        title(sprintf('res=%.2fm R=%dm',resGround,R));
        axis([0 90 -60 10])
        hold on;
        
        
        pause(2);
        
    end
end