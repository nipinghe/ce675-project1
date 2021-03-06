function [K]=Stiff_L(plane_for,ndof,nnode,nsdof,X,nel,nodes,t,nnel_v,mat_set_v,mat_list,disp)


K=zeros(nsdof);
%--------------------------------------------------------------------------
% Calculate Tangent Stiffness Matrix
%--------------------------------------------------------------------------
zp=zeros(ndof);
for el_no=1:nel
    mat_no = mat_set_v(el_no); 
    nnel = nnel_v(el_no); 
    
    [nnel,Xe,ii] = localize(el_no,X,nodes,nnel_v,ndof);
    [ngp,cgp,wgp]=gauss(nnel,ndof);

    Ke=zeros(nnel*ndof);
    B=zeros(3,nnel*ndof);
    
    [D]=linear_material_tangent(plane_for,mat_no,mat_list);
    for ip=1:ngp
        zp=cgp(ip,:);
        [Nz,dNz]=shapefn(zp,nnel,ndof);
        dXz_T=dNz*Xe;   % transpose(DX/Dz)
        dXzi_T=dXz_T^(-1);% transpose(Dz/DX)
        JX=det(dXz_T);
        DNe=dXzi_T*dNz;
        for i=1:nnel
            B(1,2*i-1)=DNe(1,i);
            B(2,2*i)=DNe(2,i);
            B(3,2*i-1)=DNe(2,i);
            B(3,2*i)=DNe(1,i);
        end
        k0=transpose(B)*D*B;
        k0=k0.*t.*JX.*wgp(ip);
        K(ii,ii)=K(ii,ii)+k0;
    end
end
%F_int = K*disp;
