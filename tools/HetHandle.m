% Class to represent a hetero handle class, that can be sorted etc
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

classdef HetHandle < handle & matlab.mixin.Heterogeneous
    
    properties (SetAccess = private)
        id
    end
    
    
    methods
        function x = HetHandle
            x.id = UniqueToken;
        end
        function delete(x)
            UniqueToken(x.id);
        end
        
    end
    
    methods (Sealed)
        
        function [y,sets]=unique(xArray)
            ids = [xArray.id];
            [uid,inds]=unique(ids);
            y=xArray(inds);
            if nargout>1
                for k=1:numel(inds)
                    sets{k}=find(ids==uid(k));
                end
            end
        end
        
        function y=eq(x0,x1)
            y=([x0.id]==[x1.id]);
            y=y(:);
        end
    end
    
end

function x=UniqueToken(remove)
persistent active
if nargin
    active = setdiff(active,remove);
end
if nargout
    if ~isempty(active)
        free = setdiff(1:max(active)+1,active);
        x    = min(free);
        active(end+1)=x;
    else
        x      = 1;
        active = 1;
    end
end
end

