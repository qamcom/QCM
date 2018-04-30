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
        scenario;   % Scenario for stochastic component (NXLOS)
        objects = Item;    % Object list (ground, buildings etc. )
    end
    
    properties (Access = private)
        los;    % POV cache
        atoms;  % Atoms list (for quick access) 
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
        % structure.point(pi,1:3) XYZ coord of Points in structure
        % structure.surface{si}.pi(1:N): List of point-index vectors. N >= 3. Defines a Polygon
        % structure.corner{ci}.si(1:2):  Index of Two surfaces defining the corner.
        % structure.corner{ci}.pi(1:2):  Index of Two points defining the corner.
        % res: Maximum tile size. [m]
        % pos: Global position (XYZ)
        % rot: Azimuth rotation (rad)
        % velocity: Velocity vector [sx,sy,sz] m/s
        function index = AddStructure(u,tag,structure,res,pos,rot,velocity)
            if ~exist('pos','var')||isempty(pos), pos=[0 0 0];       end
            if ~exist('rot','var')||isempty(rot), rot=0;       end
            if ~exist('velocity','var')||isempty(velocity), velocity=[0 0 0];       end
            if u.nrofObj
                index = u.nrofObj+1;
            else
                index = 1;
            end
            u.nrofObj = index;
            u.objects(index)=Item;

            DefStructure(u,index,1,tag,structure,res,pos,rot,velocity);
            u.ResetLOS;

        end
        
        % Get pseudo random user positions
        % Placed on surfaces with people density indication
        function pov = People(u,seed)
            ph_mean = 1.5; % People height average
            ph_std  = 0.2; % People height std dev
            ph_min  = 1;   % Minimum height
            ph_max  = 2;   % Maximom
            rr = rng;
            st = GetStructures(u);
            pov = [];
            for sti = 1:length(st)
                points   = st(sti).points;
                surfaces = st(sti).surfaces;
                for sui = 1:length(surfaces)
                    surface = surfaces{sui};
                    if isfield(surface,'people')
                        rng(seed);
                        pp    = points(surface.pi,:);
                        pp2m2 = surface.people;
                        box = [max(pp);min(pp)]; % Box enclosing polygon
                        dbox = abs(diff(box)); % box size
                        np  = round(prod(dbox(1:2))*pp2m2); % Nrof pp in box
                        pov2D = [min(pp(:,1))+dbox(1)*rand(np,1),min(pp(:,2))+dbox(2)*rand(np,1)];
                        pov2D = pov2D(inpolygon(pov2D(:,1),pov2D(:,2),pp(:,1),pp(:,2)),:);
                        pov   = [pov;[pov2D,mean(box(:,3))+min(ph_max,max(ph_min,ph_mean+ph_std*randn(size(pov2D,1),1)))]];
                    end
                end
            end
            rng(rr);
        end
                        
        % Re/Define Structure in universe
        DefStructure(u,index,valid,tag,structure,res,pos,rot,velocity);
        
        % Get all (or subset of) atoms in universe
        % cat method for AToms very slow. So keep results in cache
        function y = GetAtoms(u,inds)
            if isempty(u.atoms)
                y = Atoms;
                valid = find([u.objects.enabled]);
                for k=1:numel(valid)
                    o = valid(k);
                    a = u.objects(o).atoms;
                    y = cat(y,a);
                end
                u.atoms = y;
            else
                y=u.atoms;
            end
            if nargin==2
                y = y.Prune(inds);
            end
        end
        
        % Get all structures in universe (global pos)
        function y = GetStructures(u)
            valid = find([u.objects.enabled]);
            N = numel(valid);
            if N>0
                for k=1:numel(valid)
                    o = valid(k);
                    obj = u.objects(o);
                    structure = obj.structure;
                    structure.points = RotateVectorZ(structure.points ,obj.rot)+obj.pos;
                    structure.p0     = structure.p0+obj.pos;
                    y(k)=structure;
                end
            else
                y=[];
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
                o = u.objects(k);
                nn = size(o.atoms0.surface,1);
                o.atoms.surface = o.atoms0.surface + ratio*repmat(o.atoms.res,1,3).*randn(nn,3);
                o.atoms.normal = o.atoms0.normal + ratio*randn(nn,3);
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

function x=UniqueToken(remove)
persistent active
if nargin
    active = setdiff(active,remove);
end
if nargout
    if ~isempty(active)
        free = setdiff(1:max(active)+1,active);
        x    = min(free);
        active(end+1)=x;
    else
        x      = 1;
        active = 1;
    end
end
end

