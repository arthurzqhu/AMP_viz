function [pfm, flags] = getSummRSQ(mconfig,nikki)

bintype = {'tau' 'sbm'};
amp_only_var = {'flag','Dn_', '_M2', '_M3', '_M4','nu_'};
sppt_th = [0.1 inf]; % mm/hr surface precipitation

disp(mconfig)
[indvar_name_set, indvar_ename_set, indvar_units_set] = get_var_comp(mconfig,nikki);
[var1_str, var2_str] = case_dep_var(mconfig,nikki);

pfm = struct;
flags = struct;
for its = 1:length(bintype)
   for ivar1 = 1:length(var1_str)
      for ivar2 = 1:length(var2_str)

         [amp_struct, indvar_name, indvar_ename, indvar_units] = ...
            loadnc('amp',mconfig,nikki,its,var1_str,var2_str,ivar1,ivar2,...
            indvar_name_set,indvar_ename_set,indvar_units_set);
         [bin_struct, indvar_name, indvar_ename, indvar_units] = ...
            loadnc('bin',mconfig,nikki,its,var1_str,var2_str,ivar1,ivar2,...
            indvar_name_set,indvar_ename_set,indvar_units_set);


         % try
         %    amp_struct = loadnc('amp', indvar_name_set);
         %    bin_struct = loadnc('bin', indvar_name_set);
         % catch
         %    warning(['Failed reading nc files at ' num2str([its, ivar1, ivar2])])
         %    continue
         % end

         % indices of vars to compare
         vars = 1;
         vare = length(indvar_name);

         for ivar = vars:vare
            if strcmp(indvar_name{ivar},'mean_surface_ppt') && ~contains(nikki,{'fullmic','sed'})
               continue
            elseif strcmp(indvar_name{ivar},'albedo') && ~contains(nikki,{'fullmic'})
               continue
            elseif contains(indvar_name{ivar},'rain') && contains(nikki,{'condnuc_noinit'})
               continue
            elseif contains(indvar_name{ivar},'cloud') && contains(nikki,{'sedonly'})
               continue
            end

            var_comp_raw_amp = amp_struct.(indvar_name{ivar});
            var_amp_flt = var2phys(var_comp_raw_amp,ivar,0,1,1);

            if ~contains(indvar_name{ivar}, amp_only_var)
               var_comp_raw_bin = bin_struct.(indvar_name{ivar});
               var_bin_flt = var2phys(var_comp_raw_bin,ivar,0,1,1);

               % get the non-nan indices for both bin and amp
               vidx = ~isnan(var_amp_flt+var_bin_flt);
               nzidx = var_amp_flt.*var_bin_flt>0;

               weight = var_bin_flt(vidx)/sum(var_bin_flt(vidx));
               weight_log = log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));

               [mr, rsq, mval_amp, mval_bin] = wrsq(var_amp_flt, var_bin_flt, weight);

               if indvar_name{ivar} == "mean_surface_ppt"
                  mval_bin(mval_bin < sppt_th(1)) = 0;
                  mr(mval_bin < sppt_th(1)) = nan;
               end

               pfm.(indvar_name{ivar}).(bintype{its}).mr(ivar1, ivar2) = mr;
               pfm.(indvar_name{ivar}).(bintype{its}).rsq(ivar1, ivar2) = rsq;
               pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(ivar1, ivar2) = mval_bin;
               pfm.(indvar_name{ivar}).(bintype{its}).mpath_amp(ivar1, ivar2) = mval_amp;
            elseif contains(indvar_name{ivar}, 'oflag')
               flags.(indvar_name{ivar}).(bintype{its}).failure_rate_m0(ivar1,ivar2)=...
                  sum(var_amp_flt==2)/sum(var_amp_flt>=0);
               flags.(indvar_name{ivar}).(bintype{its}).failure_rate_mx(ivar1,ivar2)=...
                  sum(var_amp_flt==1)/sum(var_amp_flt>=0);
               flags.(indvar_name{ivar}).(bintype{its}).failure_rate_and(ivar1,ivar2)=...
                  sum(var_amp_flt==3)/sum(var_amp_flt>=0);
               flags.(indvar_name{ivar}).(bintype{its}).failure_rate_or(ivar1,ivar2)=...
                  (sum(var_amp_flt==1)+sum(var_amp_flt==2)-sum(var_amp_flt==3))/sum(var_amp_flt>=0);
               flags.(indvar_name{ivar}).(bintype{its}).success_rate(ivar1,ivar2)=...
                  sum(var_amp_flt==0)/sum(var_amp_flt>=0);
            end
         end % ivar
      end % ivar2
   end % ivar1
end % its

% set blank values to nan
for its = 1:2
   for ivar = vars:vare
      if strcmp(indvar_name{ivar},'mean_surface_ppt') && ~contains(nikki,{'fullmic','sed'})
         continue
      elseif strcmp(indvar_name{ivar},'albedo') && ~contains(nikki,{'fullmic'})
         continue
      elseif contains(indvar_name{ivar},'rain') && contains(nikki,{'condnuc_noinit'})
         continue
      elseif contains(indvar_name{ivar},'cloud') && contains(nikki,{'sedonly'})
         continue
      end
      if ~contains(indvar_name{ivar}, amp_only_var)
         rsq = pfm.(indvar_name{ivar}).(bintype{its}).rsq;
         idxNoData = rsq==0;
         pfm.(indvar_name{ivar}).(bintype{its}).mr(idxNoData) = nan;
         pfm.(indvar_name{ivar}).(bintype{its}).rsq(idxNoData) = nan;
         pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(idxNoData) = nan;
         pfm.(indvar_name{ivar}).(bintype{its}).mpath_amp(idxNoData) = nan;
      end
   end
end

end
