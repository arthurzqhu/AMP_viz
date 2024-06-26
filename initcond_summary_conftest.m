clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set ...
   indvar_name_all indvar_ename_all indvar_units_all cwp_th filename

vnum = '0001'; % last four characters of the model output file.
nikkis = {'conftest_fullmic'};

for ink = 1:length(nikkis)
   nikki = nikkis{ink};
   disp(nikki)
   global_var

   % get the list of configs. cant put it into globar_var
   mconfig_ls = get_mconfig_list(output_dir,nikki);

   %%
   % creating structures for performance analysis based on simscore and ratio
   for iconf = 1:length(mconfig_ls)
      mconfig = mconfig_ls{iconf};
      disp(mconfig)
      get_var_comp()
      case_dep_var
      nvar1 = length(var1_str);
      nvar2 = length(var2_str);
      pfm = struct;
      for its = 1:length(bintype)

         for ivar = 1:length(indvar_name_set)
            pfm.(indvar_name_set{ivar}).(bintype{its}).mr = zeros(nvar1,nvar2);
            pfm.(indvar_name_set{ivar}).(bintype{its}).simscore = zeros(nvar1,nvar2);
            pfm.(indvar_name_set{ivar}).(bintype{its}).mpath_bin = zeros(nvar1,nvar2);
            pfm.(indvar_name_set{ivar}).(bintype{its}).mpath_amp = zeros(nvar1,nvar2);
            pfm.(indvar_name_set{ivar}).(bintype{its}).rsq = zeros(nvar1,nvar2);
         end

         for ivar1 = 1:nvar1
            for ivar2 = 1:nvar2
               if ~contains(var2_str{ivar2}, var2_str_asFuncOfVar1{ivar1})
                  continue
               end
               disp([its ivar1 ivar2])

               try
                  amp_struct = loadnc('amp', indvar_name_set);
                  bin_struct = loadnc('bin', indvar_name_set);
               catch
                  warning(['Failed reading nc files at ' num2str([its, ivar1, ivar2])])
                  continue
               end

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
                     vidx = ~isnan(var_amp_flt+var_bin_flt) & ~isinf(var_amp_flt+var_bin_flt);
                     nonzero_idx = var_amp_flt.*var_bin_flt>0;

                     weight = var_bin_flt(vidx)/sum(var_bin_flt(vidx));
                     weight_log = log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));

                     [mr, simscore, mval_amp, mval_bin, ~, ~, ~, ~, ~, ~, ~, ~, rsq] = ...
                        wrsq(var_amp_flt(vidx), var_bin_flt(vidx), weight);

                     if indvar_name{ivar} == "mean_surface_ppt"
                        mval_bin(mval_bin < sppt_th(1)) = 0;
                        mr(mval_bin < sppt_th(1)) = nan;
                     end

                     % if indvar_name{ivar} == "rain_M1_path"
                     %    mval_bin(mval_bin < mean_rwp_th(1)) = 0;
                     %    mr(mval_bin < mean_rwp_th(1)) = nan;
                     % end

                     % if indvar_name{ivar} == "diagM0_rain"
                     %    mval_bin(mval_bin < mean_rn_th(1)) = 0;
                     %    mr(mval_bin < mean_rn_th(1)) = nan;
                     % end

                     pfm.(indvar_name{ivar}).(bintype{its}).mr(ivar1, ivar2) = mr;
                     pfm.(indvar_name{ivar}).(bintype{its}).simscore(ivar1, ivar2) = simscore;
                     pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(ivar1, ivar2) = mval_bin;
                     pfm.(indvar_name{ivar}).(bintype{its}).mpath_amp(ivar1, ivar2) = mval_amp;
                     pfm.(indvar_name{ivar}).(bintype{its}).rsq(ivar1, ivar2) = rsq;
                     % pfm.(indvar_name{ivar}).(bintype{its}).er(ivar1, ivar2) = er;
                     % pfm.(indvar_name{ivar}).(bintype{its}).maxr(ivar1, ivar2) = maxr;
                     % pfm.(indvar_name{ivar}).(bintype{its}).md(ivar1, ivar2) = md;
                     % pfm.(indvar_name{ivar}).(bintype{its}).serr(ivar1, ivar2) = serr;
                     % pfm.(indvar_name{ivar}).(bintype{its}).msd_amp(ivar1, ivar2) = msd_amp;
                     % pfm.(indvar_name{ivar}).(bintype{its}).msd_bin(ivar1, ivar2) = msd_bin;
                     % pfm.(indvar_name{ivar}).(bintype{its}).sval_amp(ivar1, ivar2) = sval_amp;
                     % pfm.(indvar_name{ivar}).(bintype{its}).sval_bin(ivar1, ivar2) = sval_bin;
                  elseif contains(indvar_name{ivar}, 'oflag')
                     flags(iconf).(indvar_name{ivar}).(bintype{its}).failure_rate_m0(ivar1,ivar2)=...
                        sum(var_amp_flt==2)/sum(var_amp_flt>=0);
                     flags(iconf).(indvar_name{ivar}).(bintype{its}).failure_rate_mx(ivar1,ivar2)=...
                        sum(var_amp_flt==1)/sum(var_amp_flt>=0);
                     flags(iconf).(indvar_name{ivar}).(bintype{its}).failure_rate_and(ivar1,ivar2)=...
                        sum(var_amp_flt==3)/sum(var_amp_flt>=0);
                     flags(iconf).(indvar_name{ivar}).(bintype{its}).failure_rate_or(ivar1,ivar2)=...
                        (sum(var_amp_flt==1)+sum(var_amp_flt==2)-sum(var_amp_flt==3))/sum(var_amp_flt>=0);
                     flags(iconf).(indvar_name{ivar}).(bintype{its}).success_rate(ivar1,ivar2)=...
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
               simscore = pfm.(indvar_name{ivar}).(bintype{its}).simscore;
               idxNoData = simscore==0;
               pfm.(indvar_name{ivar}).(bintype{its}).mr(idxNoData) = nan;
               pfm.(indvar_name{ivar}).(bintype{its}).simscore(idxNoData) = nan;
               pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(idxNoData) = nan;
               pfm.(indvar_name{ivar}).(bintype{its}).mpath_amp(idxNoData) = nan;
               pfm.(indvar_name{ivar}).(bintype{its}).rsq(idxNoData) = nan;
               % pfm.(indvar_name{ivar}).(bintype{its}).er(idxNoData) = nan;
               % pfm.(indvar_name{ivar}).(bintype{its}).maxr(idxNoData) = nan;
               % pfm.(indvar_name{ivar}).(bintype{its}).md(idxNoData) = nan;
               % pfm.(indvar_name{ivar}).(bintype{its}).serr(idxNoData) = nan;
               % pfm.(indvar_name{ivar}).(bintype{its}).msd_amp(idxNoData) = nan;
               % pfm.(indvar_name{ivar}).(bintype{its}).msd_bin(idxNoData) = nan;
               % pfm.(indvar_name{ivar}).(bintype{its}).sval_amp(idxNoData) = nan;
               % pfm.(indvar_name{ivar}).(bintype{its}).sval_bin(idxNoData) = nan;
            end

         end
      end

      pfm.misc.var1_str = var1_str;
      pfm.misc.var2_str = var2_str;
      save(['pfm_summary/' nikki '_' mconfig '_pfm.mat'],'pfm')
   end
   try
      save(['flags_summary/' nikki '_perinit_flags.mat'],'flags')
   end
end
