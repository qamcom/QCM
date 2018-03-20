% Check if LOS btw POV pairs. Returns a soft value if partly shaded
%
% LOS = CheckLOS(u,POV0s,POV1s)
% u is an handle to a Universe class (this class)
% POV0s, POV1s: [x,y,z] Coordinates of point-of-view [m]
% inds: Atom indece to exclude from search
% LOS:      Matrix with scalar amplitude values (1=no shading, 0=no LOS at all)
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

function LOS = FindNLOS(u,POV0s,POV1s)


N0  = size(POV0s,1);
N1  = size(POV1s,1);

LOS = zeros(N0,N1);
if N0>N1
    all1 = 1:N1;
    for n0=1:N0
        los0 = u.FindLOS(POV0s(n0,:));
        LOS(n0,intersect(all1,los0)) = 1;
    end
else
    all0 = 1:N0;
    for n1=1:N1
        los1 = u.FindLOS(POV1s(n1,:));
        LOS(intersect(all0,los1),n1) = 1;
    end
end
