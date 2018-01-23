% Define lines for plot/visualizing corners
%
% [x,y,z] = a.CornerLines
% a:        classdef Atoms instance
% x,y,z:  Parameters to built-in "line" function
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

function [x,y,z] = CornerLines(a)

ind = find(a.corner(:,1));
N = numel(ind);
if N
    
    % Corner line (universal)
    patch    = [0 -1 0; 0 1 0]/2;
    Ns = size(patch,1);

    % Orientation of each corner
    normREA = Polar3D(a.normal(ind,:));
    en = normREA(:,2);
    an = normREA(:,3);
        
    % Add corner opening. Rote to orientation. Scale to size.
    % corner(:,1)==corner opening (0=flat)
    % corner(:,2)==corner orientation (0=vertical)
    patches = zeros(N,3,Ns);
    for s=1:Ns
        patches(:,:,s) = RotateVectorZ(RotateVectorY(patch(s,:),-a.corner(ind,1)/2),pi/2+a.corner(ind,2)).*repmat(a.res(ind),1,3);
    end
        
    % Align and translate
    for s=1:Ns
        patches(:,:,s) = a.surface(ind,:)+RotateVectorZ(RotateVectorY(patches(:,:,s),-en),an);
    end
    
    % Cut out so format fits with 'line' function
    patches = permute(patches,[3,1,2]);
    x = patches(:,:,1);
    y = patches(:,:,2);
    z = patches(:,:,3);
    
else
    x=[];
    y=[];
    z=[];
end