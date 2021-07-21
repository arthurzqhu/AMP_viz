function RH=rh(rv,theta,pi,varargin)
%Calculate RH from RAMS output variables RV, THETA, and PI

%tempk=temp(theta,pi);
%p=press(pi);
ws=wsat(theta,pi,varargin);

RH=rv./ws*100;
