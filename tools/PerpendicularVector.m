function [x,y,z]=PerpendicularVector(z)

z=z/norm(z);

dd=0;
while dd==0, x=randn(1,3); dd=dot(z,x); end

y=cross(z,x); 
x=cross(y,z);

