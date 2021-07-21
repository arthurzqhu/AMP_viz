function tempv=virttemp(tempk,w)
%This function calculates virtual temperature from temperature (K) and 
%mixing ratio (g/g).
%Created by Adele Igel - updated 6/2013
e=0.622;

tempv=tempk.*(1+w/e)./(1+w);