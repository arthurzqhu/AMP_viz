function [S,B]=tkerate(u,v,w,theta,Km)
g=9.8;

tke=.5*(u.^2+v.^2+w.^2);
[dudz,dvdz,dthdz]=deal(zeros(size(u)));
for k=1:40
    [dudz(:,:,k,:)]=gradient(u(:,:,k,:),50);
    [dvdz(:,:,k,:)]=gradient(v(:,:,k,:),50);
    [dthdz(:,:,k,:)]=gradient(theta(:,:,k,:),50);
end

S=Km.*dudz.^2+Km.*dvdz.^2;

B=-3*Km.*dthdz*g/260;
