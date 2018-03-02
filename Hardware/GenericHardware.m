% Hardware model
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

classdef GenericHardware < Hardware
    
    % Abstract in parent class
    properties (SetAccess = private)
        tag     = 'Default';   % Identifier string
        power   = 30;   % [dBm]  Output power per branch
        nf      = 6;    % [dB]   Noise figure
        bw      = 18e6  % [Hz]   Bandwidth
        fc      = 3.5e9 % [Hz]   Center frequency
    end
    
    methods
        
        % Constructor
        function h=GenericHardware(tag,power,nf,bw,fc)
            if nargin
                
                h.tag     = tag;   % Identifier string
                h.power   = power; % [dBm]  Output power per branch
                h.nf      = nf;    % [dB]   Noise figure
                h.bw      = bw;    % [Hz]   Bandwidth
                h.fc      = fc;    % [Hz]   Center frequency
            end
        end
        
        % x is an actual bb signal to transmit, if excluded all ones is used to get the eq response
        function y = Transmit(h,freqs,x)
            y = x;
        end
        
        % x is an actual received bb signal, if excluded all ones is used to get the eq response
        function y = Receive(h,freqs,x)
            y = x;
        end
        
    end
    
end



