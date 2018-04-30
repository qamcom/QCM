% Check if LOS btw POV pairs. 
%
% LOS = CheckLOS(u,POV0s,POV1s,range)
% u is an handle to a Universe class (this class)
% POV0s, POV1s: [x,y,z] Coordinates of point-of-view [m]
% LOS:       (1=no shading, 0=no LOS )
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

function LOS = CheckLOS(u,POV0s,POV1s,range)

s = u.GetStructures;

N0  = size(POV0s,1);
N1  = size(POV1s,1);
LOS = ones(N0,N1);

for n0=1:N0    
    for n1=1:N1       
        LOS(n0,n1) = FindCore(POV0s(n0,:),POV1s(n1,:),s,range);
    end
end



