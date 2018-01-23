function y=DistArray(f0,d)

array  = FullArray(f0);
arrays = {array, array, array, array};


%ArrayGroup(tag,arrays,positions,elevations,azimuths,rotations,dualpol)
y = ArrayGroup(mfilename,arrays,[0 -3 0; 0 -1 -0; 0 1 0;0 3 0]*d/2,[0 0 0 0],[0 0 0 0],[0 0 0 0],1);
