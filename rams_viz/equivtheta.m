function thetae=equivtheta(theta,pi,rv)
%Calculate equivalent potential temperature
%From Bryan 2008.  In final calculation, should use pressure of dry air,
%not total pressure.
cp=1004;
R=287;
Rv=461.5;
L0=2.555e6;

temp=theta.*pi/cp;
pres=1000*(pi/cp).^(cp/R);

RH=rv./wsat(temp,pres);

thetae=temp.*(1000./pres).^(R/cp).*RH.^(Rv*rv/cp).*exp(L0*rv./(cp*temp));

