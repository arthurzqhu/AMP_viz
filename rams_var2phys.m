function rams_var2phys(var_name,var_req)

global nfile outdir runs mpdat mp_list imp

threshold = -inf;

ispath=0;
isprof=0;
isproc=0;
israin=0;
iscloud=0;

var_num=length(var_name);
load_list={};

% load the variables
for ivar=1:var_num
   req_num=length(var_req{ivar});
   for ireq=1:req_num
      if contains(var_req{ivar}{ireq},load_list)
         continue
      end
      load_list{end+1}=var_req{ivar}{ireq};
   end
end

rams_hdf5c(load_list,0:nfile-1,outdir)
mpdat(imp,1).(mp_list{imp})=runs;

% 
for varn=var_name
switch varn
case 'CWP'
   mpdat(imp).(mp_list{imp}).(varn)=deltaz*squeeze((sum(runs.RCP,3)));
case 'RWP'
   mpdat(imp).(mp_list{imp}).(varn)=deltaz*squeeze((sum(runs.RRP,3)));
case 'LWP'
   mpdat(imp).(mp_list{imp}).(varn)=deltaz*squeeze((sum(runs.RCP,3)+sum(runs.RRP,3)));
case 'Rv_da'
   mpdat(imp).(mp_list{imp}).(varn)=deltaz*squeeze((sum(runs.RV,3)));
case 'RH_da'
   mpdat(imp).(mp_list{imp}).rh_da=squeeze(mean(mpdat(imp).(mp_list{imp}).RH,[1 2 3]));
case 'flag1'

end
