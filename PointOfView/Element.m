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

classdef Element
        
    properties (SetAccess = private)
        tag;
        loss        = 0; 
        front2back  = [];
        randomBack  = 1;
        directivity = 0;
        gain;
    end
    
    properties (Access = private)
        norm        = 0;
    end
    
    methods
        
        function e=Element(tag,front2back,loss,randomBack)
            e.tag = tag;
            if nargin>3, 
                e.randomBack=randomBack; 
            end;  
            if nargin>2, 
                e.loss=loss; 
            end;
            if nargin>1, 
                e.front2back=front2back; 
            end;
            [e.directivity,e.norm] = Directivity(e);
            e.gain = e.directivity-e.loss;
        end
        
        function [y,n]=Directivity(x)            
            r  = 1; 
            da = pi/180;
            de = pi/180;
            a  =-(pi  -da/2):da:(pi  -da/2);
            e  =-(pi/2-de/2):de:(pi/2-de/2);
            [ev,av]=meshgrid(e,a); av=av(:); ev=ev(:);
            z  = ElementCoeff(x,nan,av,ev);
            P  = abs(z).^2;
            Pv = reshape(P,numel(a),numel(e));
%             Pv(:,1:10)=0;
%             contourf(a/pi*180,e/pi*180,10*log10(Pv'),-100:3:60);
%             colorbar

            dA = r^2*abs(cos(ev(:)))*da*de;
            Pa = sum(P.*dA)/sum(dA); % Average power (Should be = 1)
            
            y = x.directivity-(10*log10(Pa)    +x.loss);
            n = x.directivity-(10*log10(max(P))+x.loss);
        end
        
        function y=ElementCoeff(x,freqs,a,e)
            if numel(e)==1, e=repmat(e,size(a)); end;
            if numel(a)==1, a=repmat(a,size(e)); end;
            
            switch x.tag
                
                case 'perasoElement'
                    y = PerasoElement(freqs,e,a);
                    if ~isempty(x.front2back)
                        y0 = PerasoElement(freqs,0,0);
                        y1 = PerasoElement(freqs,0,pi);
                        f2b0 = 20*log10(rms(y0(:))/rms(y1(:)));
                        y  = y.*10.^repmat((-(x.front2back-f2b0)/20*(cos(a)<0)),1,numel(freqs));
                    end

                case 'perasoUnitCell'
                    y  = PerasoUnitCell(freqs,e,a);
                    if ~isempty(x.front2back)
                        y0 = PerasoUnitCell(freqs,0,0);
                        y1 = PerasoUnitCell(freqs,0,pi);
                        f2b0 = 20*log10(rms(y0(:))/rms(y1(:)));
                        y  = y.*10.^repmat((-(x.front2back-f2b0)/20*(cos(a)<0)),1,numel(freqs));
                    end
                    
                case 'column'
                    HPBWv = 10  ; % 3dB Beamwidth degrees
                    HPBWh = 120 ; % 3dB Beamwidth degrees
                    nv    = log(1/sqrt(2))/log(cos(HPBWv/360*pi));
                    nh    = log(1/sqrt(2))/log(cos(HPBWh/360*pi));
                    tmp   = (max(0,cos(a)).^nh.*max(0,cos(e)).^nv);
                    y     = repmat(tmp(:),1,numel(freqs));

                case 'isotropic'
                    y   = ones(numel(a),numel(freqs));
                    
                case 'quarter'
                    tmp = (abs(a)<pi/4);
                    y   = repmat(tmp(:),1,numel(freqs));
                    
                case 'patchLTCC'
                    HPBWv = 100 ; % 3dB Beamwidth degrees
                    HPBWh = 120 ; % 3dB Beamwidth degrees
                    nv    = log(1/sqrt(2))/log(cos(HPBWv/360*pi));
                    nh    = log(1/sqrt(2))/log(cos(HPBWh/360*pi));
                    if isempty(x.front2back)
                        tmp  = max(cos(a),0).^nh.*max(cos(e),0).^nv;
                    else
                        tmp  = abs(cos(a)).^nh.*abs(cos(e)).^nv.*10.^(-x.front2back/20*(cos(a)<0));
                    end
                    y    = repmat(tmp(:),1,numel(freqs));

                case 'patch'
                    HPBW = 120 ; % 3dB Beamwidth degrees
                    n    = log(1/sqrt(2))/log(cos(HPBW/360*pi));
                    if isempty(x.front2back)
                        tmp  = (max(cos(a),0).^n.*max(cos(e),0)).^n;
                    else
                        tmp  = abs(cos(a)).^n.*abs(cos(e)).^n.*10.^(-x.front2back/20*(cos(a)<0));
                    end
                    y    = repmat(tmp(:),1,numel(freqs));

                case 'column4to1'
                    HPBWh = 120 ; % 3dB Beamwidth degrees
                    HPBWv = 30 ;  % 3dB Beamwidth degrees
                    nh    = log(1/2)/log(cos(HPBWh/360*pi))/2;
                    nv    = log(1/2)/log(cos(HPBWv/360*pi))/2;
                    tmp  = (max(cos(a),0).^nh).*(max(cos(e),0).^nv);
                    y    = repmat(tmp(:),1,numel(freqs));

                case 'horn11'
                    HPBW = 11 ; % 3dB Beamwidth degrees
                    n    = log(1/2)/log(cos(HPBW/360*pi));
                    tmp  = (max(0,cos(a)).*max(0,cos(e))).^n;
                    y    = repmat(tmp(:),1,numel(freqs));
                   
                case 'omni'
                    tmp = cos(e);
                    y   = repmat(tmp(:),1,numel(freqs));
                    
                case 'sector90'
                    HPBWv = 8 ; % 3dB Beamwidth degrees
                    HPBWh = 90 ; % 3dB Beamwidth degrees
                    nv    = log(1/sqrt(2))/log(cos(HPBWv/360*pi));
                    nh    = log(1/sqrt(2))/log(cos(HPBWh/360*pi));
                    tmp  = max(cos(a),0).^nh.*max(cos(e),0).^nv;
                    y    = repmat(tmp(:),1,numel(freqs));
                    
                case 'omni8'
                    HPBW = 8 ; % 3dB Beamwidth degrees
                    n    = log(1/2)/log(cos(HPBW*2/360*pi));
                    tmp  = abs(cos(e)).^(2*n);
                    y    = repmat(tmp(:),1,numel(freqs));
                    
                otherwise
                    error('Element type not supported')
            end
            if x.randomBack
                inds = find(abs(a)>pi/2);
                sz = [numel(inds),numel(freqs)];
                if ~isempty(x.front2back)
                    rs = rng('shuffle');
                    %y(inds,:) = (randn(sz)+1j*randn(sz))*10^(-x.front2back/20);
                    y(inds,:) = y(inds,:).*(randn(sz)+1j*randn(sz));
                    rng(rs);
                end
            end

            y = y*10^((x.directivity-x.loss-x.norm)/20);
        end
        
    end
end
    
