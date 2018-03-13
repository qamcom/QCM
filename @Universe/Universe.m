% The environment for the Map Based Channel Model
% I.e. "The Map". Contains all structure.
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

classdef Universe < handle
    
    properties (SetAccess = private)
        tag;        % Identifier string
        nrofAtoms;
        nrofObj;
        obj;        % Object list (ground, buildings etc)
        atoms;      % Classdef Atoms (Surfaces & Corners)
        scenario;   % Scenario for stochastic component (N3LOS)
    end
    
    properties (Access = private)
        los;    % POV cache
        nudge0; % Original atom def (before any Nudge)
    end
    
    methods
        
        % Constructor
        function u=Universe(tag,scenario)            
            u.tag       = tag;
            u.nrofObj   = 0;
            u.nrofAtoms = 0;
            if nargin==2
                u.scenario  = scenario;
            else
                u.scenario  = 'hata-urban-smallcity';
            end           
            u.atoms = Atoms;
        end
        
         % Clear LOS cache
        function ResetLOS(u)
            u.los   = [];
            u.los.N = 0;
        end
         
       
        % Add atoms to universe
        AddAtoms(u,tag,x,pos,rot);
        
        % Get all (or subset of) atoms in universe
        y = GetAtoms(u,inds);

        % Render channel between several point-of-view pairs in universe
        y = Channels(u,x0,x1,freqs,times,rain,bb);
        
        % Render channel between a single point-of-view pair in universe
        y = Channel(u,x0,x1,freqs,times,rain,bb);
        
        % Random nudge of location and alignmnet of atoms in universe
        function natoms = Nudge(u,ratio,seed)
            if nargin<3, seed  = 0; end
            if nargin<2, ratio = 0.1; end
            tmp=rng(seed);
            u.atoms.surface = u.nudge0.surface + ratio*repmat(u.atoms.res,1,3).*randn(u.nrofAtoms,3); 
            u.atoms.normal  = u.nudge0.normal  + ratio*randn(u.nrofAtoms,3);
            rng(tmp);
            natoms = u.nrofAtoms;
        end

            
        % System Evaluation
        % A: Activity factor A(tx-node,rx-node) [0,1]
        % sinr(cell/tx index, layer-index): Multi-user SINR (linear)
        % snr(cell/tx index, layer-index): Single-layer SNR (linear)
        % snr0(cell/tx index, ms-index): Single layer SNR w/o precoding (eg BCH)
        % sinrPredict, same as sinr but predicted using OrthoTest
        function [sinr,snr,snr0,sinrPredict] = System(u,TXpov,RXpov,A,freqs,times,rain)
            
            BW = (max(freqs)-min(freqs));
            pn0 = 4*sys.kB*sys.T*BW;    % Ideal noise floor [Watt]

            Nrx = numel(RXpov);
            Ntx = numel(TXpov);
            ii=0;
            for txi = 1:Ntx
                TX = TXpov{txi};
                Pt = TX.hardware.power;
                pt = 10^((Pt-30)/20);         % Transmitter output power [Watt]
                Hmu = [];
                for rxi = 1:Nrx
                    if A(txi,rxi)
                        
                        % Get channel
                        RX   = RXpov{rxi};
                        NFr  = RX.hardware.nf;
                        pn   = pn0*10^(NFr/20); % Receiver noise power [Watt]
                        link = u.Channel(RX,TX,freqs,times,rain);
                        H    = link.Hf;
                        
                        % Concat for MU case below
                        Ns = size(H,1);
                        SUind{rxi}=size(Hmu,1)+(1:Ns);
                        Hmu(SUind{rxi},:,:,:) = H;
                        
                        % Multi-layer. Single user case
                        P    = TX.algorithm.DesignPrecoder(H,Pt,NFr,BW);
                        HP   = TX.algorithm.Precode(H,P);
                        E    = RX.algorithm.DesignEqualizer(HP,NFr,BW);
                        EHP  = RX.algorithm.Equalize(HP,E);
                        snr(txi,SUind{rxi})= diag(rms(rms(EHP,3),4)).^2*pt/pn/Ns; % PC&EQ Link signal vs Noise floor

                        % Single layer. No precoder (typ. broadcasting)
                        EH  = RX.algorithm.Equalize(H,E);
                        snr0(txi,rxi) = rms(EH(:)).^2*pt/pn; % EQ Link signal vs Noise floor
                    end
                end
                
                    % Multiuser case

                    % Actual SINR
                    Pmu  = TX.algorithm.DesignPrecoder(Hmu,Pt,NFr,BW);
                    HPmu = TX.algorithm.Precode(Hmu,Pmu);
                    for rxi = 1:Nrx
                        if A(txi,rxi)
                            RX    = RXpov{rxi};
                            NFr   = RX.hardware.nf;
                            HPsu  = HPmu(SUind{rxi},SUind{rxi},:,:);                % Useful channel
                            IPsc  = HPmu(SUind{rxi},setdiff(1:end,SUind{rxi}),:,:); % Channel for Inter MS (Intra Cell) interference channel
                            Esu   = RX.algorithm.DesignEqualizer(HPsu,NFr,BW);
                            EHPsu = RX.algorithm.Equalize(HPsu,Esu);
                            Ns    = size(EHPsu,1);
                            for stream = 1:Ns
                               S  = mean(abs(EHPsu(stream,stream,:).^2));
                               Iu = mean(sum(abs(EHPsu(stream,setdiff(1:Ns,stream),:)).*2,2));
                               Ic = mean(sum(abs(IPsc(stream,:,:)).^2,2));
                               N  = pn/pt;
                               sinr(txi,SUind{rxi})=S/(Iu+Ic+N); % PC&EQ Link signal vs Self inteference and Noise floor
                            end
                        end
                    end
                    
                    % Prediction based on OrthoTest
                    [~,tmp] = TX.algorithm.OrthoTest(Hmu,snr(txi,:));
                    sinrPredict(txi,:) = tmp;
                
            end
            
            
        end
        
        % Visualize channel
        y = Trace(u,pov0,pov1,freqs,rain);
        [Hf,Fbins,Ht,Tbins,Rbins,Pt,Pf]=Response(u,povs0,povs1,freqs,rain);
        
        % Plot 3D picture to illustrate materials
        Plot(u,x0,x1,forceColor,pbox);           
        
        % Plot 3D picture to illustrate line-of-sight
        PlotLOS(u,POV0,POV1);      
        
        
        
    end
end
