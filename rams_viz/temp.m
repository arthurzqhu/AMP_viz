function T=temp(theta,pi,varargin)
%calculate temperature from RAMS output variables THETA and PI

cp=1004;
T=theta.*pi/cp;

if ~isempty(varargin) & varargin=='C'
    T=T-273.15;
end
