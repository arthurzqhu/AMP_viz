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
TAUorSBM = 1:2;

USconfs = [1 2];
varset = {[2 4] [1 3]};
selected_cases = {[1 2] [3 3]};

ifig = 0;

for ivarset = 1:2
vars2plot=varset{ivarset};
for its = TAUorSBM
if its==2 && ivarset==1
   continue
end

figure(1)
set(gcf,'position',[0 0 1000 700])
tiles = [];
tl = tiledlayout(10,4);

nexttile(2,[1,2])
set(gca,'color','none')
set(gca,'XColor','none')
set(gca,'YColor','none')
cb = colorbar('southoutside');
cb.Label.String = 'Similarity score';
cb.Label.Position=[0.5000 2.5 0];
set(cb,'position',[0.3187 0.8921 0.3676 0.0171])
caxis([0 1])
colormap(gca,cmaps.magma_r)
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

nvar1 = size(pfm.(indvar_name_set{1}).(bintype{1}).mr,1);
nvar2 = size(pfm.(indvar_name_set{1}).(bintype{1}).mr,2);

mom_matrix = zeros(nvar1,nvar2);

for ivar = 1:2
   ipvar = vars2plot(ivar);
   rsq = pfm.(indvar_name_set{ipvar}).(bintype{its}).rsq; % larger = better
   nexttile((iconf-1)*24+(ivar-1)*2+5, [3,2]) % make sure it's on the right grid
   % score_by_momcombo = score(iconf).(bintype{its}).(indvar_name_set{ipvar});
   nanimagesc(rsq)
   rectangle('position', [selected_cases{1}(2)-.5, selected_cases{1}(1)-.5, 1, 1], ...
      'EdgeColor',aux_line_color,'LineWidth',2)
   rectangle('position', [selected_cases{2}(2)-.5, selected_cases{2}(1)-.5, 1, 1], ...
      'EdgeColor',aux_line_color,'LineWidth',2)
   % cb = colorbar;
   % cb.Label.String = 'Similarity score';
   colormap(gca,cmaps.magma_r)
   caxis([0 1])

   mean_score = nanmean(rsq(:));
   wmean_score = wmean(rsq(:),pfm.(indvar_name_set{ipvar}).(bintype{its}).mpath_bin(:));
   ttl = sprintf('(%s) %s by %sAMP-%s, mean score = %.3f', ...
      Alphabet((iconf-1)*6+ivar), indvar_ename_set{ipvar}, UorS, upper(bintype{its}), wmean_score);
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

   for icase = 1:length(selected_cases)
      ivar1 = selected_cases{icase}(1); ivar2 = selected_cases{icase}(2);
      mconfig = mconfig_ls{USconfs(1)};
      bin_struct = loadnc('bin', indvar_name_set);
      amp2m_struct = loadnc('amp', indvar_name_set);

      mconfig = mconfig_ls{USconfs(2)};
      amp4m_struct = loadnc('amp', indvar_name_set);

      time = bin_struct.time;
      nexttile((icase-1)+(ivar-1)*2+17,[3,1])

      var_comp_raw_amp2m = amp2m_struct.(indvar_name_set{ipvar});
      var_comp_amp2m = var2phys(var_comp_raw_amp2m,ipvar,1);

      var_comp_raw_amp4m = amp4m_struct.(indvar_name_set{ipvar});
      var_comp_amp4m = var2phys(var_comp_raw_amp4m,ipvar,1);

      if ~contains(indvar_name_set{ipvar}, amp_only_var)
         var_comp_raw_bin = bin_struct.(indvar_name_set{ipvar});
         var_comp_bin = var2phys(var_comp_raw_bin,ipvar,1);
      end

      if (min(size(var_comp_amp2m))>1)
         var_comp_amp2m = nanmean(var_comp_amp2m,2);
         var_comp_amp4m = nanmean(var_comp_amp4m,2);
         var_comp_bin = nanmean(var_comp_bin,2);
      end



      plot(time, var_comp_bin,'DisplayName',['bin-' upper(bintype{its})], ...
         'Color', color_order{its}, 'LineWidth', .5, 'LineStyle', '-')
      hold on
      plot(time, var_comp_amp2m,'DisplayName',['S-AMP-' upper(bintype{its})], ...
         'Color', color_order{its}, 'LineWidth', 1.5, 'LineStyle', ':')
      plot(time, var_comp_amp4m,'DisplayName',['U-AMP-' upper(bintype{its})], ...
         'Color', color_order{its}, 'LineWidth', 1, 'LineStyle', '--')

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

   end % icase
end % ivar

end % iconf

   for icase = 1:length(selected_cases)
      for iscoreplot = [1 4]
         axes(tiles(iscoreplot))
         [xl_start, yl_start] = coord2norm(gca, ...
            selected_cases{icase}(2)-.5, selected_cases{icase}(1)-.5);
         [xr_start, yr_start] = coord2norm(gca, ...
            selected_cases{icase}(2)+.5, selected_cases{icase}(1)-.5);
         axes(tiles(iscoreplot+icase))
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
      for iscoreplot = [7 10]
         axes(tiles(iscoreplot))
         [xl_start, yl_start] = coord2norm(gca, ...
            selected_cases{icase}(2)-.5, selected_cases{icase}(1)+.5);
         [xr_start, yr_start] = coord2norm(gca, ...
            selected_cases{icase}(2)+.5, selected_cases{icase}(1)+.5);
         axes(tiles(iscoreplot+icase))
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


   axes(tiles(5))
   legend('show','location','best','fontsize',11)
   title(tl,['Mean scores and time series of ',indvar_ename{vars2plot(1)},...
      ' and ', indvar_ename{vars2plot(2)}],'fontsize',24,'fontweight','bold')
   exportgraphics(gcf,['plots/p2/fs',num2str(ifig+4),'_', mconfig, ' ' bintype{its} ' rank sandwich.pdf'])
   saveas(gcf,['plots/p2/fs',num2str(ifig+4),'_', mconfig, ' ' bintype{its} ' rank sandwich.fig'])
   ifig = ifig + 1;
end % its
end % ivarset
