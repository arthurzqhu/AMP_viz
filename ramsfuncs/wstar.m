function [wice,wcloud]=wstar(Nrw,Nri,T,p,qv)

%constants
g=9.8;
cp=1004;
Rv=461.5;
Ra=287;
Lv=2.5e6;
Ls=2.834e6;
rhoi=500;
rhow=1000;

%thermal conductivity and vapor diffusion coefficient based on Pruppacher
%and Klett
k=(3.78+0.02*T)*4.184e-3;
D=0.211*(T/273.15).^1.94.*(1013.25./p)/10000;

rhoa=p./(Ra*virttheta(T,qv))*100;

Ew=6.11*exp(17.15*(T-273.15)./(T-38.25));
Ei=6.11*exp(21.88*(T-273.15)./(T-7.65));

a0=g./(Ra*T).*(Lv*Ra./(cp*Rv*T)-1);
a1=1./qv+Lv^2./(cp*Rv*T.^2);
a2=1./qv+Lv*Ls./(cp*Rv*T.^2);
Ai=(rhoi*Ls^2./(k.*Rv.*T.^2)+rhoi*Rv*T./(Ei.*D)).^(-1);
Aw=(rhow*Lv^2./(k.*Rv.*T.^2)+rhow*Rv*T./(Ei.*D)).^(-1);
Bi0=4*pi*rhoi*Ai./rhoa;
Bw=4*pi*rhow*Aw./rhoa;

nu=a2.*Bi0./a0;
chi=a1.*Bw./a0;

Nri=Nri.*rhoa/1000; %Units should be 1/m2
Nrw=Nrw.*rhoa/1000000;

wcloud=(Ew-Ei)./Ei.*nu.*Nri;

wice=(Ei-Ew)./Ew.*chi.*Nrw;