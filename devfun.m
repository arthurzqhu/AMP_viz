function dev_strt=devfun(pfm)

fldnm=fieldnames(pfm);
bintype={'tau','sbm'};

for ifld=1:length(fldnm)
   for its=1:2
      mean_ratio=pfm.(fldnm{ifld}).(bintype{its}).mr(:);
      mean_val=pfm.(fldnm{ifld}).(bintype{its}).mpath_bin(:);

      dev_strt.(fldnm{ifld})(its)=wmean(mean_ratio,mean_val);
   end
end

end