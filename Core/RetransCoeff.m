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
function y = RetransCoeff(freqs,materials,corners,elevation0,elevation1,azimuth0,azimuth1,pol0,pol1,radius0,radius1,res)

% Expand any scalar
N=max([numel(materials) numel(elevation0) numel(elevation1) numel(azimuth0) numel(azimuth1)]);
materials(end+1:N,1)  = materials(end,1);
elevation0(end+1:N,1) = elevation0(end,1);
elevation1(end+1:N,1) = elevation1(end,1);
azimuth0(end+1:N,1)   = azimuth0(end,1);
azimuth1(end+1:N,1)   = azimuth1(end,1);
pol0(end+1:N,1)       = pol0(end,1);
pol1(end+1:N,1)       = pol1(end,1);

% Check which are surfaces and corners
cornerFlag  = (corners(:,1)> 0); % If positive, we are dealing with a convex corner.
surfaceFlag = (corners(:,1)==0); % If zero, we are dealing with a surface.

y = zeros(numel(materials),numel(freqs));

[umat,smat]=unique(materials);
for k=1:numel(umat)
    
    material = umat(k);
    ind      = smat{k};
    
    % Surfaces
    indS = ind(surfaceFlag(ind));
    if numel(indS)
        y(indS,:) = material.SurfaceCoeff(freqs,...
            radius0(indS),radius1(indS),...
            elevation0(indS),elevation1(indS),...
            azimuth0(indS),azimuth1(indS),...
            pol0(indS),pol1(indS),...
            res(indS));
    end
    
    % Corners
    if ~sys.forceNoDiffraction
        indC = ind(cornerFlag(ind));
        if numel(indC)
            y(indC,:) = material.CornerCoeff(freqs,...
                corners(indC,1),...
                radius0(indC),radius1(indC),...
                elevation0(indC),elevation1(indC),...
                azimuth0(indC),azimuth1(indC),...
                pol0(indC),pol1(indC),...
                res(indC));
        end
    end
end

