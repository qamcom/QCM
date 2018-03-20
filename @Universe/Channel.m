% Renders channel coefficients for given frequency bins and an endpoint pair.
%
% y = u.Channel(pov0,pov1,freqs,times,rain,bb)
% u is an handle to a Universe class (this class)
% freqs:    Vector of frequencies [Hz]
% times:    Vector of time samples [s]
% rain:     Rain intensity [mm/h]
% pov0:     Endpoint 0 (class PointOfView)
% pov1:     Endpoint 1 (class PointOfView)
% bb:       BB signal transmitted over link. Default white
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

function [y,cc] = Channel(u,pov0,pov1,freqs,times,rain,bb)

if ~exist('bb','var') || isempty(bb), bb=ones(1,numel(freqs)); end

losRadius = norm(pov1.position-pov0.position);
%fprintf('losRadius=%d\n',round(losRadius));





losMetas   = cell(pov0.antsys.n,pov1.antsys.n);
nlosMetas  = cell(pov0.antsys.n,pov1.antsys.n);
n2losMetas = cell(pov0.antsys.n,pov1.antsys.n);
n3losMetas = cell(pov0.antsys.n,pov1.antsys.n);

for pp0 = 1:pov0.antsys.n
    
    [POV0,DOV0,NOV0,pol0,rot0,array0,vel0] = pov0.xyz(pp0);
    POL0 = RotateAroundAxis(NOV0,DOV0,pol0);
    dp0 = pov0.antsys.dualpol;
    
    % Find LOS atoms
    indLOS0 = u.FindLOS(POV0);
    
    for pp1 = 1:pov1.antsys.n
        
        
        [POV1,DOV1,NOV1,pol1,rot1,array1,vel1] = pov1.xyz(pp1);
        POL1 = RotateAroundAxis(NOV1,DOV1,pol1);
        dp1 = pov1.antsys.dualpol;
        
        % Find LOS atoms
        indLOS1    = u.FindLOS(POV1);
        
        losCoeff   = 0; losMeta.P=-inf;
        nlosCoeff  = 0; nlosMeta.P=-inf;
        n2losCoeff = 0; n2losMeta.P=-inf;
        n3losCoeff = 0; n3losMeta.P=-inf;
        
        if sys.enableLOS || sys.forceLOS
            
            % First order path exists? (LOS, soft criteria)
            
            if sys.forceLOS
                LOS = 1;
            else
                LOS = u.CheckLOS(POV0,POV1);
            end
            
            % First order path
            losRadius = norm(POV1-POV0);
            
            losMeta.P = -inf;
            if LOS
                
                % Angle off DOV (Elevation vs NOV)
                path01 = POV1-POV0;
                [offElevation0, offAzimuth0] = AngleOffDOV(DOV0,NOV0, path01);
                [offElevation1, offAzimuth1] = AngleOffDOV(DOV1,NOV1,-path01);
                
                % Polarisation diff
                % 0 and pi = perfect polarisation match. pi/2 => no match
                polDiff  = AngleDiff(POL0,POL0);
                
                % Speed diff
                speed0  = vdot(vel0, path01)./losRadius; % Speed of pov0 approaching pov1
                speed1  = vdot(vel1,-path01)./losRadius; % Speed of pov1 approaching pov0
                speed01 = speed0+speed1; % Speed of POVs approaching each others
                
                [losCoeff,losMeta] = LosCoeff(freqs,times,array0,array1,dp0,dp1,rot0,rot1,speed01,losRadius,...
                    offAzimuth0,offElevation0,offAzimuth1,offElevation1,...
                    polDiff,LOS,rain,sys.raySelThreshold,bb);
                
            end
            
        end
        
        
        % Find path reflection points (in LOS from both POV)
        indLOS01 = intersect(indLOS0,indLOS1); % In LOS of both POV
        
        % Second order paths
        if numel(indLOS01) && sys.enableNLOS
            
            % Secondary cluster locations vs POVs
            a = u.GetAtoms(indLOS01);
            path0   = VectorAdd(POV0,-a.surface); % Path from a to POV
            path1   = VectorAdd(POV1,-a.surface);
            radius0 = vnorm(path0,2);
            radius1 = vnorm(path1,2);
            
            % Path angle vs normal (0 = perpendicular towards surface. >pi/2 = from behind.
            elevation0 = AngleDiff(a.normal,path0);
            elevation1 = AngleDiff(a.normal,path1);
            
            % Project paths on surface (plane defined by normals)
            pathS0 = VectorOnPlane(path0,a.normal);
            pathS1 = VectorOnPlane(path1,a.normal);
            
            % Corner edge (or surface orientation)
            normREA = Polar3D(a.normal); en=normREA(:,2); an=normREA(:,3);
            
            % Path angle vs corner edge (or surface orientation)
            pathS0n  = RotateVectorZ(RotateVectorY(RotateVectorZ(pathS0,-an),en),-pi/2-a.corner(:,2));
            azimuth0 = angle(pathS0n(:,1:2) *[1j;1]);
            pathS1n  = RotateVectorZ(RotateVectorY(RotateVectorZ(pathS1,-an),en),-pi/2-a.corner(:,2));
            azimuth1 = angle(pathS1n(:,1:2) *[1j;1]);
            
            % Angle off DOV (Elevation vs NOV)
            [offElevation0, offAzimuth0] = AngleOffDOV(DOV0,NOV0,-path0);
            [offElevation1, offAzimuth1] = AngleOffDOV(DOV1,NOV1,-path1);
            
            % Project POL vectors on the Reflection Plane
            POLS0 = VectorOnPlane(POL0,a.normal);
            POLS1 = VectorOnPlane(POL1,a.normal);
            
            % Polarisation angle paths projected on reflection
            % 0 and pi = no reflection. pi/2 => perfect reflection
            polAngle0 = AngleDiff(pathS0,POLS0);
            polAngle1 = AngleDiff(pathS1,POLS1);
            
            % Speed diff
            speed0  = vdot(vel0,-path0)./radius0; % Speed of pov0 approaching a
            speed1  = vdot(vel1,-path1)./radius1; % Speed of pov1 approaching a
            speed01 = speed0+speed1; % Speed of POVs approaching each others (via a)
            
            if exist('histStats','var') && histStats
                figure(histStats); clf;
                subplot(3,2,1); hist([radius0,radius1],30);                title('Distance to secondary path clusters [m]');
                subplot(3,2,2); hist(180*[offElevation0,offElevation1]/pi,30); title('Elevation vs element to secondary path clusters (vs both endpoints) [degrees]');
                subplot(3,2,3); hist(180*[offAzimuth0,offAzimuth1]/pi,30); title('Azimuth vs element to secondary path clusters (vs both endpoints) [degrees]');
                subplot(3,2,4); hist(180*[elevation0,elevation1]/pi,30); title('Incident angle vs surface normal (vs both endpoints) [degrees]');
                subplot(3,2,5); hist(180*[azimuth0,azimuth1]/pi,30);     title('Incident angle vs corner normal (vs both endpoints) [degrees]');
                subplot(3,2,6); hist(180*[polAngle0,polAngle1]/pi,30);     title('Polarisation vs reflection [degrees]');
                pause(0.1);
            end
            
            [nlosCoeff,nlosMeta] = NlosCoeff(freqs,times,array0,array1,dp0,dp1,rot0,rot1,speed01,...
                a.material,a.corner,radius0,radius1,...
                elevation0,elevation1,azimuth0,azimuth1,...
                offAzimuth0,offElevation0,offAzimuth1,offElevation1,...
                polAngle0,polAngle1,a.res,rain,sys.raySelThreshold,bb);
            
            % Traced paths
            if ~isempty(nlosMeta)
                nlosMeta.ind = indLOS01;
            end
            
        end
        
        % Prune 2nd order paths
        indLOS11 = setdiff(indLOS1,indLOS01);  % In LOS of POV1 only
        indLOS00 = setdiff(indLOS0,indLOS01);  % In LOS of POV0 only
        
        % Higher order paths
        N0 = numel(indLOS00);
        N1 = numel(indLOS11);
        if N0&&N1&&(sys.enableN2LOS || sys.enableN3LOS)
            
            % Select closest secondary cluster locations vs _other_ POVs
            a0       = u.GetAtoms(indLOS00);
            a1       = u.GetAtoms(indLOS11);
            path0    = VectorAdd(POV0,-a0.surface);
            path1    = VectorAdd(POV1,-a1.surface);
            %distance = norm(POV1-POV0);
            radius0  = vnorm(path0,2);
            radius1  = vnorm(path1,2);
            sel0     = find(radius0<sys.secondOrderRange);
            sel1     = find(radius1<sys.secondOrderRange);
            N0       = numel(sel0);
            N1       = numel(sel1);
            
            if N0&&N1
                % Select/Prune
                a0      = u.GetAtoms(indLOS00(sel0));
                a1      = u.GetAtoms(indLOS11(sel1));
                path0   = VectorAdd(POV0,-a0.surface);
                path1   = VectorAdd(POV1,-a1.surface);
                h0      = a0.surface(:,3); % Height of atom
                h1      = a1.surface(:,3); % Height of atom
                
                % Get cross distances
                vNLOS0   = repmat(permute(single(a0.surface),[1,3,2]),1,N1);
                vNLOS1   = repmat(permute(single(a1.surface),[3,1,2]),N0,1);
                path01x  = vNLOS1-vNLOS0;
                radius01 = vnorm(path01x,3);
                
                % Path angle vs normal (0 = perpendicular towards surface. >pi/2 = from behind.
                elevation0 = AngleDiff(a0.normal,path0);
                elevation1 = AngleDiff(a1.normal,path1);
                
                % Project paths on surface (plane defined by normals)
                pathS0 = VectorOnPlane(path0,a0.normal);
                pathS1 = VectorOnPlane(path1,a1.normal);
                
                % Project POL vectors on the Reflection Plane
                POLS0 = VectorOnPlane(POL0,a0.normal);
                POLS1 = VectorOnPlane(POL1,a1.normal);
                
                % Polarisation angle paths projected on reflection
                % 0 and pi = no reflection. pi/2 => perfect reflection
                polAngle0 = AngleDiff(pathS0,POLS0);
                polAngle1 = AngleDiff(pathS1,POLS1);
                
                % Angle off DOV
                [offAzimuth0, offElevation0] = AngleOffDOV(DOV0,NOV0,path0);
                [offAzimuth1, offElevation1] = AngleOffDOV(DOV1,NOV1,path1);
                
                % Speed diff
                speed0  = vdot(vel0,-path0)./vnorm(path0,2); % Speed of pov0 approaching a0
                speed1  = vdot(vel1,-path1)./vnorm(path1,2); % Speed of pov1 approaching a1
                
                % See if any LOS btw 1st bounce from both ends (=> 2 bounce paths)
                if sys.enableN2LOS
                    LOS = u.FindNLOS(a0.surface,a1.surface);
                else
                    LOS = zeros(numel(sel0),numel(sel1));
                end
                inds01 = find(LOS(:)~=0);
                
                N = numel(inds01);
                if N && sys.enableN2LOS % There were one or more 2 bounce paths
                    path01  = zeros(N,3);
                    inds0   = zeros(N,1);
                    inds1   = zeros(N,1);
                    speed01 = zeros(N,1);
                    for ii=1:N
                        [ind0,ind1]  = ind2sub(size(LOS),inds01(ii));
                        inds0(ii)    = ind0;
                        inds1(ii)    = ind1;
                        path01(ii,:) = path01x(ind0,ind1,:);
                        speed01(ii)  = speed0(ind0)+speed1(ind1); % Speed of POVs approaching each others (via a0 and a1)
                    end
                    
                    elevation01 = AngleDiff(a0.normal(inds0,:), path01);
                    elevation10 = AngleDiff(a1.normal(inds1,:),-path01);
                    
                    %                     hold on;
                    %                     cc=colormap;
                    %                     for ii=numel(inds0):-1:1,
                    %                         c0 = a0.corner(inds0(ii),1);
                    %                         c1 = a1.corner(inds1(ii),1);
                    %                         i0 = inds0(ii);
                    %                         i1 = inds1(ii);
                    %                         if ~c0 && ~c1 %&& (max([elevation0(i0),elevation01(i0),elevation1(i1),elevation10(i1)])<(pi+c0)/2)
                    %                             s0 = a0.surface(i0,:);
                    %                             s1 = a1.surface(i1,:);
                    %                             ll=line(...
                    %                                 'XData',[POV0(1);s0(1);s1(1);POV1(1)],...
                    %                                 'YData',[POV0(2);s0(2);s1(2);POV1(2)],...
                    %                                 'ZData',[POV0(3);s0(3);s1(3);POV1(3)],...
                    %                                 'Color','r');%cc(min(63,1+floor(LOS(inds01(ii))*64)),:));
                    % %                                                     ii
                    % %                                                     pause
                    % %                                                     ll.delete;
                    %                         end
                    %
                    %                     end
                    %                     colorbar
                    
                    
                    % Project paths on surface (plane defined by normals)
                    pathS01 = VectorOnPlane( path01,a0.normal(inds0,:));
                    pathS10 = VectorOnPlane(-path01,a1.normal(inds1,:));
                    
                    % Corner edge
                    normREA = Polar3D(a0.normal(inds0,:)); en0=normREA(:,2); an0=normREA(:,3);
                    normREA = Polar3D(a1.normal(inds1,:)); en1=normREA(:,2); an1=normREA(:,3);
                    
                    % Path angles vs corner edges
                    pathS0n  = RotateVectorZ(RotateVectorY(RotateVectorZ(pathS0(inds0,:),-an0),en0),-pi/2-a0.corner(inds0,2));
                    pathS01n = RotateVectorZ(RotateVectorY(RotateVectorZ(pathS01        ,-an0),en0),-pi/2-a0.corner(inds0,2));
                    azimuth0 = pi/2+angle(pathS0n(:,1:2) *[1j;1]);
                    azimuth01= pi/2+angle(pathS01n(:,1:2)*[1j;1]);
                    pathS1n  = RotateVectorZ(RotateVectorY(RotateVectorZ(pathS1(inds1,:),-an1),en1),-pi/2-a1.corner(inds1,2));
                    pathS10n = RotateVectorZ(RotateVectorY(RotateVectorZ(pathS10        ,-an1),en1),-pi/2-a1.corner(inds1,2));
                    azimuth1 = angle(pathS1n(:,1:2) *[1j;1]);
                    azimuth10= angle(pathS10n(:,1:2)*[1j;1]);
                    
                    
                    [n2losCoeff,n2losMeta] = N2losCoeff(freqs,times,array0,array1,dp0,dp1,rot0,rot1,speed01,...
                        a0.material(inds0),a1.material(inds1),...
                        a0.corner(inds0,:),a1.corner(inds1,:),radius0(inds0),radius1(inds1),radius01(inds01),...
                        elevation0(inds0),elevation1(inds1),azimuth0,azimuth1,...
                        elevation01,elevation10,azimuth01,azimuth10,...
                        offAzimuth0(inds0),offElevation0(inds0),offAzimuth1(inds1),offElevation1(inds1),...
                        polAngle0(inds0),polAngle1(inds1),a0.res(inds0),a1.res(inds1),LOS(inds01),rain,sys.raySelThreshold,bb);
                    
                    % Traced paths
                    if ~isempty(n2losMeta)
                        n2losMeta.ind1 = indLOS11(sel1(inds1)); % Indece of atoms in LOS with antenna 1
                        n2losMeta.ind0 = indLOS00(sel0(inds0)); % Indece of atoms in LOS with antenna 0
                    end
                    
                end
                
                % No LOS. Let's connect with stoch. model
                inds01 = find(LOS(:)==0|~sys.enableN2LOS);
                N = numel(inds01);
                if N && sys.enableN3LOS, % There were one or more 2+ bounce paths
                    path01  = zeros(N,3);
                    inds0   = zeros(N,1);
                    inds1   = zeros(N,1);
                    speed01 = zeros(N,1);
                    for ii=1:N
                        [ind0,ind1]=ind2sub(size(LOS),inds01(ii));
                        inds0(ii) = ind0;
                        inds1(ii) = ind1;
                        path01(ii,:) = path01x(ind0,ind1,:);
                        speed01(ii)  = speed0(ind0)+speed1(ind1); % Speed of POVs approaching each others (via a0 and a1)
                    end
                    
                    [n3losCoeff,n3losMeta] = N3losCoeff(freqs,times,array0,array1,dp0,dp1,rot0,rot1,speed01,...
                        a0.material(inds0),a1.material(inds1),...
                        a0.corner(inds0,:),a1.corner(inds1,:),radius0(inds0),radius1(inds1),radius01(inds01),...
                        elevation0(inds0),elevation1(inds1),offAzimuth0(inds0),...
                        offElevation0(inds0),offAzimuth1(inds1),offElevation1(inds1),...
                        polAngle0(inds0),polAngle1(inds1),...
                        a0.res(inds0),a1.res(inds1),h0(inds0),h1(inds1),u.scenario,rain,sys.raySelThreshold,bb);
                    
                    % Traced paths
                    if ~isempty(n3losMeta)
                        n3losMeta.ind1 = indLOS11(inds1); % Indece of atoms in LOS with antenna 1
                        n3losMeta.ind0 = indLOS00(inds0); % Indece of atoms in LOS with antenna 0
                    end
                end
                
            end
        end
        
        Meta.los{pp0,pp1}   = losMeta;
        Meta.nlos{pp0,pp1}  = nlosMeta;
        Meta.n2los{pp0,pp1} = n2losMeta;
        Meta.n3los{pp0,pp1} = n3losMeta;
        
        tmpHf = losCoeff+nlosCoeff+n2losCoeff+n3losCoeff;
        
        % Cat POV1
        if pp1==1
            catHf   = tmpHf;
        else
            catHf   = cat(3,catHf,tmpHf);
        end
        
    end
    
    % Cat POV0
    if pp0==1
        Hf   = catHf;
    else
        Hf   = cat(2,Hf,catHf);
    end
    
end

cc = numel(Hf);

y.tag       = sprintf('%s-%s',pov0.tag,pov1.tag);
y.pov0      = pov0;
y.pov1      = pov1;
y.range     = losRadius;
y.los       = Meta.los;
y.nlos      = Meta.nlos;
y.n2los     = Meta.n2los;
y.n3los     = Meta.n3los;
y.P         = 20*log10(rms(Hf(:)));
y.Hf        = Hf;

