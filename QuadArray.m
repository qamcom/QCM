function y=QuadArray(f0)

array  = FullArray(f0);
arrays = {array, array, array, array};

ap = array.aperture;

dw = mean(diff(unique(array.array(:,2))));
dh = mean(diff(unique(array.array(:,3))));
w = ap(1)+dw;
h = ap(2)+dh;


%ArrayGroup(tag,arrays,positions,elevations,azimuths,rotations,dualpol)
y = ArrayGroup(mfilename,arrays,[0 w -h; 0 -w -h; 0 w h;0 -w h]/2,[0 0 0 0],[0 0 0 0],[0 0 0 0],1);
