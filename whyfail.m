clear 
close all
clear global

nikki='2021-10-07';
run global_var.m

load([nikki '_fullmic_pfm'])
load([nikki '_fullmic_success_rate'])

mconfig_ls_dir=dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags=[mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2)=0; % ignore the current and parent dir
mconfig_ls={mconfig_ls_dir(mconfig_ls_dir_flags).name};

iconf=2;
mconfig=mconfig_ls{iconf};

%%
close all
vars=1;
indvar_name=fieldnames(pfm);
vare=length(indvar_name);

for its=1:length(bintype)
   for ivar=vars:vare
      
      sr_r=squeeze(success_rate_r(its,:,:));
      mrat=pfm.(indvar_name{ivar}).(bintype{its}).mr;
      cov_mtx=nancov(sr_r(:),mrat(:));
      cov_scl_c(ivar,its)=cov_mtx(1,2);
      figure
%       refline(0,1); hold on
      scatter(sr_r(:),mrat(:))
      title(indvar_name{ivar})
   end
end