function ptmask = FindCore(x,POV,s,range)

N = size(x,1);

if N
    
    % Atoms vs LOS point (Put POV in origo)
    x0 = VectorAdd(x,-POV);
    % Pruning atoms with surface points in shade
    ptmask = ones(N,1)==1;
    ptmask(vnorm(x0,2)>range)=0;
    
    % Sort shading structures, so closest comes first
    % Tese are most likely to cast shade onm any others
    % Quickly reducing remaining atoms to trace during first iterations
    p0   = VectorAdd(reshape([s.p0],3,[])',-POV);
    r0 = vnorm(p0,2);
    [~,sortS] = sort(r0);
    
    for ii = sortS(r0<range)'
        points   = s(ii).points;
        surfaces = s(ii).surfaces;
        clouds = s(ii).clouds;
        for ss = 1:length(surfaces)
            if any(ptmask)
                surface = surfaces{ss};
                p = VectorAdd(points(surface.pi,:),-POV);
                behind = BehindPolygon(p,x0(ptmask,:));
                ptmask(ptmask)=~behind;
            else
                break
            end
        end
        for cc = 1:length(clouds)
            if any(ptmask)
                cloud = clouds{cc};
                r = cloud.radius;
                p = VectorAdd(points(cloud.pi,:),-POV);
                behind = BehindSphere(p,r,x0(ptmask,:));
                ptmask(ptmask)=~behind;
            else
                break
            end
        end
    end
else
    ptmask = [];
end