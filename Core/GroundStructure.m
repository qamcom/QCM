% Define atoms for ground plane
%
% y = GroundStructure(dx0,dy0,res,material)
% dx0:      Ground length along x.axis [m]
% dy0:      Ground width along y.axis [m]
% res:      Ground tile size / resolution [m]
% material: Classdef Material handle
% y:        classdef Atoms instance
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

function y=GroundStructure(dx0,dy0,res,material)

dx = round(dx0/res);
dy = round(dy0/res);
[tmpx,tmpy] = meshgrid(1:dx,1:dy);
N = numel(tmpx);

y = Atoms;
y.normal   = [zeros(N,2) ones(N,1)*res/2];
y.surface  = [tmpx(:)*res-res/2 tmpy(:)*res-res/2 zeros(N,1)]; % Put atom surface on top
y.corner   = zeros(N,2);
y.material = repmat(material,N,1);
y.res      = repmat(res,N,1);


