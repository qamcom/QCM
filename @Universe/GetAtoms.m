% Get selected atoms from Universe.
%
% y = u.GetShadingAtoms(inds)
% u is an handle to a Universe class (this class)
% indas:     Index vector. FOr example defined by FindLOS method
% y:         Instance of classdef Atoms
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

function y = GetAtoms(u,inds)
y=Atoms;
if nargin>1
    y.normal   = u.atoms.normal(inds,:);
    y.surface  = u.atoms.surface(inds,:);
    y.material = u.atoms.material(inds,:);
    y.corner   = u.atoms.corner(inds,:);
    y.res      = u.atoms.res(inds,:);
else
    y.normal   = u.atoms.normal;
    y.surface  = u.atoms.surface;
    y.material = u.atoms.material;
    y.corner   = u.atoms.corner;
    y.res      = u.atoms.res;
end


