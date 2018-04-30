% Generate a number of trivial trees as an Structure class instance
% y = TreeStructure(p,r,h,matTrunk,matFoliage)
% p   tree positions
% r   tree radii
% h   tree heights
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

function y = TreeStructure(r,h,matTrunk,matFoliage)


% Defining points
p  =[0 0 0; 0 0 h-r];
 
% Surfaces. None
s = cell(0);    
c = cell(0);    

% Corners. Trunk.
c{1}.pi       = [1 2];
c{1}.si       = [];
c{1}.material = matTrunk;

% Clouds. Crown
x{1}.pi       = 2;
x{1}.radius   = r;
x{1}.density  = 0.5;
x{1}.material = matFoliage;

y = Structure(p,s,c,x);

% y = Atoms;  % Init 'Atoms' class instance
% 
% % Trunks
% y.surface  = p+[zeros(N,2) (h-r)/2]; % Trunk center (trunk height = h-r)
% y.corner   = repmat([pi,0],N,1);     % Special case, Corner w/o surface
% y.res      = h-r;                    % Trunk length
% y.normal   = repmat([1,0,0],N,1);    % Normal irrelevant
% y.material = repmat(matTrunk,N,1);
% 
% % Crowns
% y.surface  = [y.surface;  p+[zeros(N,2) h-r]]; % Crown center (trunk height = h-r)
% y.corner   = [y.corner;   repmat([0,0],N,1)];  % Special case, Not a surface at all
% y.res      = [y.res;      r*2];                  % Crown radius
% y.normal   = [y.normal;   zeros(N,3)];         % Normal does not exist
% y.material = [y.material; repmat(matFoliage,N,1)];
% 



