% Basic Algorithm Model
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

classdef BasicUEAlgorithm < Algorithm
    
    properties (SetAccess = private)
        tag = 'BasicUE'; % Identifier string
    end
       
    methods 
        
        function O = OrthoTest(a,H) % Checking orthogonality btw links (btw BSs)
            error('Not implemented.');
        end
        
        % H(ant-tx,ant-rx,freq-bin,time-bin)
        % P(ant-tx,stream-tx,freq-bin,time-bin)
        function P = DesignPrecoder(a,H)
            error('Not implemented.')
        end
        
        % H(ant-tx,ant-rx,freq-bin,time-bin)
        % P(ant-tx,stream-tx,freq-bin,time-bin)
        % Hp(ant-rx,stream-tx,freq-bin,time-bin)
        function Hp = Precode(a,H,P)
            Hp = multiprod(Htmp,P,[1,2]);
        end

        
        % Hp(ant-rx,stream-tx,freq-bin,time-bin)
        % NF, Rx Noise Figure [dB]
        % BW, Bandwidth [Hz]
        % E(stream-rx,ant-rx,freq-bin,time-bin)
        % NOTE: Power level normalized to noise floor (noise power = 1)
        function E = DesignEqualizer(a,Hp,NF,BW)
            [Nr,Ns,Nf,Nt]=size(Hp);

            pn0 = 4*sys.kB*sys.T*BW;    % Ideal noise floor [Watt]
            pn = pn0*10^(NF/20);        % Recieiver noise power [Watt]
            alfa = pn;
            
            E = nan([Ns,Nr,Nf,Nt]);
            for f=1:Nf
                for t=1:Nt
                    Hf = squeeze(Hp(:,:,f,t));
                    Ef = Hf'/(Hf*Hf'+alfa*eye( Nr));
                    E(:,:,f,t)=Ef/norm(Ef,'fro')/sqrt(pn);
                end
            end
        end

        % Hp(ant-rx,stream-tx,freq-bin,time-bin)
        % E(stream-rx,ant-rx,freq-bin,time-bin)
        % He(stream-rx,stream-tx,freq-bin,time-bin)
        function He = Equalize(a,Hp,E)
            He = multiprod(E,Hp,[1,2]);
        end


    end
    
end
