clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set ...
   script_name

script_name = mfilename;

nikki = 'fullmic';
global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);
aux_line_color = [.5 .5 .5];
TAUorSBM = 2;
metrics = {'rsq', 'mr'};
met_title = {'R^2','Mean Ratio'};

for imet = 2:length(metrics)
metric = metrics{imet};

figure(1)
set(gcf,'position',[0 0 1000 700])
tiles = [];
tl = tiledlayout(10,4);

USconfs = [1 2];


clear ranking cb

nexttile(2,[1,2])
set(gca,'color','none')
set(gca,'XColor','none')
set(gca,'YColor','none')
cb = colorbar('southoutside');
cb.Label.String = met_title{imet};
cb.Label.Position = [imet/2 2.5 0]; % adhoc fix to the strange behavior of positioning...
set(cb,'position',[0.3187 0.8921 0.3676 0.0171])
if metric == "mr"
   caxis([.5 2])
   colormap(cmaps.coolwarm_s)
   set(gca,'colorscale','log')
else
   caxis([0 1])
   colormap(cmaps.magma_r)
end
set(gca,'fontsize',12)

for iconf = 1:length(USconfs)
idir = USconfs(iconf);
mconfig = mconfig_ls{idir};
case_dep_var
load([summ_dir,nikki,'_', mconfig, '_pfm.mat'])

indvar_name_set = fieldnames(pfm);
name_idx = contains(indvar_name_all,indvar_name_set);
indvar_name_set = indvar_name_all(name_idx);
indvar_ename_set = indvar_ename_all(name_idx);
indvar_units_set = indvar_units_all(name_idx);

vars2plot = [2 4];
% selected_cases = {[1 3], [3 4]};
selected_cases = {[1 2] [3 3]};

nvar1 = size(pfm.(indvar_name_set{1}).(bintype{1}).mr,1);
nvar2 = size(pfm.(indvar_name_set{1}).(bintype{1}).mr,2);

mom_matrix = zeros(nvar1,nvar2);


for ivar = 1:2
   ipvar = vars2plot(ivar);
   for its = TAUorSBM
      altscore = pfm.(indvar_name_set{ipvar}).(bintype{its}).(metric); % larger = better
      nexttile((iconf-1)*24+(ivar-1)*2+5, [3,2]) % make sure it's on the right grid
      % score_by_momcombo = score(iconf).(bintype{its}).(indvar_name_set{ipvar});
      nanimagesc(altscore)
      rectangle('position', [selected_cases{1}(2)-.5, selected_cases{1}(1)-.5, 1, 1], ...
         'EdgeColor',aux_line_color,'LineWidth',2)
      rectangle('position', [selected_cases{2}(2)-.5, selected_cases{2}(1)-.5, 1, 1], ...
         'EdgeColor',aux_line_color,'LineWidth',2)
      % cb = colorbar;
      % cb.Label.String = 'Similarity score';

      if metric == "mr"
         caxis([.5 2])
         colormap(cmaps.coolwarm_s)
         set(gca,'colorscale','log')
      else
         caxis([0 1])
         colormap(cmaps.magma_r)
      end

      mean_score = nanmean(altscore(:));
      wmean_score = wmean(altscore(:),pfm.(indvar_name_set{ipvar}).(bintype{its}).mpath_bin(:));
      ttl = sprintf('(%s) %s by %sAMP-%s, %s = %.3f', ...
         Alphabet((iconf-1)*6+ivar), indvar_ename_set{ipvar}, ...
         UorS, upper(bintype{its}), met_title{imet}, wmean_score);
      title(ttl,'FontWeight','normal')
      xticks(1:nvar2)
      yticks(1:nvar1)
      xticklabels(extractAfter(var2_str,lettersPattern))
      yticklabels(extractAfter(var1_str,lettersPattern))
      xlab_key = extractBefore(var2_str,digitsPattern);
      ylab_key = extractBefore(var1_str,digitsPattern);
      xlab = [initVarSymb_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
      ylab = [initVarSymb_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
      xlabel(xlab)
      ylabel(ylab)
      tiles = [tiles gca];
      set(gca,'fontsize',14)

   end

end % ivar
end % iconf

for icase = 1:length(selected_cases)
   ivar1 = selected_cases{icase}(1); ivar2 = selected_cases{icase}(2);
   mconfig = mconfig_ls{USconfs(1)};
   its = 1;
   bintau_struct = loadnc('bin', indvar_name_set);
   amptau2m_struct = loadnc('amp', indvar_name_set);
   its = 2;
   binsbm_struct = loadnc('bin', indvar_name_set);
   ampsbm2m_struct = loadnc('amp', indvar_name_set);

   mconfig = mconfig_ls{USconfs(2)};
   its = 1;
   amptau4m_struct = loadnc('amp', indvar_name_set);
   its = 2;
   ampsbm4m_struct = loadnc('amp', indvar_name_set);

   time = bintau_struct.time;
   for ivar = 1:2
      ipvar = vars2plot(ivar);
      nexttile((icase-1)+(ivar-1)*2+17,[3,1])

      var_comp_raw_amptau2m = amptau2m_struct.(indvar_name_set{ipvar});
      var_comp_amptau2m = var2phys(var_comp_raw_amptau2m,ipvar,1);
      var_comp_raw_ampsbm2m = ampsbm2m_struct.(indvar_name_set{ipvar});
      var_comp_ampsbm2m = var2phys(var_comp_raw_ampsbm2m,ipvar,1);

      var_comp_raw_amptau4m = amptau4m_struct.(indvar_name_set{ipvar});
      var_comp_amptau4m = var2phys(var_comp_raw_amptau4m,ipvar,1);
      var_comp_raw_ampsbm4m = ampsbm4m_struct.(indvar_name_set{ipvar});
      var_comp_ampsbm4m = var2phys(var_comp_raw_ampsbm4m,ipvar,1);

      if ~contains(indvar_name_set{ipvar}, amp_only_var)
         var_comp_raw_bintau = bintau_struct.(indvar_name_set{ipvar});
         var_comp_bintau = var2phys(var_comp_raw_bintau,ipvar,1);
         var_comp_raw_binsbm = binsbm_struct.(indvar_name_set{ipvar});
         var_comp_binsbm = var2phys(var_comp_raw_binsbm,ipvar,1);
      end

      if (min(size(var_comp_amptau2m))>1)
         var_comp_amptau2m = nanmean(var_comp_amptau2m,2);
         var_comp_ampsbm2m = nanmean(var_comp_ampsbm2m,2);
         var_comp_amptau4m = nanmean(var_comp_amptau4m,2);
         var_comp_ampsbm4m = nanmean(var_comp_ampsbm4m,2);
         var_comp_bintau = nanmean(var_comp_bintau,2);
         var_comp_binsbm = nanmean(var_comp_binsbm,2);
      end


      hold on

      plot(time, var_comp_bintau,   'DisplayName', 'bin-TAU', 'Color', color_order{1}, ...
         'LineWidth', .5, 'LineStyle', '-')
      plot(time, var_comp_amptau2m, 'DisplayName', 'S-AMP-TAU', 'Color', color_order{1}, ...
         'LineWidth', 1.5, 'LineStyle', ':')
      plot(time, var_comp_amptau4m, 'DisplayName', 'U-AMP-TAU', 'Color', color_order{1}, ...
         'LineWidth', 1, 'LineStyle', '--')
      plot(time, var_comp_binsbm,   'DisplayName', 'bin-SBM', 'Color', color_order{2}, ...
         'LineWidth', .5, 'LineStyle', '-')
      plot(time, var_comp_ampsbm2m, 'DisplayName', 'S-AMP-SBM', 'Color', color_order{2}, ...
         'LineWidth', 1.5, 'LineStyle', ':')
      plot(time, var_comp_ampsbm4m, 'DisplayName', 'U-AMP-SBM', 'Color', color_order{2}, ...
         'LineWidth', 1, 'LineStyle', '--')

      hold off
      xlim_val=xlim;
      xlim([xlim_val(1) max(time)])
      xlabel('Time [s]')
      ylabel([indvar_ename_set{ipvar} indvar_units_set{ipvar}])
      tiles = [tiles gca];
      grid
      box on
      set(gca,'fontsize',14)

      title(['(',Alphabet(icase+ivar*2),') ',var1_str{ivar1}, var2_str{ivar2}],'fontweight','normal')

   end % ivar

end % icase

axes(tiles(6))
legend('show','location','best','fontsize',11)
title(tl,[met_title{imet} ' scores and time series of RWP and precipitation rate'],'fontsize',24,'fontweight','bold')

% connecting the lines
for icase = 1:length(selected_cases)
   for iscoreplot = 1:2
      axes(tiles(iscoreplot))
      [xl_start, yl_start] = coord2norm(gca, ...
         selected_cases{icase}(2)-.5, selected_cases{icase}(1)-.5);
      [xr_start, yr_start] = coord2norm(gca, ...
         selected_cases{icase}(2)+.5, selected_cases{icase}(1)-.5);
      axes(tiles(5+iscoreplot-1+(icase-1)*2))
      ax_pos = get(gca,'position');
      xl_end = ax_pos(1);
      xr_end = ax_pos(1) + ax_pos(3);
      y_end = ax_pos(2) + ax_pos(4);
      annotation('line', [xl_start xl_end], [yl_start y_end], ...
         'LineStyle', '-', 'Color', aux_line_color, 'LineWidth', 1)
      annotation('line', [xr_start xr_end], [yr_start y_end], ...
         'LineStyle', '-', 'Color', aux_line_color, 'LineWidth', 1)
   end
end

for icase = 1:length(selected_cases)
   for iscoreplot = 3:4
      axes(tiles(iscoreplot))
      [xl_start, yl_start] = coord2norm(gca, ...
         selected_cases{icase}(2)-.5, selected_cases{icase}(1)+.5);
      [xr_start, yr_start] = coord2norm(gca, ...
         selected_cases{icase}(2)+.5, selected_cases{icase}(1)+.5);
      axes(tiles(5+iscoreplot-3+(icase-1)*2))
      ax_pos = get(gca,'position');
      xl_end = ax_pos(1);
      xr_end = ax_pos(1) + ax_pos(3);
      y_end = ax_pos(2);
      annotation('line', [xl_start xl_end], [yl_start y_end], ...
         'LineStyle', '-', 'Color', aux_line_color, 'LineWidth', 1)
      annotation('line', [xr_start xr_end], [yr_start y_end], ...
         'LineStyle', '-', 'Color', aux_line_color, 'LineWidth', 1)
   end
end

exportgraphics(gcf,['plots/p2/fs',sprintf('%.2d',8+imet),'_', mconfig,...
   ' ' bintype{TAUorSBM} ' rwpspr rank sandwich.pdf'])
saveas(gcf,['plots/p2/fs',sprintf('%.2d',8+imet),'_', mconfig, ' ' bintype{TAUorSBM} ' rwpspr rank sandwich.fig'])

close

end % imet
