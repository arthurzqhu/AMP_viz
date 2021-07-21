function ws=wsat(theta,pi,varargin)
%This function calculates saturated vapor mixing ratio from temperature (K)  
%and pressure (mb).  For saturated vapor mixing ratio over ice, pass an
%additional third argument (it can be literally anything).
%Created by Adele Igel - updated 6/2013

% L=2.5e6;
% if ~isempty(varargin)
%     L=2.83e6;
%     %Use this value for calculating ice saturation
% end
% Mw=18.016;
% Rstar=8.3145;
% 
T=temp(theta,pi);
p=press(pi);
% 
% es=6.11*exp(L*Mw/Rstar/1000*(1/273-1./T));
% 
% ws=.622*es./(p-es);

% es=6.1078*exp(17.269*(T-273.15)./(T-35.86));
% ws=.622*es./(p-es);

% RAMS specific calcuation
c0=0.6105851e3;
c1=0.4440316e2;
c2=0.1430341e1;
c3=0.2641412e-1;
c4=0.2995057e-3;
c5=0.2031998e-5;
c6=0.6936113e-8;
c7=0.2564861e-11;
c8=-0.3704404e-13;
 
x=max(-80,T-273.15);
 
es=c0+x.*(c1+x.*(c2+x.*(c3+x.*(c4+x*(c5+x*(c6+x*(c7+x*c8)))))));

% HUCM calculation
%x=T-273.15;
%es = 2.53e11*exp(-5.42e3./(x+273.15));

ws=0.622*es./(p*100-es);


