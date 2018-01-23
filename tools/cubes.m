% This function renders cubes at various spatial locations.
% It uses a single PATCH call which is the MOST efficient way to
% render lots of data.
%
% EXAMPLE: cubes(rand(1,10),rand(1,10),rand(1,10),rand(10,3));
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

function cubes(X0,Y0,Z0,C0,S)

if numel(S)==1, S=S*ones(size(X0)); end

sizes=unique(S);
for box_sz = sizes(:)'
    ind = find(box_sz==S);
    N=length(ind);
    X = X0(ind,:);
    Y = Y0(ind,:);
    Z = Z0(ind,:);
    C = C0(ind,:);
    
    f =nan(6*N,4);
    v =nan(8*N,3);
    fc=nan(6*N,3);
    
    v1=[-box_sz/2 +box_sz/2 +box_sz/2 -box_sz/2 -box_sz/2 +box_sz/2 +box_sz/2 -box_sz/2]';
    v2=[-box_sz/2 -box_sz/2 +box_sz/2 +box_sz/2 -box_sz/2 -box_sz/2 +box_sz/2 +box_sz/2]';
    v3=[-box_sz/2 -box_sz/2 -box_sz/2 -box_sz/2 +box_sz/2 +box_sz/2 +box_sz/2 +box_sz/2]';
    vv = [v1 v2 v3];
    XX = repmat(X',8,1);
    YY = repmat(Y',8,1);
    ZZ = repmat(Z',8,1);
    for k=0:N-1
        
        % Cube definitions
        faces=[1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8]+8*k;
        f(k*6+(1:6),:) = faces;
        v(k*8+(1:8),:) = vv+[XX(:,k+1),YY(:,k+1),ZZ(:,k+1)];
        fc(k*6+(1:6),1)= (C(k+1,1));
        fc(k*6+(1:6),2)= (C(k+1,2));
        fc(k*6+(1:6),3)= (C(k+1,3));
    end
    
    patch('Vertices',v,'Faces',f,'FaceVertexCData',fc,'FaceColor','Flat','FaceColor','flat'); axis equal;
end


