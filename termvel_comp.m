clear
close all

%%
binmean_sbm = load('diamg_sbm.txt');
binmean_tau = load('diamg_tau.txt');
termvel_sbm=[0.50E-01 0.78E-01 0.12E+00 0.19E+00 0.31E+00 0.49E+00 ...
0.77E+00 0.12E+01 0.19E+01 0.30E+01 0.48E+01 0.74E+01...
0.11E+02 0.17E+02 0.26E+02 0.37E+02 0.52E+02 0.71E+02...
0.94E+02 0.12E+03 0.16E+03 0.21E+03 0.26E+03 0.33E+03...
0.41E+03 0.48E+03 0.57E+03 0.66E+03 0.75E+03 0.82E+03...
0.88E+03 0.90E+03 0.90E+03]/1e2;

for ibin=1:34
   if ibin>=1 && ibin<15
      beta(ibin)=2/3;
      alpha(ibin)=0.45795E+06;
   elseif ibin>=15 && ibin<25
      beta(ibin)=1/3;
      alpha(ibin)=4.962E+03;
   elseif ibin>=25 && ibin<32
      beta(ibin)=1/6;
      alpha(ibin)=1.732E+03;
   elseif ibin>=32
      beta(ibin)=0;
      alpha(ibin)=917;
   end
   AMS(ibin)=binmean_tau(ibin)^3*pi/6*1e3;
   termvel_tau(ibin)=alpha(ibin)*(AMS(ibin)*1000.)^beta(ibin)/1e2;
end

termvel_tau_new=interp1(binmean_sbm,termvel_sbm,binmean_tau,'spline');
termvel_tau_new=round(termvel_tau_new,2,'significant');
termvel_tau_new(end)=termvel_sbm(end);

loglog(binmean_sbm,termvel_sbm); hold on
loglog(binmean_tau,termvel_tau_new,'--')