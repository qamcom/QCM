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
            if nargin<2, ratio = 0; end
            tmp=rng(seed);
            u.atoms.surface = u.nudge0.surface + ratio*repmat(u.atoms.res,1,3).*randn(u.nrofAtoms,3); 
            u.atoms.normal  = u.nudge0.normal  + ratio*randn(u.nrofAtoms,3);
            rng(tmp);
            natoms = u.nrofAtoms;
        end
        
        % System Evaluation
        % 0. Calculate detectors (P&E) for each link.
        % 1. Calculate XNR matrix
        % 2. Interference summed at RXpov's using activity factors A
        % 3. Add thermal noise
        % 4. Produce post equalizer SINR
        function snr = System(u,TXpov,RXpov,A,freqs,times,rain)
            Nrx = numel(RXpov);
            Ntx = numel(TXpov);
            BW = (max(freqs)-min(freqs));
            ii=0;
            for rxi = 1:Nrx
                for txi = 1:Ntx
                    if A(txi,rxi)
                        ii = ii+1;
                        linkInd(txi,rxi)=ii;
                        TX   = TXpov{txi};
                        RX   = RXpov{rxi};
                        link = u.Channel(RX,TX,freqs,times,rain);
                        H    = link.Hf;
                        P    = TX.algorithm.DesignPrecoder(H,TX.hardware.power,RX.hardware.nf,BW);
                        HP   = TX.algorithm.Precode(H,P);
                        E    = RX.algorithm.DesignEqualizer(HP,RX.hardware.nf,BW);
                        EHP  = RX.algorithm.Equalize(HP,E);
                        snr(txi,rxi)=rms(EHP(:)).^2; % (X)Link signal vs Noise floor
                    end
                end
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
