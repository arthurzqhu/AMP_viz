function sed_strt = devfun_sed(pfm)

fldnm=fieldnames(pfm);
bintype={'tau','sbm'};

for ifld = 1:length(fldnm)
   for its = 1:2
      mean_sed=pfm.(fldnm{ifld}).(bintype{its}).sed(:);
      mean_val=pfm.(fldnm{ifld}).(bintype{its}).mpath_bin(:);
      sed_strt.mean_val.(fldnm{ifld})(its) = nanmean(mean_val);
      
      if ~exist('wORa','var') || wORa=="w" % weighted average
         sed_strt.sed.(fldnm{ifld})(its) = wmean(mean_sed,mean_val);
      elseif wORa=="a"
         sed_strt.sed.(fldnm{ifld})(its) = nanmean(mean_sed);
      else
         error('second argument is invalid')
      end
   end
end

end
