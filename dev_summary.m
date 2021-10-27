clear
close all
clear global

load('2021-10-07_fullmic_pfm.mat')


fldnm=fieldnames(pfm);
bintype={'tau','sbm'};

for ifld=1:length(fldnm)
   for its=1:2
      mean_ratio=pfm.(fldnm{ifld}).(bintype{its}).mr(:);
      mean_val=pfm.(fldnm{ifld}).(bintype{its}).mpath_bin(:);

      dev.(fldnm{ifld})(its)=wmean(mean_ratio,mean_val);
   end
end
