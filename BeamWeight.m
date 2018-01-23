% Beam steering weights for a node (node0) to communicate with another node (node1)
% H(freq,ant0,ant1,pol0,pol1)
% W0(ant0)
% And v.v. W1(ant1)
function [W0,W1]=BeamWeight(HS,pov0,pov1)

mode = 'CBF';

Nbit0 = pov0.agroup.nbit;
Nbit1 = pov1.agroup.nbit;

S0 = pov0.agroup.subarray;
S1 = pov1.agroup.subarray;

% Map on static sub-arrays
if numel(HS)==1,
    H = HS;
else
    H = ipermute(multiprod(multiprod(S0,permute(HS,[2,1,3,4,5]),[1,2]),S1.',[2,3],[1,2]),[2,1,3,4,5]);
end

if numel(H)==1,
    W0=1;
    W1=1;
else
    
    [Nf,N0e,N1e,N0p,N1p]=size(H);
    H0 = reshape(permute(H,[4,2,5,3,1]),[N0e*N0p,N1e*N1p,Nf]);
    H1 = reshape(permute(H,[5,3,4,2,1]),[N1e*N1p,N0e*N0p,Nf]);
    
    % Pick center freq (assume uniform freqs)
    % Average over far end
    cind = 1+round((Nf-1)/2);
    H0a = squeeze(mean(H0(:,:,cind),2));
    H1a = squeeze(mean(H1(:,:,cind),2));
    
    switch mode
        case 'CBF'
                        %w = mean(exp(-1j*angle(H)),1); % Conjugate of phase.

    %        W0 = mean(exp(1j*angle((H0a'))),1)'; % Conjugate beam forming.
    %        W1 = mean(exp(1j*angle((H1a'))),1); % Conjugate beam forming.
            W0 = (exp(1j*angle(mean(H0a',1))))'; % Conjugate beam forming.
            W1 = (exp(1j*angle(mean(H1a',1)))); % Conjugate beam forming.
            
        case 'LDL'
            
            % Covariance
            Cxx0 = cov(H0a');
            Cxx1 = cov(H1a');
            
            % Factorize
            L0 = ldl(Cxx0);
            L1 = ldl(Cxx1);
            
            % Get first vector
            W0 = L0(:,1);
            W1 = L1(:,1)';
            
            % Remove amplitude tapering
            W0 = exp(1j*angle(W0));
            W1 = exp(1j*angle(W1));
    end
    
    % Quantize phase
    if ~isempty(Nbit0)&&~isinf(Nbit0),
        dP0 = 2*pi/2^Nbit0;
        W0 = exp(1j*round(angle(W0)/dP0)*dP0);
    end
    if ~isempty(Nbit1)&&~isinf(Nbit1),
        dP1 = 2*pi/2^Nbit1;
        W1 = exp(1j*round(angle(W1)/dP1)*dP1);
    end
    
end

% Same subarray def for each polarisation
if pov0.agroup.dualpol && ~isscalar(S0), S0 = [S0,S0*0;S0*0,S0]; end;
if pov1.agroup.dualpol && ~isscalar(S1), S1 = [S1,S1*0;S1*0,S1]; end;

% Combine with static beamforming
W0 = (S0.')*W0;
W1 = W1*S1;

% Normalize for power
W0 = W0/norm(W0);
W1 = W1/norm(W1);


