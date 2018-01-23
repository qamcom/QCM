% Angle diff vs boresight of a number of rays
%
% [elevation, azimuth] = AngleOffDOV(DOV,NOV,path)
%
% DOV:          3D vector [x y z] Direction of view (Greenwich meridian = boresight)
% NOV:          3D vector [x y z] Normal of view (North pole)
% path:         3D vectors of paths vs POV
% elevation:    Angle of rays vs NOV [radians]
% azimuth:      Angle of rays vs DOV [radians]
%
% Assume an antenna element directed in the path of DOV (direction-of-view)
% Assume it's oriented with its "up" in the path of NOV (normal-of-view)
% NOV _|_ DOV
% Here we calculate how path vectors are deviating from the DOV
% Both in elevation and azimuth (vs DOV and NOV)
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

function [elevation, azimuth] = AngleOffDOV(DOV,NOV,path)

% % Elevation of path is the angle vs the Equator (defined by NOV)
% elevation = pi/2-AngleDiff(path,NOV);
% 
% % Azimuth of path is the path projected on the equator plane, 
% % and its subsequent angle vs the Greenwich meridian (i.e DOV)
% path2D  = VectorOnPlane(path,NOV);
% azimuth = AngleDiff(path2D,DOV);

 
% Per Z. Incl sign.    
path2D    = VectorOnPlane(path,NOV);
elevation = atan( ((path-path2D)*NOV')./ vnorm(path2D,2) );
    
% Basis vector orthotogonal to both NOV and DOV 
NOV2              = cross(NOV,DOV);
    
path2D_along_DOV  = DOV*path2D';
path2D_along_NOV2 = NOV2*path2D';
    
path2D_along_DOV  = path2D_along_DOV.';
path2D_along_NOV2 = path2D_along_NOV2.';
    
azimuth = angle(path2D_along_DOV+1j*path2D_along_NOV2);

azimuth(isnan(azimuth))=pi;
elevation(isnan(elevation))=0;
