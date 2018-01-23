function [side0,side1,pos,rot]=align_box(x)

% Simpler and faster with complex 
c   = complex(x(:,1),x(:,2));
pos = mean(c(1:4));

% Find long and short sides
side0 = mean(c([2 3])-c([1 4]));
side1 = mean(c([3 4])-c([2 5]));

% Align to a parallel sides, with perpendicular corners
rot = angle(side0+1j*side1);
side0 = abs(side0);
side1 = abs(side1);

if side0>side1
    xx    = side0;
    side0 = side1;
    side1 = xx;
    rot   = rot+pi/2;
end

% Back from complex
pos = [real(pos),imag(pos)]; 