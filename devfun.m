function dev_strt = devfun(pfm, wORa)

fldnm = fieldnames(pfm);
bintype = {'tau','sbm'};

for ifld = 1:length(fldnm)
   for its = 1:2
      mean_ratio = pfm.(fldnm{ifld}).(bintype{its}).mr(:);
      mean_val = pfm.(fldnm{ifld}).(bintype{its}).mpath_bin(:);
      mean_val(isnan(mean_val)) = 0;
      
      if ~exist('wORa','var') || wORa == "w" % weighted average
         dev_strt.mean_ratio.(fldnm{ifld})(its) = wmean(mean_ratio,mean_val);
         dev_strt.std_ratio.(fldnm{ifld})(its) = nanstd(mean_ratio,mean_val);
      elseif wORa == "a"
         dev_strt.mean_ratio.(fldnm{ifld})(its) = nanmean(mean_ratio);
         dev_strt.std_ratio.(fldnm{ifld})(its) = nanstd(mean_ratio);
      else
         error('second argument is invalid')
      end
   end
end

end
