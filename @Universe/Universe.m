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
            
            u.atoms.normal   = zeros(0,3);
            u.atoms.surface  = zeros(0,3);
            u.atoms.corner   = zeros(0,2);
            u.atoms.res      = zeros(0,1);
            
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
        y = Channels(u,freqs,rain,x0,x1,bb);
        
        % Render channel between a single point-of-view pair in universe
        y = Channel(u,freqs,rain,pov0,pov1,bb);
        
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
        
        
        y = Trace(u,pov0,pov1,freqs,rain);
        [Hf,Fbins,Ht,Tbins,Rbins,Pt,Pf]=Response(u,povs0,povs1,freqs,rain);

        
        % Plot 3D picture to illustrate materials
        Plot(u,x0,x1,forceColor,pbox);           
        
        % Plot 3D picture to illustrate line-of-sight
        PlotLOS(u,POV0,POV1);      
        
        
        
    end
end
