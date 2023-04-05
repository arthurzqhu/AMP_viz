clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name ...
   indvar_ename indvar_ename_set

nikki = '2023-04-04';
global_var

% as opposed to mean ratio. should be set between 0 and 1. 0.5 means rsq and mr are equally important
rsq_importance = 0.5; 

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);
aux_line_color = [.5 .5 .5];
SBMorTAU = 1;

figure(1)
set(gcf,'position',[0 0 1250 800])
tiles = [];
tl = tiledlayout(3,8,'TileSpacing','compact','padding','compact');

USconfs = [1 2];

for iconf = 1:length(USconfs)
idir = USconfs(iconf);
mconfig = mconfig_ls{idir};
case_dep_var
load(['pfm_summary/',nikki,'_', mconfig, '_pfm.mat'])

indvar_name = fieldnames(pfm);
name_idx = contains(indvar_name_all,indvar_name);
indvar_ename = indvar_ename_all(name_idx);
indvar_units = indvar_units_all(name_idx);

vars2plot = [2 4];
% selected_cases = {[1 3], [3 4]};
selected_cases = {[2 3]};

nvar1 = size(pfm.(indvar_name{1}).(bintype{1}).mr,1);
nvar2 = size(pfm.(indvar_name{1}).(bintype{1}).mr,2);

mom_matrix = zeros(nvar1,nvar2);

clear ranking

for its = SBMorTAU
   for ivar = vars2plot
      rsq = pfm.(indvar_name{ivar}).(bintype{its}).rsq; % larger = better
      [rsq_sorted,rsq_sortIdx] = sort(rsq(:),'ascend','MissingPlacement','first');

      abslogmr = abs(log(pfm.(indvar_name{ivar}).(bintype{its}).mr)); 
      adj_abslogmr = 1-abslogmr; % larger = better
      [abslogmr_sorted,abslogmr_sortIdx] = sort(adj_abslogmr(:),'ascend','MissingPlacement','first');

      if contains(indvar_name{ivar},'half_life')
         overall_score = adj_abslogmr;
      else
         overall_score = rsq*rsq_importance + adj_abslogmr*(1-rsq_importance);
      end
      [ovs_sorted, ovs_sortIdx] = sort(overall_score(:), 'descend', 'MissingPlacement','last');

      if contains(mconfig,'momcombo')
         % fold the grid and find the better moment combination between XY and YX
         % +1/-1 proabbly not necessary but added for better readability
         for imomx = 1:nvar1
            for imomy = imomx+1:nvar2+1
               score_xy = overall_score(imomx,imomy-1);
               score_yx = overall_score(imomy-1,imomx);
               score_better = max([score_xy, score_yx]);
               mom_matrix(imomx, imomy-1) = score_better;
               mom_matrix(imomy-1, imomx) = nan;
            end
         end
         % for every moment combination I want a rank of how good it is at predicting each variable
         for imomx = 1:nvar1
            for imomy = imomx+1:nvar2+1
               if isnan(mom_matrix(imomx,imomy-1))
                  ranking.(bintype{its}).(indvar_name{ivar})(imomx,imomy-1) = nan;
               else
                  % in the rare case of same overall score ...
                  temp_rank = find(ovs_sorted==mom_matrix(imomx,imomy-1));
                  if length(temp_rank) > 1
                     temp_rank = min(temp_rank);
                  end
                  ranking.(bintype{its}).(indvar_name{ivar})(imomx,imomy-1) = temp_rank;
                  ranking.(bintype{its}).(indvar_name{ivar})(imomy-1,imomx) = nan;
               end
            end
         end

      else
         for ivar1 = 1:nvar1
            for ivar2 = 1:nvar2
               if isnan(overall_score(ivar1,ivar2))
                  ranking.(bintype{its}).(indvar_name{ivar})(ivar1,ivar2) = nan;
               else
                  % in the rare case of same overall score ...
                  temp_rank = find(ovs_sorted==overall_score(ivar1,ivar2));
                  if length(temp_rank) > 1
                     temp_rank = min(temp_rank);
                  end
                  ranking.(bintype{its}).(indvar_name{ivar})(ivar1,ivar2) = temp_rank;
               end
            end
         end
         mom_matrix = overall_score;
      end

      score(iconf).(bintype{its}).(indvar_name{ivar}) = mom_matrix;
   end % ivar
end % its

for ivar = vars2plot
   for its = SBMorTAU
      nexttile((iconf-1)*16+(ivar-2)*2+1, [1,4]) % make sure it's on the right grid
      score_by_momcombo = score(iconf).(bintype{its}).(indvar_name{ivar});
      nanimagesc(score_by_momcombo)
      rectangle('position', [selected_cases{1}(2)-.5, selected_cases{1}(1)-.5, 1, 1], ...
         'EdgeColor',aux_line_color,'LineWidth',2)
      % rectangle('position', [selected_cases{2}(2)-.5, selected_cases{2}(1)-.5, 1, 1], ...
      %    'EdgeColor',aux_line_color,'LineWidth',2)
      cb = colorbar;
      cb.Label.String = 'Similarity score';
      caxis([0 1])
      colormap(gca,cmaps.magma_r)

      mean_score = nanmean(score(iconf).(bintype{its}).(indvar_name{ivar})(:));
      wmean_score = wmean(score(iconf).(bintype{its}).(indvar_name{ivar})(:),...
         pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(:));
      ttl = sprintf('(%s) %s %sAMP-%s, weighted mean score = %.3f', ...
         Alphabet((iconf-1)*6+ivar/2), indvar_ename{ivar}, UorS, upper(bintype{its}), wmean_score);
      title(ttl,'FontWeight','normal')
      xticks(1:nvar2)
      yticks(1:nvar1)
      xticklabels(extractAfter(var2_str,lettersPattern))
      yticklabels(extractAfter(var1_str,lettersPattern))
      xlab_key = extractBefore(var2_str,digitsPattern);
      ylab_key = extractBefore(var1_str,digitsPattern);
      xlab = [initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
      ylab = [initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
      xlabel(xlab)
      ylabel(ylab)
      tiles = [tiles gca];

      rank_by_momcombo = ranking.(bintype{its}).(indvar_name{ivar});
      rank_str = sprintfc('%d', rank_by_momcombo);

   end

   % title(tl,[indvar_ename{ivar} indvar_units{ivar} ...
   %    ],'fontsize',20,'fontweight','bold')
end % ivar
end % iconf

for icase = 1:length(selected_cases)
   ivar1 = selected_cases{icase}(1); ivar2 = selected_cases{icase}(2);
   mconfig = mconfig_ls{USconfs(1)};
   its = 1;
   bintau_struct = loadnc('bin', indvar_name);
   amptau2m_struct = loadnc('amp', indvar_name);
   its = 2;
   binsbm_struct = loadnc('bin', indvar_name);
   ampsbm2m_struct = loadnc('amp', indvar_name);

   mconfig = mconfig_ls{USconfs(2)};
   its = 1;
   amptau4m_struct = loadnc('amp', indvar_name);
   its = 2;
   ampsbm4m_struct = loadnc('amp', indvar_name);

   time = bintau_struct.time;
   for ivar=vars2plot
      nexttile((icase-1)*2+(ivar-2)*2+9,[1,4])

      var_comp_raw_amptau2m = amptau2m_struct.(indvar_name{ivar});
      var_comp_amptau2m = var2phys(var_comp_raw_amptau2m,ivar,1);
      var_comp_raw_ampsbm2m = ampsbm2m_struct.(indvar_name{ivar});
      var_comp_ampsbm2m = var2phys(var_comp_raw_ampsbm2m,ivar,1);

      var_comp_raw_amptau4m = amptau4m_struct.(indvar_name{ivar});
      var_comp_amptau4m = var2phys(var_comp_raw_amptau4m,ivar,1);
      var_comp_raw_ampsbm4m = ampsbm4m_struct.(indvar_name{ivar});
      var_comp_ampsbm4m = var2phys(var_comp_raw_ampsbm4m,ivar,1);

      if ~contains(indvar_name{ivar}, amp_only_var)
         var_comp_raw_bintau = bintau_struct.(indvar_name{ivar});
         var_comp_bintau = var2phys(var_comp_raw_bintau,ivar,1);
         var_comp_raw_binsbm = binsbm_struct.(indvar_name{ivar});
         var_comp_binsbm = var2phys(var_comp_raw_binsbm,ivar,1);
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
      % xlim([0 max(time)])
      xlabel('Time [s]')
      ylabel([indvar_ename{ivar} indvar_units{ivar}])
      tiles = [tiles gca];
      grid
      box on

      % var1_key = extractBefore(var1_str{ivar1},digitsPattern);
      % var2_key = extractBefore(var2_str{ivar2},digitsPattern);
      % var1_symb = initVarSymb_dict(var1_key);
      % var1_val = extractAfter(var1_str{ivar1},lettersPattern);
      % var1_units = initVarUnit_dict(var1_key);
      % var1_titl = [var1_symb ' = ' var1_val ' ' var1_units(3:end-1)];
      % var2_symb = initVarSymb_dict(var2_key);
      % var2_val = extractAfter(var2_str{ivar2},lettersPattern);
      % var2_units = initVarUnit_dict(var2_key);
      % var2_titl = [var2_symb ' = ' var2_val ' ' var2_units(3:end-1)];

      title(['(',Alphabet(icase+ivar),') ',var1_str{ivar1}, var2_str{ivar2}],'fontweight','normal')

   end % ivar

end % icase

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

legend('show','location','best')

exportgraphics(gcf,['plots/p2/', mconfig, ' ', nikki, ' lwpspr ' bintype{SBMorTAU} ' rank sandwich.pdf'])
