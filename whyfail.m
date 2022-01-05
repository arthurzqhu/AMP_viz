clear 
close all
clear global

nikki='2021-10-07';
run global_var.m

load([nikki '_fullmic_pfm'])
load([nikki '_fullmic_success_rate'])


%%
close all
vars=1;
indvar_name=fieldnames(pfm);
vare=length(indvar_name);

for its=1:length(bintype)
   for ivar=vars:vare
      
      sr_c=squeeze(success_rate_c(its,:,:));
      sr_r=squeeze(success_rate_r(its,:,:));
      mrat=pfm.(indvar_name{ivar}).(bintype{its}).mr;
      cov_mtx_r=nancov(sr_r(:),mrat(:));
      cov_scl_r(ivar,its)=cov_mtx_r(1,2);
      
      cov_mtx_c=nancov(sr_c(:),mrat(:));
      cov_scl_c(ivar,its)=cov_mtx_c(1,2);
      
      figure
%       refline(0,1); hold on
      scatter(sr_r(:),mrat(:))
      title(indvar_name{ivar})
   end
end