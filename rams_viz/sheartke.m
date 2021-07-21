function sf=sheartke(wind,dz,Kh)

[~,~,sf]=gradient(wind,dz);
sf=sf.^2.*-Kh;