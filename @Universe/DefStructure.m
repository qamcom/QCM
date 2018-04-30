% (re)Define Structure in universe
% DefStructure(u,index,enabled,tag,structure,res,pos,rot,velocity)
function DefStructure(u,index,enabled,tag,structure,res,pos,rot,velocity)

if ~exist('tag','var')||isempty(tag), tag=u.objects(index).tag; end
if ~exist('structure','var')||isempty(structure), structure=u.objects(index).structure; end
if ~exist('enabled','var')||isempty(enabled), enabled=u.objects(index).enabled; end
if ~exist('res','var')||isempty(res), res=u.objects(index).res; end
if ~exist('pos','var')||isempty(pos), pos=u.objects(index).pos; end
if ~exist('rot','var')||isempty(rot), rot=u.objects(index).rot; end
if ~exist('velocity','var')||isempty(velocity), velocity=u.objects(index).velocity; end


atoms = Atoms;

% Points
pts = structure.points;
structure.p0 = mean(pts);

% Clouds to Atoms (3D)
Ns = numel(structure.clouds);
for s = 1:Ns
    ss  = structure.clouds{s};
    spi = ss.pi;
    sps = pts(spi,:);
    mat = ss.material;
    rad = ss.radius;
    den = ss.density;
    
    for p = 1:numel(rad)
        
        % Tile this bubble      
        grid = -rad(p):res/den:rad(p); grid = grid-mean(grid);
        [xx,yy,zz]=meshgrid(grid,grid,grid);
        ind = find(vnorm([xx(:),yy(:),zz(:)],2)<rad(p));
        nc = numel(ind);
        if nc<=1
            resp=rad*2*den;
            cpos = sps;
            nc=1;
        else
            resp=res;
            cpos = VectorAdd([xx(ind),yy(ind),zz(ind)],sps);
        end
        
        % Each atom is defined by:
        %   normal:     3D vector perpendicular to atom surface. Length=res/2
        %   surface:    3D coordinate of atom surface center
        %   material:   instance of classdef Material
        %   corner:     2 angles. Corner opening, and corner orientation
        %   res:        Atom size (1D: res=corner length, 2D: res^2 = area,
        b = Atoms(zeros(nc,3),cpos,repmat(mat,nc,1),zeros(nc,2),repmat(resp,nc,1),repmat(velocity,nc,1));
        
        atoms  = cat(atoms,b);
    end
end

% Polygons to Atoms (2D)
Ns = numel(structure.surfaces);
for s = 1:Ns
    ss  = structure.surfaces{s};
    spi = ss.pi;
    sps = pts(spi,:);
    mat = ss.material;
    % Tile this surface
    b  = Surface2Atoms(sps,mat,res);
    atoms  = cat(atoms,b);
end

% Corner Lines to Atoms (1D)
Nc = numel(structure.corners);
for c=1:Nc
    
    % Parse this corner (position, orientation and opening)
    cc    = structure.corners{c};
    pc    = pts(cc.pi,:); % 2x 3D points of corner
    pcc   = mean(pc);     % Corner center (3D pt)
    cpn   = diff(pc);     % Corner plane normal (3D vector // corner)
    if isempty(cc.si)
        % Corner not defined by surfaces. Just a diffracting 1D structure
        alfa = pi;
        beta = 0;
        cn = PerpendicularVector(pcc);
    else
        % Surface corner
        si0   = cc.si(1);     % One side of corner (surface index)
        si1   = cc.si(2);     % Other side of corner (surface index)
        s0pi  = structure.surfaces{si0}.pi; % One side of corner (point index)
        s1pi  = structure.surfaces{si1}.pi; % Other side of corner (point index)
        s0p   = pts(s0pi,:);   % One side of corner (3D points of surface poly)
        s1p   = pts(s1pi,:);   % Other side of corner (3D points of surface poly)
        ind0(1)  = FindPt(s0p,pc(1,:));
        ind0(2)  = FindPt(s0p,pc(2,:));
        ind1(1)  = FindPt(s1p,pc(1,:));
        ind1(2)  = FindPt(s1p,pc(2,:));
        ss0p  = ShrinkPolygon(s0p);
        ss1p  = ShrinkPolygon(s1p);
        ms0p  = mean(ss0p(ind0,:));
        ms1p  = mean(ss1p(ind1,:));
        pc0   = pcc-ms0p;     % Center of one side _to_ Corner Center (3D vector)
        pc1   = pcc-ms1p;     % Center of other side _to_ Corner Center (3D vector)
        cpn   = diff(pc);     % Corner plane normal (3D vector // corner)
        pc0p  = VectorOnPlane(pc0,cpn); % Projection on corner plane (// to plane)
        pc1p  = VectorOnPlane(pc1,cpn); % Projection on corner plane (// to plane)
        pc0pn = pc0p/norm(pc0p); % // to one side. Unit length
        pc1pn = pc1p/norm(pc1p); % // to other side. Unit length
        cn    = (pc0pn+pc1pn)/norm(pc0pn+pc1pn); % Corner normal (3D vector).
        alfa  = pi-AngleDiff(pc0pn,pc1pn); % Corner angle (0=surface)
        beta  = Line2Corner(cpn,cn); % Corner orientation (0=vertical)
    end
    mat   = cc.material;
    
    %     % Tile this corner
    lenc = norm(cpn);
    resc = min(res,lenc);
    nc   = ceil(lenc/resc);
    resc = lenc/nc;
    cpos = zeros(nc,3);
    for n=1:nc
        cpos(n,:)=pc(1,:)+cpn*(n-0.5)/nc;
    end
    
    % Each atom is defined by:
    %   normal:     3D vector perpendicular to atom surface. Length=res/2
    %   surface:    3D coordinate of atom surface center
    %   material:   instance of classdef Material
    %   corner:     2 angles. Corner opening, and corner orientation
    %   res:        Atom size (1D: res=corner length, 2D: res^2 = area,
    b = Atoms(repmat(cn,nc,1),cpos,repmat(mat,nc,1),repmat([alfa,beta],nc,1),repmat(resc,nc,1),repmat(velocity,nc,1));
    atoms = cat(atoms,b);
    
    
end

% Move globally and Add some stuf
nAtom = size(atoms.normal,1);
atoms.normal  = RotateVectorZ(atoms.normal,rot);
atoms.surface = RotateVectorZ(atoms.surface,rot)+repmat(pos,nAtom,1);
if isempty(atoms.velocity)
    atoms.velocity = zeros(nAtom,3);
end

pts = structure.points;
structure.p0 = mean(pts);

% Add to universe--------------------------------------------------------

% Clear LOS cache
u.ResetLOS;

% Add this structure to database
u.objects(index).enabled = enabled;
u.objects(index).tag = tag;
u.objects(index).atoms   = atoms;
u.objects(index).atoms0  = atoms; % For Nudge fcn
u.objects(index).structure = structure;
u.objects(index).res = res;
u.objects(index).pos = pos;
u.objects(index).rot = rot;
u.objects(index).velocity = velocity;


u.nrofObj   = index;
u.nrofAtoms = u.nrofAtoms+nAtom;

