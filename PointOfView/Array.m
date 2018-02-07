% Defined with implicit POV=[0 0 0], DOV=[1,0,0] and NOV=[0,0,1]
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
classdef Array
    
    properties (SetAccess = private)
        tag;     % Identifier string
        array;   % Array config H,V
        pol;     % Polarisation vs NOV
        element; % Element Class
        nelem;   % Nrof elements
        npath;   % Nrof sub-arrays
        subarray;% Mapping of static subarrays subarray(subarray-index,element-index)
        aperture;% Size of box enclosing all elements
        f0;      % [Hz] Normalize bore sight gain at this frequency (ie. matching network)
        norm=0;  % [dB] Normalisation factor 
        directivity; % [dBi] Bore sight directivity
        loss;    % Feeder loss on average [dB]
        elemloss;% Element loss [dB]
        gain;    % Array gain
    end
    
    
    methods
        
        function x = Array(tag,array,element,pol,subarray,f0,loss2cm)
            x.tag     = tag;
            if size(array,2)==2
                x.array   = [zeros(size(array,1),1) array]; % Include X coord
            else
                x.array   = array;
            end
            x.element = element;
            x.pol     = pol;
            x.nelem   = size(array,1);
            if nargin<6 || isempty(subarray),
                x.subarray = 1;
                x.npath    = x.nelem;
            else
                x.subarray = subarray;
                x.npath    = size(subarray,1);
            end

            if nargin <7 || isempty(f0), 
                x.f0 = nan;
            else
                x.f0 = f0;
            end
            if nargin <8 || isempty(loss2cm), 
                x.loss = 0;
            else
                x.loss = 10*log10(mean(10.^(loss2cm*vnorm(array,1)*100/10)));
            end
            x.elemloss = x.element.loss;
            
            x.aperture = [max(array(:,1))-min(array(:,1)),max(array(:,2))-min(array(:,2))];
            
            if ~isnan(x.f0)
                [x.directivity,x.norm]=x.Directivity;
            end
            x.gain = x.directivity-x.loss-x.element.loss;
                        
        end
                
        % Beam weights for a beam in one wanted direction
        function w=SingleBeam(a,elevation,azimuth)         % Get beamforming weight for direction, for center frequency
            farfaraway = 1e9; % Meter...  
            HS = ArrayCoeff(a,a.f0,farfaraway,elevation,azimuth,0); % Channel from point far far away
            H  = a.ProjectSubarray(HS);
            w  = mean(exp(-1j*angle(H)),1); % Conjugate of phase.
        end
        
        function w=ExpandSubarray(a,ws)
            % Expand to sub-arrays
            w = permute(ws,[1,3,2])*a.subarray;
            w = w/norm(w);
            w = ipermute(w,[1,3,2]);
        end
        
        % Map on static sub-arrays
        function H=ProjectSubarray(a,HS)
            if size(HS,3)==1,
                H = HS;
            else
                H = permute(multiprod(HS,a.subarray.',[2,3],[1,2]),[2,1,3]);
            end
        end

        
        function [d,n,w]=Directivity(a,azimuth,elevation)

            if nargin<3
                elevation=0;
                azimuth=0;
            end
            
            % Get beamforming weight for direction, for used frequencies
            w  = a.SingleBeam(elevation,azimuth);
            we = a.ExpandSubarray(w);
            
            
            ne = a.nelem;
            np = a.npath;
            r  = 1000;
            da = pi/180; % 1 degree steps
            de = pi/180; % 1 degree steps
            
            aa  =-(pi  -da/2):da:(pi  -da/2);
            ee  =-(pi/2-de/2):de:(pi/2-de/2);
            [ev,av]=meshgrid(ee,aa); av=av(:); ev=ev(:);
            nr = numel(ev); nf=numel(a.f0);

            z = a.element.ElementCoeff(nan,av,ev);
            q = a.ArrayCoeff(a.f0,repmat(r,nr,1),ev,av,0);
            
            P = mean(abs(sum(repmat(we,nr,nf).*q.*repmat(z,[1,nf,ne]),3)).^2,2);
            
           
            dA = r^2*abs(cos(ev(:)))*da*de;
            Pa = sum(P.*dA)/sum(dA); % Average power (Should be = 1)
            
%                          Pv = reshape(P,numel(aa),numel(ee));
%                          imagesc(aa/pi*180,ee/pi*180,10*log10(Pv'/mean(Pa)));
%                          colorbar

            n = 10*log10(Pa)+a.element.loss+a.loss;
            d = 10*log10(max(P))-10*log10(Pa);
            w = w*10^(n/10);
        end

        % Individual Element positions aligned and translated according to POV definition.
        function elem=Elem(a,pov,dov,nov)
            x = dov;
            z = nov;
            y = cross(x,z);
            elem = a.array*[x;y;z];
            elem = elem + repmat(pov,size(elem,1),1);
        end
        
        function Plot(a,pov,dov,nov)
            cp=1;
            cn=1;

            plot3(pov(1),pov(2),pov(3),'r*','MarkerSize',4), hold on;
            plot3([pov(1) pov(1)+cp*dov(1)],[pov(2) pov(2)+cp*dov(2)],[pov(3) pov(3)+cp*dov(3)],'r','LineWidth',4)
            plot3([pov(1) pov(1)+cn*nov(1)],[pov(2) pov(2)+cn*nov(2)],[pov(3) pov(3)+cn*nov(3)],'r:','LineWidth',4)

            elem = a.Elem(pov,dov,nov);
            plot3(elem(:,1),elem(:,2),elem(:,3),'r.'), hold on;
        end
        
        % radius(ray)            Ray distance to source
        % elevation(ray)         Ray elevation vs antenn array (vs NOV)
        % azimuth(ray)           Ray azimuth vs antenna array (vs DOV)
        % rotatation             Array orientation/rotation vs DOV/NOV
        % elem(element,1)        Antenna element horizontal position (Horizontal arrays)
        % elem(element,2)        Antenna element vertical position (Vertical arrays)
        % Calculates coeff per antenna element
        % y(freq,elem)
        function y = ArrayCoeff(a,freqs,radius,elevation,azimuth,rotation)
            NR = size(radius,1);
            NF = numel(freqs);
            
            % Element positions rotated according to POV definition.
            elem = RotateVectorX(a.array,rotation);
            
            % Ray sources.
            ray = Cartesian3D([radius,pi/2-elevation,azimuth]);
            
            % Get cross distances (ray source - array elem)
            R         = repmat(permute(single(ray), [1,3,2]),1,a.nelem);
            E         = repmat(permute(single(elem),[3,1,2]),NR,1);
            pathR2E   = R-E;
            diffR2E   = vnorm(pathR2E,3)-repmat(radius,1,a.nelem); % Distance difference vs phase center
            
            % Phase offset alfa(ray,freq,elem) = 2pi*d/lambda = 2pi*d*f/c
            alfa = 2*pi/sys.c*repmat(permute(diffR2E,[1,3,2]),1,NF).*repmat(freqs,[NR,1,a.nelem]);
            
            % Array coeff y(freq,elem) = exp(1j*alfa)
            y = exp(1j*alfa)*10^(-(a.norm+a.loss)/20);
            
        end
        
        
    end
end



