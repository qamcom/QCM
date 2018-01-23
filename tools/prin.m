function y=prin(x)
tol = pi/1000000;
y=mod(x,2*pi);
ind = find(y>=pi-tol);
y(ind)=y(ind)-2*pi;