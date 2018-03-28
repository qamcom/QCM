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
        scenario;   % Scenario for stochastic component (N3LOS)
    end
    
    properties (Access = private)
        los;    % POV cache
        atoms;  % Atoms list (for quick access) 
        obj;    % Object list (ground, buildings etc. each with optional polygon set)
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
        end
        
        % Clear LOS cache
        function ResetLOS(u)
            u.los   = [];
            u.los.N = 0;
            u.atoms = [];
        end
        
        % Add Structure to universe
        % Will be tiled into atoms.
        % x.point(pi,1:3) XYZ coord of Points in structure
        % x.surface{si}.pi(1:N): List of point-index vectors. N >= 3. Defines a Polygon
        % x.corner{ci}.si(1:2):  Index of Two surfaces defining the corner.
        % x.corner{ci}.pi(1:2):  Index of Two points defining the corner.
        % res: Maximum tile size. [m]
        % pos: Global position (XYZ)
        % rot: Azimuth rotation (rad)
        AddStructure(u,tag,x,res,pos,rot,velocity);
                
        % Get all (or subset of) atoms in universe
        % cat method for AToms very slow. So keep results in cache
        function y = GetAtoms(u,inds)
            if isempty(u.atoms)
                y = Atoms;
                for o=1:u.nrofObj
                    y = cat(y,u.obj(o).atoms);
                end
                u.atoms = y;
            else
                y=u.atoms;
            end
            if nargin==2
                y = y.Prune(inds);
            end
        end
        
        % Get all structures in universe
        function y = GetStructures(u)
            for o=1:u.nrofObj
                y(o)=u.obj(o).structure;
            end
        end
        
        % Render channel between several point-of-view pairs in universe
        y = Channels(u,x0,x1,freqs,times,rain,bb);
        
        % Render channel between a single point-of-view pair in universe
        [y,cc] = Channel(u,x0,x1,freqs,times,rain,bb);
        
        % Random nudge of location and alignmnet of atoms in universe
        function Nudge(u,ratio,seed)
            if nargin<3, seed  = 0; end
            if nargin<2, ratio = 0.1; end
            tmp=rng;
            for k=1:u.nrofObj
                rng(seed);
                o = u.obj(k);
                o.atoms.surface = o.atoms0.surface + ratio*repmat(o.atoms.res,1,3).*randn(o.nrofAtoms,3);
                o.atoms.normal = o.atoms0.normal + ratio*randn(o.nrofAtoms,3);
            end
            rng(tmp);
        end
        
        % System Evaluation
        % A: Activity factor A(tx-node,rx-node) [0,1]
        % sinr(cell/tx index, layer-index): Multi-user SINR (linear)
        % snr(cell/tx index, layer-index): Single-layer SNR (linear)
        % snr0(cell/tx index, ms-index): Single layer SNR w/o precoding (eg BCH)
        % sinrPredict, same as sinr but predicted using OrthoTest
        [sinr,snr,snr0,sinrPredict,C] = System(u,TXpov,RXpov,A,freqs,times,rain);
        
        % Visualize channel
        y = Trace(u,pov0,pov1,freqs,rain);
        [Hf,Fbins,Ht,Tbins,Rbins,Pt,Pf]=Response(u,povs0,povs1,freqs,rain);
        
        % Plot 3D picture to illustrate materials
        Plot(u,x0,x1,forceColor,pbox);
        
        % Plot 3D picture to illustrate line-of-sight
        PlotLOS(u,POV0,POV1);
        
        
    end
end
