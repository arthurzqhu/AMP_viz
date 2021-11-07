clear
close all
clear global

load('2021-11-05_evaponly_moredrop_inhom_pfm.mat')


fldnm=fieldnames(pfm);
bintype={'tau','sbm'};

for ifld=1:length(fldnm)
   for its=1:2
      mean_ratio=reshape(pfm.(fldnm{ifld}).(bintype{its}).mr(:,:),1,[]);
      mean_val=reshape(pfm.(fldnm{ifld}).(bintype{its}).mpath_bin(:,:),1,[]);

      mean_end_ratio=nanmean(pfm.(fldnm{ifld}).(bintype{its}).er(:));

      dev.(fldnm{ifld})(its)=(wmean(mean_ratio,mean_val)-1)*100;
      %dev.(fldnm{ifld})(its)=(mean_end_ratio-1)*100;
   end
end

dev
