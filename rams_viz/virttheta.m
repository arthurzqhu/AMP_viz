function thetav=virttheta(theta,rv)
%Calculate virtual potential temperature from THETA and RV

e=0.622;

thetav=theta.*(1+rv/e)./(1+rv);
