% Universe System Constants
%
% To see all constants. Type >> sys
% To access a single constant refer with dot, eg sys.enableLOS
% Values can only be changed in this file. NOT during runtime
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

classdef sys
   properties (Constant)
      maxRadius             = 400; % Max raytracing range [m]
      largeScaleResolution  = 1;   % Grid spacing, for retracing rays (shading) [m] 
      c                     = 3e8; % Speed of light [m/s]
      kB                    = 1.38e-23; % J/K, Boltzmann
      T                     = 290; % [K] System temp
      raySelThreshold       = 50;  % Discard rays weaker than this value vs strongest ray [dB] 
      secondOrderRange      = 30;  % Don't look further than this to find 2nd bounce [m]
      secondOrderPaths      = 100; % Max nrof second order path endpoints
      enableDopplerSpread   = 0;   % 1 => Model doppler of each ray. 0 => don't
      enableLOS             = 1;   % Trace first order path (LOS) if enabled (=1)
      forceLOS              = 0;   % Ensure LOS channel. Disregard any shading for LOS path. Overrides "enableLOS"
      enableNLOS            = 1;   % Trace second order paths if enabled (=1)
      enableN2LOS           = 1;   % Trace 3rd order paths if enabled (=1)
      enableN3LOS           = 0;   % Use stochastic model for >3rd (and 2nd if disabled) order paths if enabled (=1). 
      quickTrace            = 1;   % Somewhat faster ray tracing, some infrequent mistakes possible
      bubbleTrace           = 1;   % Use shading spheres (bubbles) for faster ray tracing
      forceNoScattering     = 0;
      forceNoDiffraction    = 0;
      forceNoReflection     = 0;
      forceNoCorners        = 0;
      forceNoPenetration    = 1;
      plotCornerPatches     = 0;
      plotAtomNormals       = 0;
      plotSurfacePatches    = 1;
      plotShadingSpheres    = 0;
   end
end