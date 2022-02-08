function sf=scalarflux(scalar,dz,Kh)

[~,~,sf]=gradient(scalar,dz);
sf=sf.*-Kh;