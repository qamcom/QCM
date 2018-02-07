function y=FullArray(f0)

Nv        = 8;
Nh        = 16;
Ns        = 1;  
spacingV  = 0.75;
spacingH  = 0.75;
pol       = pi/4;
element   = Element('isotropic');
nbit      = inf;

lambda    = sys.c/f0;

[hp,vp]   = meshgrid(spacingH*(-(Nh-1)/2:(Nh-1)/2),spacingV*(-(Nv-1)/2:(Nv-1)/2));
array     = [hp(:),vp(:)]*lambda; % Array config H,V


% Static combination elements
subarrays = reshape(permute(repmat(eye(Nh*Nv/Ns),[1,1,Ns]),[3,1,2]),Nv*Nh,[])';

y = Array('FullArray',array,element,pol,subarrays,nbit);