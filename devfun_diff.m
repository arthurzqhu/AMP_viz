function diff_strt = devfun_diff(pfm)

fldnm=fieldnames(pfm);
bintype={'tau','sbm'};

for ifld = 1:length(fldnm)
   for its = 1:2
      mean_diff=pfm.(fldnm{ifld}).(bintype{its}).md(:);
      mean_val=pfm.(fldnm{ifld}).(bintype{its}).mpath_bin(:);
      diff_strt.mean_val.(fldnm{ifld})(its) = nanmean(mean_val);
      
      if ~exist('wORa','var') || wORa=="w" % weighted average
         diff_strt.diff.(fldnm{ifld})(its) = wmean(mean_diff,mean_val);
      elseif wORa=="a"
         diff_strt.diff.(fldnm{ifld})(its) = nanmean(mean_diff);
      else
         error('second argument is invalid')
      end
   end
end

end
