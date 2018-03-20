rng(2);

scenario = 2; % 1 or 2


% METIS Madrid Grid
B = [9 423 0 129 543 52.5;...
    9 285 0 129 405 49;...
    9 147 0 129 267 42;...
    9 9 0 129 129 45.5;...
    147 423 0 267 543 31.5;...
    147 147 0 267 267 52.5;...
    147 9 0 267 129 28;...
    297 423 0 327 543 31.5;...
    297 285 0 327 405 45.5;...
    297 147 0 327 267 38.5;...
    297 9 0 327 129 42;...
    348 423 0 378 543 45.5;...
    348 285 0 378 405 49;...
    348 147 0 378 267 38.5;...
    348 9 0 378 129 42];

R     = [387,552];   % Universe size



resHouse  = 10;  % House tile size
resGround = 10; % Ground tile size


%--------------------------------------------------------------------------
% Materials
matGround   = GenericMaterial('Street',0); % Ground cannot cast shade.
matWall     = GenericMaterial('CMU',1);
matRoof     = GenericMaterial('Wood',1);
matTrunk    = GenericMaterial('Wood',0);
matFoliage  = ScatteringMaterial('Foliage',-10);


% Start a universe, add ground tiles
u  = Universe('MadridGrid','hata-urban-largecity');
ground    = GroundStructure(R(1),R(2),resGround,matGround);
u.AddAtoms('Ground',ground);


% Add buildings
for n=1:size(B,1)
    
    corners = [0 0; 0 B(n,5)-B(n,2); B(n,4)-B(n,1) B(n,5)-B(n,2); B(n,4)-B(n,1) 0];
    corners(:,1) = corners(:,1)-corners(1,1);
    corners(:,2) = corners(:,2)-corners(1,2);
    bpos    = B(n,1:3);
    bh      = B(n,6)-B(n,3);
    
    % Define atoms for a simple building structure
    %
    % y = BuildingdStructure(corners,bh,res,matWall,matRoof)
    % corners:  Building corner 2D coordinates (ordered clockwise) [m]
    % bh:       Building height [m]
    % res:      Ground tile size / resolution [m]
    % matWall:  Classdef Material handle. For wall atoms
    % matRoof:  Classdef Material handle. For roof atoms
    % y:        classdef Atoms instance
    bb = BuildingStructure(corners,bh,resHouse,matWall,matRoof);
    
    % Adds Atoms to Universe
    %
    % u.AddAtoms(tag,x,pos,rot)
    % u is an handle to a Universe class (this class)
    % tag is just a text string to label this structure in Universe
    % x is an instance of classdef Atoms
    % pos (optional) is a 3D ccordinate for translating structure into Universe
    % rot (optional) is a azimuth rotation angle ro rotate structure into Universe
    u.AddAtoms(sprintf('Building%d',n),bb,bpos,0);
    
    
end

x0=cell(0);
x1=cell(0);
switch scenario
    case 1
        freq = 3.5e9+(-50:50)*15e3*12;%6e9+(10:10)*5e6;
        %freq = 3.5e9+(-200:200)*1; % 10Hz grid to see doppler spread
        
        pol      = pi/4;     % Polarisation (Radians Vs Normal-of-view vector)
        dualpol  = 1;     % 1 == Also analyze perpendicular polarisation mode
        ueElement  = Element('isotropic');
        ueAnt      = Array('UE',[0 0],ueElement,pol);
        ueAntsys   = AntennaSystem('UE',{ueAnt ueAnt},[0 0 0;0 1 0],[0 0],[0 0],[0 0],dualpol);
        
        dd=50;
        n=0;
        z=2;
        y=276;
        speed = 30; % [m/s]
        for x=[(1:dd:(340-dd/2)) 340]
            n=n+1;
            % x = PointOfView(tag,agroup,position,elevation,azimuth,velocity)
            x0{n} = PointOfView(sprintf('UE%d',n),ueAntsys,[x,y,z],0,0,[1,0,0]*speed);
        end
        for y=[(276:dd:(410-dd/2)) 410]
            n=n+1;
            % x = PointOfView(tag,agroup,position,elevation,azimuth,velocity)
            x0{n} = PointOfView(sprintf('UE%d',n),ueAntsys,[x,y,z],0,0,[0,1,0]*speed);
        end
        for x=[(340-dd:-dd:(250+dd/2)) 250]
            n=n+1;
            % x = PointOfView(tag,agroup,position,elevation,azimuth,velocity)
            x0{n} = PointOfView(sprintf('UE%d',n),ueAntsys,[x,y,z],0,0,[-1,0,0]*speed);
        end
        for xy=[(dd:dd:(100-dd/2)) 100]
            n=n+1;
            % x = PointOfView(tag,agroup,position,elevation,azimuth,velocity)
            x0{n} = PointOfView(sprintf('UE%d',n),ueAntsys,[x-xy,y-xy,z],0,0,[-1,-1,0]/sqrt(2)*speed);
        end
        inds = 1:length(x0);
        UNdPos = (inds'-1)*dd;
        
        % Define BTS positions
        la = [131  340 51];
        btsAntsys = DistArray(mean(freq),30); % QuadArray(mean(freq),30);
        
        bb=[];%zeros(1,numel(freq)); bb(round(numel(freq)/2))=1;
        
    case 2
        freq = 3.5e9;
        
        pol      = pi/4;     % Polarisation (Radians Vs Normal-of-view vector)
        dualpol  = 0;     % 1 == Also analyze perpendicular polarisation mode
        ueElement  = Element('isotropic');
        ueAnt      = Array('UE',[0 0],ueElement,pol);
        ueAntsys   = AntennaSystem('UE',{ueAnt},[0 0 0],[0],[0],[0],dualpol);
        
        % Define UE positions
        nUNd = 10000;
        UNdPos = [linspace(9,387,nUNd).' 276*ones(nUNd,1) 10*ones(nUNd,1)];
        
        inds = 1:nUNd;
        for n=1:numel(inds)
            ind = inds(n);
            % x = PointOfView(tag,agroup,position,elevation,azimuth,velocity)
            x0{n} = PointOfView(sprintf('UE%d',ind),ueAntsys,UNdPos(ind,:),0,0,[30,0,0]);
        end
        
        % Define BTS positions
        la = [140  200 10];
        btsAntsys = ueAntsys;
        
        bb = [];
    otherwise
end


% PointOfView(tag,position,elevation,azimuth,agroup)
x1{1} = PointOfView('BTS',btsAntsys,la,0,0);
% figure(3);
% u.Plot(x0,x1);
% axis equal;
% pause(0.1)

figure(11);
u.PlotLOS(x0{1}.position,x1{1}.position);



rain  = 0; % mm/h
times = 0;

itmode =1;
tic
if itmode==0
    
    % Batch calculation
    channelResponse = u.Channels(x0,x1,freq,times,rain,bb);
    
    N0 = channelResponse.link{1}.pov0.antsys.n;
    N1 = channelResponse.link{1}.pov1.antsys.n;
    P  = nan(numel(inds),1);
    PP = nan(numel(inds),4,N0,N1);
    PPe0 = nan(numel(inds),1);
    PPe1 = nan(numel(inds),1);
    PPd = nan(numel(inds),1);
    PPa = nan(numel(inds),1);
    
    for n=1:numel(inds)
        link = channelResponse.link{n};
        ind = inds(n);
        P(n) = channelResponse.link{n}.P;
        for n0=1:N0
            for n1=1:N1
                PP(n,1,n0,n1) = link.los{n0,n1}.P;
                PP(n,2,n0,n1) = link.nlos{n0,n1}.P;
%                 PPe0(n,1,n0,n1) = link.nlos{n0,n1}.elemCoeff0;
%                 PPe1(n,1,n0,n1) = link.nlos{n0,n1}.elemCoeff1;
%                 PPd(n,1,n0,n1)  = link.nlos{n0,n1}.distanceCoeff;
%                 PPa(n,1,n0,n1)  = link.nlos{n0,n1}.atmosphereCoeff;

                PP(n,3,n0,n1) = link.n2los{n0,n1}.P;
                PP(n,4,n0,n1) = link.n3los{n0,n1}.P;
            end
        end
    end
    
else
    
    
    P  = nan(numel(inds),1);
    PP = nan(numel(inds),5);
    PPe0 = nan(numel(inds),1);
    PPe1 = nan(numel(inds),1);
    PPd = nan(numel(inds),1);
    PPa = nan(numel(inds),1);
    
    N = numel(inds);
    DispChannelProgress(N,0,0)
    for n=1:N
        
        ind = inds(n);
        
        % Single link calculation
        [link,cc] = u.Channel(x0{n},x1{1},freq,times,rain);
        DispChannelProgress(N,n,cc);

        N0 = link.pov0.antsys.n;
        N1 = link.pov1.antsys.n;
        for n0=1:N0
            for n1=1:N1
                PP(n,1,n0,n1) = link.los{n0,n1}.P;
                
                PP(n,2,n0,n1) = link.nlos{n0,n1}.P;
%                 PPe0(n,1,n0,n1) = link.nlos{n0,n1}.elemCoeff0;
%                 PPe1(n,1,n0,n1) = link.nlos{n0,n1}.elemCoeff1;
%                 PPd(n,1,n0,n1)  = link.nlos{n0,n1}.distanceCoeff;
%                 PPa(n,1,n0,n1)  = link.nlos{n0,n1}.atmosphereCoeff;
                
                PP(n,3,n0,n1) = link.n2los{n0,n1}.P;
                PP(n,4,n0,n1) = link.n3los{n0,n1}.P;
                PP(n,5,n0,n1) = link.n3los{n0,n1}.P;
            end
        end
        
        P(n) = link.P;
        
    end
    
end
toc

figure(1); clf;
plot(UNdPos(inds,1),P(:,1),'b','LineWidth',4);
hold on;
plot(UNdPos(inds,1),PP(:,1,1),'r','LineWidth',4);
plot(UNdPos(inds,1),PP(:,2,1),'m');
plot(UNdPos(inds,1),PP(:,3,1),'g');
plot(UNdPos(inds,1),PP(:,4,1),'c');
plot(UNdPos(inds,1),squeeze(PP(:,1,:)),'r:');
plot(UNdPos(inds,1),squeeze(PP(:,2,:)),'m:');
plot(UNdPos(inds,1),squeeze(PP(:,3,:)),'g:');
plot(UNdPos(inds,1),squeeze(PP(:,4,:)),'c:');
%plot(UNdPos(inds,1),squeeze(PPe0(:,1,:)),'k:');
%plot(UNdPos(inds,1),squeeze(PPe1(:,1,:)),'k:');
%plot(UNdPos(inds,1),squeeze(PPd(:,1,1)),'k:'); 
%plot(UNdPos(inds,1),squeeze(PPa(:,1,:)),'k:');
legend({'RMS','los','nlos','n2los','n3los'})
xlabel('UNdPos [m]');
ylabel('RMS Path Loss incl antennas [dB]');
grid on;

% Visualize

if 0%scenario==1
    for n=1:numel(inds)
        ind = inds(n);
        figure
        u.Trace(x0{n},x1{1},freq,times,rain);
    end
    figure
    u.Response(x1,x0,freq,times,rain);
end




