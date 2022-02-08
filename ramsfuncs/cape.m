function anscape=cape(exner,thetav,theta,zu,qv)
%Calculate CAPE from PI,Virtual potential temperature, potential temperature,
%momentum height levels, and water vapor mixing ratio

thetap(1)=theta(1);
thetavp(1)=thetap(1)*(1+0.61*qv(1));
qs(1)=380/(1000e2*exner(1)^(1004/287))*exp(17.27*(thetap(1)*exner(1)-273)...
    /(thetap(1)-36));

for k=2:length(zu)
    if qs(k-1)<=qv(k-1)
        lcl=k;
        break
    else
        qv(k)=qv(k-1);
        thetap(k)=thetap(k-1);
        thetavp(k)=thetavp(k-1);
        qs(k)=380/(1000e2*exner(k)^(1004/287))*exp(17.27*(thetap(k)*exner(k)-273)/(thetap(k)-36));       
    end
end

lfc=0;
el=0;

for k=lcl:length(zu)
    thetap(k)=thetap(k-1);
    qv(k)=qv(k-1);
    qs(k)=380/(1000e2*exner(k)^(1004/287))*exp(17.27*(thetap(k)*exner(k)-273)/(thetap(k)-36));
    if qs(k)<=qv(k)
        phi=qs(k)*(17.27*237*2.536/(1004*(thetap(k)*exner(k)-36)^2));
        C=(qv(k)-qs(k))/(1+phi);
        thetap(k)=thetap(k)+2.5e6*C/(1004*exner(k));
        qv(k)=qv(k)-C;
    end
    thetavp(k)=thetap(k)*(1+.61*qv(k));
    if lfc==0 && thetavp(k)>=thetav(k)
        lfc=k;
    end
    
    if(el==0 && lfc~=0 && thetavp(k)<=thetav(k))
        el=k;
    end
end
anscape=0;
for k=lfc:el-1
    anscape=anscape+9.8*(thetavp(k)-thetav(k))/thetav(k)*(zu(k)-zu(k-1));
end
