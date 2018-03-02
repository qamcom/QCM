% Abstract Algorithm Model
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

classdef Algorithm < handle
    
    properties (Abstract, SetAccess = private)
        tag   % Identifier string
    end
       
    methods (Abstract)
        O  = OrthoTest(a,R); % Checking orthogonality btw links
        P  = DesignPrecoder(a,H); 
        E  = DesignEqualizer(a,H); 
        Hp = Precode(a,H,P); 
        He = Equalize(a,H,E); 
    end
    
end
