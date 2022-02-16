function rvar2phys(var_name)

global nfile outdir runs mpdat mp_list imp deltaz

threshold = -inf;

ispath=0;
isprof=0;
isproc=0;
israin=0;
iscloud=0;

% 

cwp=deltaz*squeeze((sum(runs.RCP,3)));
rwp=deltaz*squeeze((sum(runs.RRP,3)));
lwp=cwp+rwp;
rv=deltaz*squeeze((sum(runs.RV,3)));
rel_hum=rh(runs.RV,runs.THETA,runs.PI);

for ivar=1:length(var_name)
   varn=var_name{ivar};
   switch varn
   case 'CWP'
      mpdat(imp).(mp_list{imp}).(varn)=cwp;
   case 'RWP'
      mpdat(imp).(mp_list{imp}).(varn)=rwp;
   case 'LWP'
      mpdat(imp).(mp_list{imp}).(varn)=lwp;
   case 'CWP_da'
      mpdat(imp).(mp_list{imp}).(varn)=squeeze(mean(cwp,[1 2]));
   case 'RWP_da'
      mpdat(imp).(mp_list{imp}).(varn)=squeeze(mean(rwp,[1 2]));
   case 'LWP_da'
      mpdat(imp).(mp_list{imp}).(varn)=squeeze(mean(lwp,[1 2]));
   case 'Rv_da'
      mpdat(imp).(mp_list{imp}).(varn)=deltaz*squeeze((sum(runs.RV,3)));
   case 'RH_da'
      mpdat(imp).(mp_list{imp}).(varn)=squeeze(mean(rel_hum,[1 2 3]));
   end
end
