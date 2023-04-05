clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set ...
   indvar_name_all indvar_ename_all indvar_units_all cwp_th filename

vnum = '0001'; % last four characters of the model output file.
nikkis = {'conftest_nodown'};
doplot = 0
doload = 0

for ink = 1:length(nikkis)
   nikki = nikkis{ink};
   disp(nikki)
   global_var

   % get the list of configs. cant put it into globar_var
   mconfig_ls = get_mconfig_list(output_dir,nikki);

   %%
   % creating structures for performance analysis based on Rsq and ratio
   for iconf = 1:length(mconfig_ls)
      mconfig = mconfig_ls{iconf};
      disp(mconfig)
      get_var_comp() % sedonly
      case_dep_var
      if ~doload
      pfm = struct;
      for its = 1:length(bintype)
         for ivar1 = 1:length(var1_str)
            for ivar2 = 1:length(var2_str)
               if ~contains(var2_str{ivar2}, var2_str_asFuncOfVar1{ivar1})
                  continue
               end
               disp([its, ivar1, ivar2])

               try
                  amp_struct = loadnc('amp', indvar_name_set);
                  bin_struct = loadnc('bin', indvar_name_set);
               catch
                  warning(['Failed reading nc files at' num2str([its, ivar1, ivar2])])
                  continue
                  % amp_struct = struct;
                  % bin_struct = struct;
               end

               % indices of vars to compare
               vars = 1;
               vare = length(indvar_name);

               time = amp_struct.time;
               z = amp_struct.z;
               for ivar = vars:vare
                  if strcmp(indvar_name{ivar},'mean_surface_ppt') && ~contains(mconfig,{'fullmic','sed'})
                     continue
                  elseif strcmp(indvar_name{ivar},'albedo') && ~contains(mconfig,{'fullmic'})
                     continue
                  elseif contains(indvar_name{ivar},'rain') && contains(mconfig,{'condnuc_noinit'})
                     continue
                  elseif contains(indvar_name{ivar},'cloud') && contains(mconfig,{'sedonly'})
                     continue
                  end

                  var_comp_raw_amp = amp_struct.(indvar_name{ivar});
                  var_amp_flt = var2phys(var_comp_raw_amp,ivar,0,1,1);

                  var_comp_raw_bin = bin_struct.(indvar_name{ivar});
                  var_bin_flt = var2phys(var_comp_raw_bin,ivar,0,1,1);

                  % get the non-nan indices for both bin and amp
                  vidx = ~isnan(var_amp_flt+var_bin_flt);
                  nzidx = var_amp_flt.*var_bin_flt>0;

                  weight = var_bin_flt(vidx)/sum(var_bin_flt(vidx));
                  weight_log = log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));

                  [mr, rsq, mval_amp, mval_bin, er, maxr, md, serr, msd_amp, msd_bin, ...
                     sval_amp, sval_bin] = wrsq(var_amp_flt, var_bin_flt, weight);

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
                  pfm.(indvar_name{ivar}).(bintype{its}).rsq(ivar1, ivar2) = rsq;
                  pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(ivar1, ivar2) = mval_bin;
                  pfm.(indvar_name{ivar}).(bintype{its}).mpath_amp(ivar1, ivar2) = mval_amp;
                  pfm.(indvar_name{ivar}).(bintype{its}).er(ivar1, ivar2) = er;
                  pfm.(indvar_name{ivar}).(bintype{its}).maxr(ivar1, ivar2) = maxr;
                  pfm.(indvar_name{ivar}).(bintype{its}).md(ivar1, ivar2) = md;
                  pfm.(indvar_name{ivar}).(bintype{its}).serr(ivar1, ivar2) = serr;
                  pfm.(indvar_name{ivar}).(bintype{its}).msd_amp(ivar1, ivar2) = msd_amp;
                  pfm.(indvar_name{ivar}).(bintype{its}).msd_bin(ivar1, ivar2) = msd_bin;
                  pfm.(indvar_name{ivar}).(bintype{its}).sval_amp(ivar1, ivar2) = sval_amp;
                  pfm.(indvar_name{ivar}).(bintype{its}).sval_bin(ivar1, ivar2) = sval_bin;
               end % ivar
            end % ivar2
         end % ivar1
      end % its

      % set blank values to nan
      for its = 1:2
         for ivar = vars:vare
            if strcmp(indvar_name{ivar},'mean_surface_ppt') && ~contains(mconfig,{'fullmic','sed'})
               continue
            elseif strcmp(indvar_name{ivar},'albedo') && ~contains(mconfig,{'fullmic'})
               continue
            elseif contains(indvar_name{ivar},'rain') && contains(mconfig,{'condnuc_noinit'})
               continue
            elseif contains(indvar_name{ivar},'cloud') && contains(mconfig,{'sedonly'})
               continue
            end
            rsq = pfm.(indvar_name{ivar}).(bintype{its}).rsq;
            idxNoData = rsq==0;
            pfm.(indvar_name{ivar}).(bintype{its}).mr(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).rsq(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).mpath_amp(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).er(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).maxr(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).md(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).serr(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).msd_amp(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).msd_bin(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).sval_amp(idxNoData) = nan;
            pfm.(indvar_name{ivar}).(bintype{its}).sval_bin(idxNoData) = nan;
         end
      end

      pfm.misc.var1_str = var1_str;
      pfm.misc.var2_str = var2_str;
      save(['pfm_summary/' nikki '_' mconfig '_pfm.mat'],'pfm')
      else
         its = 1;
         load(['pfm_summary/' nikki '_' mconfig '_pfm.mat'])
         fldnms = fieldnames(pfm(1));
         fldnms = fldnms(1:end-1);
         indvar_name = intersect(indvar_name_set, fldnms, 'stable');
         vidx = ismember(indvar_name_set, indvar_name);
         indvar_ename=indvar_ename_set(vidx);
         indvar_units=indvar_units_set(vidx);
      end % doload


%% plot
      if doplot

      tmpvarname = fieldnames(pfm(1));
      fldnms = fieldnames(pfm(1).(tmpvarname{1}).(bintype{its}));
      fldnms = fldnms(1:end-1);

      close all
      vars = 1;
      vare = length(indvar_name);

      for ivar = vars:vare
         if strcmp(indvar_name{ivar},'mean_surface_ppt') && ~contains(mconfig,{'fullmic','sed'})
            continue
         elseif strcmp(indvar_name{ivar},'albedo') && ~contains(mconfig,{'fullmic'})
            continue
         elseif contains(indvar_name{ivar},'rain') && contains(mconfig,{'condnuc_noinit'})
            continue
         elseif contains(indvar_name{ivar},'cloud') && contains(mconfig,{'sedonly'})
            continue
         end
         %%
         figure(1)
         set(gcf,'position',[0 0 1250 700])
         tl = tiledlayout(7,4);
         for its = 1:length(bintype)
            nexttile((its-1)*12+5,[3 4])

            rsq = pfm.(indvar_name{ivar}).(bintype{its}).rsq;
            idxNoData = rsq==0;
            mr = pfm.(indvar_name{ivar}).(bintype{its}).mr;
            mr(idxNoData) = nan;

            nanimagesc(mr')
            cb = colorbar;
            if its == length(bintype)
               cb.Label.String = 'AMP/bin'; 
            end
            title(upper(bintype{its}),'FontWeight','normal')
            xticks(1:length(var1_str))
            yticks(1:length(var2_str))
            xticklabels(extractAfter(var1_str,lettersPattern))
            yticklabels(extractAfter(var2_str,lettersPattern))
            set(gca,'FontSize',16)

            colormap(cmaps.BrBG)
            set(gca,'ColorScale','log')
            caxis([.5 2])
            %                cb.Ticks = [.25 .5 1 2 4];

            mpath = pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin;
            [XX,YY] = meshgrid(1:length(var1_str),1:length(var2_str));
            mpath_bin_str = sprintfc('%0.3g',mpath);

            nexttile(2,[1,2])
   %          imagesc()
            set(gca,'Color','none')
            set(gca,'XColor','none')
            set(gca,'YColor','none')
   %          ax = gca;
            colormap(gca,cmaps.coolwarm_r)
            cb = colorbar('southoutside');
            cb.Label.String = 'R^2';
            cb.Label.Position = [0.5000 3.3 0];
            set(gca,'FontSize',16)

            xlab_key = extractBefore(var1_str,digitsPattern);
            ylab_key = extractBefore(var2_str,digitsPattern);
            xlab = [initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
            ylab = [initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
            xlabel(tl,xlab,'fontsize',16)
            ylabel(tl,ylab,'fontsize',16)
            %ylabel(tl,[ylab repelem(' ',23)],'fontsize',16)
            
         end
         title(tl,[indvar_ename{ivar} indvar_units{ivar} ...
            ],'fontsize',20,'fontweight','bold')
         saveas(gcf,[plot_dir ' summ ' ...
            (indvar_ename{ivar}) ' mr'...
            '.png'])
      end
      end
   end
end
