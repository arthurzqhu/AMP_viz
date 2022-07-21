function dev_strt = devfun_bin(pfm, wORa)

fldnm = fieldnames(pfm);

for ifld = 1:length(fldnm)-1
   mean_ratio = pfm.(fldnm{ifld}).mr(:);
   mean_val = pfm.(fldnm{ifld}).mpath_sbm(:);
   mean_val(isnan(mean_val)) = 0;
   
   if ~exist('wORa','var') || wORa == "w" % weighted average
      dev_strt.mean_ratio.(fldnm{ifld}) = wmean(mean_ratio,mean_val);
      dev_strt.std_ratio.(fldnm{ifld}) = nanstd(mean_ratio,mean_val);
   elseif wORa == "a"
      dev_strt.mean_ratio.(fldnm{ifld}) = nanmean(mean_ratio);
      dev_strt.std_ratio.(fldnm{ifld}) = nanstd(mean_ratio);
   else
      error('second argument is invalid')
   end
end

end
