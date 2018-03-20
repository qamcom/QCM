function AddRemconFile(u,fname,maxRes)

zz=load(fname);
ff=fields(zz);
x=zz.(ff{1});

N=numel(x);

matWall     = GenericMaterial('CMU',1);
matRoof     = GenericMaterial('Wood',1);
matGround   = GenericMaterial('Street',0); 

pmax = -inf(1,3);
pmin =  inf(1,3);
for n=1:N
    xn = x(n);
    F = xn.nFaces;
    
    zmax = -inf;
    zmin = inf;
    for f=1:F
        xnf = xn.Face(f);
        cc = xnf.CornerCoord;
        zmax = max(zmax,max(cc(:,3)));
        zmin = min(zmin,min(cc(:,3)));
        pmax = max([pmax;cc]);
        pmin = min([pmin;cc]);
    end
    corners = [];
    for f=1:F
        fprintf('.')
        xnf = xn.Face(f);
        cc  = xnf.CornerCoord;
        
        if all(cc(:,3)==zmax)
            bh  = zmax-zmin;
            pos = min(cc);
            corners = cc(:,1:2)-pos(1:2);
        end
        
    end
    b0 = pos(3);
    pos(3)=0;
    if   ~isempty(corners)
        bldAtoms = BuildingStructure(corners,bh,maxRes,matWall,matRoof);
        u.AddAtoms(sprintf('Building%d',n),bldAtoms,pos);
        fprintf('B%d\n',n)
    end
    
end


gndAtoms = GroundStructure(pmax(1)-pmin(1),pmax(2)-pmin(2),maxRes,matGround);
u.AddAtoms(sprintf('Building%d',n),gndAtoms,[pmin(1:2) 0]);


% N=numel(x);
% for n=1:N
%     xn = x(n);
%     F = xn.nFaces;
% clf; hold on;
%     for f=1:F
%         fprintf('.')
%         xnf = xn.Face(f);
%         mat = matVector(xn.Material);
%         faceAtoms = Surface2Atoms(xnf.CornerCoord,mat,maxRes);
%         faceAtoms.Plot
%         axis equal
% %         patch(xnf.CornerCoord(:,1),xnf.CornerCoord(:,2),xnf.CornerCoord(:,3),'r','FaceAlpha',.5)
%         u.AddAtoms(sprintf('Building%d_Face%d',n,f),faceAtoms);
%     end
%     fprintf('\n')
%
% end