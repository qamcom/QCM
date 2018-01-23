% Define patches for plot/visualizing corners
%
% [x,y,z,c] = a.CornerPatches
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

function [x,y,z,c] = CornerPatches(a)

ind = find(a.corner(:,1));
N = numel(ind);
if N
    
    % Corner shape (universal)
    dc = 1/10;
    patch    = [-dc -1 0; -dc 1 0; dc 1 0; dc -1 0]/2;
    Ns = size(patch,1);

    % Orientation of each corner
    normREA = Polar3D(a.normal(ind,:));
    en = normREA(:,2);
    an = normREA(:,3);
    
    % Mirror default patch around x-axis for both sides of corner
    patch0 = patch; patch0(:,1)=patch(:,1)-min(patch(:,1));
    patch1 = patch; patch1(:,1)=min(patch(:,1))-patch(:,1);
    
    % Add corner opening. Rote to orientation. Scale to size.
    % corner(:,1)==corner opening (0=flat)
    % corner(:,2)==corner orientation (0=vertical)
    patches0 = zeros(N,3,Ns);
    patches1 = zeros(N,3,Ns);
    for s=1:Ns
        patches0(:,:,s) = RotateVectorZ(RotateVectorY(patch0(s,:),-a.corner(ind,1)/2),pi/2+a.corner(ind,2)).*repmat(a.res(ind),1,3);
        patches1(:,:,s) = RotateVectorZ(RotateVectorY(patch1(s,:), a.corner(ind,1)/2),pi/2+a.corner(ind,2)).*repmat(a.res(ind),1,3);
    end
    
    C = 0;%1/100;
    % Make corners stand out a bit
    patches0(:,3,:) = patches0(:,3,:)+1/100;
    patches1(:,3,:) = patches1(:,3,:)+1/100;
    
    % Align and translate
    for s=1:Ns
        patches0(:,:,s) = a.surface(ind,:)+C*a.normal(ind,:)+RotateVectorZ(RotateVectorY(patches0(:,:,s),-en),an);
        patches1(:,:,s) = a.surface(ind,:)+C*a.normal(ind,:)+RotateVectorZ(RotateVectorY(patches1(:,:,s),-en),an);
    end
    
    % Cut out so format fits with 'patch' function
    patches = permute([patches0;patches1],[3,1,2]);
    x = patches(:,:,1);
    y = patches(:,:,2);
    z = patches(:,:,3);
    c = [[a.material(ind).color]; [a.material(ind).color]];
    c = c(:);
    
else
    x=[];
    y=[];
    z=[];
    c=[];
end