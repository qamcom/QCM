% Add Structure to universe
% Will be tiled into atoms.
% x.point(pi,1:3) XYZ coord of Points in structure
% x.surface{si}.pi(1:N): List of point-index vectors. N >= 3. Defines a Polygon
% x.corner{ci}.si(1:2):  Index of Two surfaces defining the corner.
% x.corner{ci}.pi(1:2):  Index of Two points defining the corner.
% res: Maximum tile size. [m]
% pos: Global position (XYZ)
% rot: Azimuth rotation (rad)
function AddStructure(u,tag,structure,res,pos,rot,velocity)


if ~exist('pos','var')||isempty(pos), pos=[0,0,0]; end
if ~exist('rot','var')||isempty(rot), rot=0;       end
if ~exist('velocity','var')||isempty(velocity), velocity=[0 0 0];       end

atoms = Atoms;

% Points
pts = structure.points;
structure.p0 = mean(pts);

% Polygons to Surface Atoms
Ns = numel(structure.surfaces); 
atomOffset = 0;
for s = 1:Ns
    ss  = structure.surfaces{s};
    spi = ss.pi;
    sps = pts(spi,:);
    mat = ss.material;                
    % Tile this surface
    b  = Surface2Atoms(sps,mat,res);
    atoms  = cat(atoms,b);

    nrofAtoms = length(b);
    structure.surfaces{s}.firstAtom = atomOffset+1;
    structure.surfaces{s}.nrofAtoms = nrofAtoms;
    atomOffset = atomOffset+nrofAtoms;
end

% Lines to Corner Atoms
Nc = numel(structure.corners);
for c=1:Nc
    
    % Parse this corner (position, orientation and opening)
    cc    = structure.corners{c};
    pc    = pts(cc.pi,:); % 2x 3D points of corner
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
    pcc   = mean(pc);      % Corner center (3D pt)
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
 
    nrofAtoms = length(b);
    structure.surfaces{s}.firstAtom = atomOffset+1;
    structure.surfaces{s}.nrofAtoms = nrofAtoms;
    atomOffset = atomOffset+nrofAtoms;
    
end

% Move globally and Add some stuf
nAtom = size(atoms.normal,1);
atoms.normal  = RotateVectorZ(atoms.normal,rot);
atoms.surface = RotateVectorZ(atoms.surface,rot)+repmat(pos,nAtom,1);
if isempty(atoms.velocity)
    atoms.velocity = zeros(nAtom,3);
end

structure.points = RotateVectorZ(structure.points ,rot)+pos;
pts = structure.points;
structure.p0 = mean(pts);
structure.velocity = velocity;

% Add to universe--------------------------------------------------------

% Clear LOS cache
u.ResetLOS;

% Add this structure to database
nn = u.nrofObj+1;
u.obj(nn).tag = tag;
u.obj(nn).atoms   = atoms;
u.obj(nn).atoms0  = atoms; % For Nudge fcn
u.obj(nn).firstAtom = u.nrofAtoms+1;
u.obj(nn).nrofAtoms = nAtom;
u.obj(nn).structure = structure;
inds = u.nrofAtoms+(1:nAtom);

u.nrofObj   = nn;
u.nrofAtoms = u.nrofAtoms+nAtom;

