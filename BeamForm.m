% Beam steering for a node (node0) to communicate with another node (node1)
function HW=BeamForm(HS,W0,W1)

[Nf,N0e,N1e,N0p,N1p]=size(HS);
H0 = reshape(permute(HS,[4,2,5,3,1]),[N0e*N0p,N1e*N1p,Nf]);
HW = squeeze(multiprod(multiprod(W0',H0),W1.'));
