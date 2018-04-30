% Finds all atom in sight of POV.
% Uses a cache to re-use results and save runtime.
%
% [indLOS,indNLOS] = u.FindLOS(POV)
% u is an handle to a Universe class (this class)
% POV:      [x,y,z] Coordinate sof point-of-view [m]
% indLOS:   Indece of all atoms in line-of-sight vs POV
% indNLOS:  Indece of all atoms in NOT line-of-sight vs POV
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

function [indLOS,indNLOS] = FindLOS(u,POV,range)

% Discrete position
POV=round(POV/sys.largeScaleResolution)*sys.largeScaleResolution;

% Check LOS cache
ind = [];
if ~isempty(u.los) && u.los.N>0
    ind = FindPt(u.los.pov,POV);
else
    u.los.N = 0;
end

% If not in cache
if isempty(ind)
    
    % All Atoms & Structures
    a = u.GetAtoms;
    s = u.GetStructures;
    
    % Trace core
    ptmask = FindCore(a.surface,POV,s,range);
    indLOS = find(ptmask);
    
    % Store in cache
    ind = u.los.N+1;
    u.los.ind{ind}=indLOS(:);
    u.los.pov(ind,1:3)=round(POV);
    u.los.N=ind;
else
    
    % Load from cache
    indLOS = u.los.ind{ind};
    
end

indNLOS = setdiff(1:u.nrofAtoms,indLOS);

