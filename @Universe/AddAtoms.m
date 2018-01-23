% Adds Atoms to Universe
%
% u.AddAtoms(tag,x,pos,rot)
% u is an handle to a Universe class (this class)
% tag is just a text string to label this structure in Universe
% x is an instance of classdef Atoms
% pos (optional) is a 3D ccordinate for translating structure into Universe
% rot (optional) is a azimuth rotation angle ro rotate structure into Universe
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

function AddAtoms(u,tag,x,pos,rot)

% Clear LOS cache
u.ResetLOS;

if ~exist('pos','var'), pos=[0,0,0]; end
if ~exist('rot','var'), rot=0;       end

if sys.forceNoCorners
    ind = find(~x.corner(:,1));
    x.normal   = x.normal(ind,:);
    x.surface  = x.surface(ind,:);
    x.material = x.material(ind,:);
    x.corner   = x.corner(ind,:);
    x.res      = x.res(ind,:);
end

% Add this structure to database
nAtom = size(x.normal,1);
nn = u.nrofObj+1;
u.obj(nn).tag = tag;
u.obj(nn).firstAtom = u.nrofAtoms+1;
u.obj(nn).nrofAtoms = nAtom;
inds = u.nrofAtoms+(1:nAtom);

u.atoms.normal(inds,1:3)  = RotateVectorZ(x.normal,rot);
u.atoms.surface(inds,1:3) = RotateVectorZ(x.surface,rot)+repmat(pos,nAtom,1);
u.atoms.material(inds,1)  = x.material;
u.atoms.corner(inds,1:2)  = x.corner; 
u.atoms.res(inds,1)       = x.res;

u.nrofObj   = nn;
u.nrofAtoms = u.nrofAtoms+nAtom;

% Save atoms orignal state to allow Nudging
u.nudge0.normal(inds,1:3)  = u.atoms.normal(inds,1:3);
u.nudge0.surface(inds,1:3) = u.atoms.surface(inds,1:3);

