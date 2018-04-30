% Define patches for plot/visualizing surfaces
%
% [x,y,z,c] = a.SurfacePatches
% a:        classdef Atoms instance
% x,y,z,c:  Parameters to built-in "patch" function
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

function [x,y,z,c] = SurfacePatches(a)

ind = find(~a.corner(:,1)&vnorm(a.normal,2)>0);
N = numel(ind);

if N
    
    % Orientation of each surface
    normREA = Polar3D(a.normal(ind,:));
    en = normREA(:,2);
    an = normREA(:,3);
    
    % Patch shape (universal)
    patch0    = [-1 -1 0; -1 1 0; 1 1 0; 1 -1 0]/2;
    
    Ns = size(patch0,1);
    patches = zeros(N,3,Ns);
    
    % Copy and rotate default patch
    for s=1:Ns
        patches(:,:,s) = a.surface(ind,:)+RotateVectorZ(RotateVectorY(RotateVectorZ(patch0(s,:),pi/2+a.corner(ind,2)),-en),an).*repmat(a.res(ind),1,3);
    end
    
    % Cut out so format fits with 'patch' function
    patches = permute(patches,[3,1,2]);
    x = patches(:,:,1);
    y = patches(:,:,2);
    z = patches(:,:,3);
    c = [a.material(ind).color];
    
else
    x=[];
    y=[];
    z=[];
    c=[];
end

