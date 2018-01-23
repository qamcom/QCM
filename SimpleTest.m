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

function SimpleTest

rng(1); % Random seed
addpath(genpath('QCM'));
addpath(genpath('QCM'));

% -------------------------------------------------------------------------
% Setup

% Freq bins
freqs = 28e9+(-60:60)*150e3; % [Hz] One freq bin per per 150kHz


% Antenna array
lambda = sys.c/60e9;
Nv=2; Nh=12; spacingV=0.7; spacingH=0.7;

% Universe size x (EW) & y (NS) [m]
R = [110,110];   % Universe size

% Nrof houses
Nx=4; Ny=4;

% Average building height, and stf dev
bh_mean = 20; bh_std = 5;

% Resolution
resHouse  = 5;  % House tile size
resGround = 5; % Ground tile size

% Materials
matGround   = Material('Street',0); % Ground cannot cast shade.
matWall     = Material('CMU',1);
matRoof     = Material('Wood',1);
matTrunk    = Material('Wood',0);
matFoliage  = Material('Wood',1);


% -------------------------------------------------------------------------
% Start a universe

universe  = Universe('Test');
ground    = GroundStructure(R(1),R(2),resGround,matGround);
universe.AddAtoms('Ground',ground);


% Define var's for point-ov-view:s
ii=1;
dovN  = 90;  %[ 0, 1, 0];  % Direction-of-view vector N
dovE  = 0;   %[ 1, 0, 0];  % Direction-of-view vector E
dovS  = -90; %[ 0,-1, 0];  % Direction-of-view vector S
dovW  = 180; %[-1, 0, 0];  % Direction-of-view vector W
dovNE = 45;  %[ 1,  1, 0]/sqrt(2);  % Direction-of-view vector N
dovSW = -135;%[-1, -1, 0]/sqrt(2);  % Direction-of-view vector E
dovSE = -45; %[ 1, -1, 0]/sqrt(2);  % Direction-of-view vector N
dovNW = 135; %[-1,  1, 0]/sqrt(2);  % Direction-of-view vector E
pol     = pi/4;     % Polarisation (Radians Vs Normal-of-view vector)
dualpol = 1;        % 1 == Also analyze perpendicular polarisation mode

% Get array element coordinates
[hp,vp]   = meshgrid(spacingH*(-(Nh-1)/2:(Nh-1)/2),spacingV*(-(Nv-1)/2:(Nv-1)/2));
elempos   = [hp(:),vp(:)]*lambda; % Array config H,V

% Define element for arrays
element = Element('isotropic');

% Define array
array = Array('SimpleTest',elempos,element,pol);

arrayGroup = ArrayGroup('SimpleTest',{array},[0 0 0],0,0,0,dualpol);

% Buildings
n=0;
for ny=-(Ny-1)/2:(Ny-1)/2,
    for nx=-(Nx-1)/2:(Nx-1)/2,
        n = n+1;
        b0       = 0; % Building ground zero
        bh(n)    = bh_mean+bh_std*randn(1); % Building height
        bx       = 40/Nx;
        by       = 40/Ny;
        corners  = [bx/2*[-1 -1 1 1]' by/2*[-1 1 1 -1]'];
        pos      = [R(1)/2+nx*bx*2 R(2)/2+ny*by*2 b0];
        rot      = 0;
        building = BuildingStructure(corners,bh(n),resHouse,matWall,matRoof);
        universe.AddAtoms(sprintf('Building%d',n),building,pos,rot);
    end
end

% Add tree to universe
tt = TreeStructure([55 55 0],3,13,matTrunk,matFoliage);
universe.AddAtoms(sprintf('Tree%d',1),tt);
tt = TreeStructure([55 10 0],6,13,matTrunk,matFoliage);
universe.AddAtoms(sprintf('Tree%d',2),tt);
tt = TreeStructure([55 100 0],3,13,matTrunk,matFoliage);
universe.AddAtoms(sprintf('Tree%d',3),tt);
tt = TreeStructure([10 55 0],4,14,matTrunk,matFoliage);
universe.AddAtoms(sprintf('Tree%d',4),tt);
tt = TreeStructure([100 55 0],4,11,matTrunk,matFoliage);
universe.AddAtoms(sprintf('Tree%d',5),tt);

x0=cell(0);
x1=cell(0);



% x = PointOfView(tag,agroup,position,elevation,azimuth,velocity)

pov  = [35,15,10]; n=0;
x0{1} = PointOfView(sprintf('%dNE',n),arrayGroup,pov,0,dovNE);

pov  = [75,95,10]; n=n+1;
x1{n} = PointOfView(sprintf('%dSW',n),arrayGroup,pov,0,dovSW);

pov  = [35,95,10]; n=n+1;
x1{n} = PointOfView(sprintf('%dSE',n),arrayGroup,pov,0,dovSE);

pov  = [75,15,10]; n=n+1;
x1{n} = PointOfView(sprintf('%dNW',n),arrayGroup,pov,0,dovNW);

figure(3);
universe.Plot(x0,x1);
pause(0.1)

figure(10);
universe.PlotLOS(x0{1}.position,x1{1}.position);


rain  = 0; % mm/h
channelResponse = universe.Channels(x0,x1,freqs,rain);

figure(20);
universe.Response(x0,x1,freqs,rain);
for ii=1:n
    figure(10+ii); 
    universe.Trace(x0{1},x1{ii},freqs,rain); 
end



