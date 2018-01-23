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

function y=Skew(x,d,N)

K = size(x,1);
y = nan(size(x));

if nargin<3, N=3; end

for k=1:K,
    xk = x(k,:);
    dk = d(k);
    
    M = ceil(abs(dk)+(N-1)/2);
    Dk = floor(dk);
    dk = dk-Dk;
    
    %xx = [-flipud(x(2:M))+2*x(1);x;-(x(end-1:-1:end-M+1))+2*x(end)];
    xx = [repmat(xk(1),M-1,1);xk(:);repmat(xk(end),M,1)];
    
    n =-(N-1)/2:(N-1)/2;
    h = sinc(n+dk).*hamming(N);
    h = h/sum(h);
    
    yy = filter(h,1,xx);
    
    y(k,:) = yy(Dk+M+(N-1)/2+(0:length(xk)-1));
end
