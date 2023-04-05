clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name ...
   indvar_ename indvar_ename_set

nikki = '2023-03-13';
global_var

% as opposed to mean ratio. should be set between 0 and 1. 0.5 means rsq and mr are equally important
rsq_importance = 0.5; 

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);

figure(1)
set(gcf,'position',[0 0 1250 800])
tl = tiledlayout(3,8,'TileSpacing','compact','padding','compact');

for iconf = [1 2]%7:nconf
mconfig = mconfig_ls{iconf};
case_dep_var
load(['pfm_summary/',nikki,'_', mconfig, '_pfm.mat'])

indvar_name = fieldnames(pfm);
name_idx = contains(indvar_name_all,indvar_name);
indvar_ename = indvar_ename_all(name_idx);
indvar_units = indvar_units_all(name_idx);

vars = 1;
% vare = length(indvar_name)-1;
vare = 2;
% mom_tested = [1 2 4:9];
nvar1 = size(pfm.(indvar_name{1}).(bintype{1}).mr,1);
nvar2 = size(pfm.(indvar_name{1}).(bintype{1}).mr,2);

mom_cell = cell(nvar1,nvar2);
mom_matrix = zeros(nvar1,nvar2);

clear ranking

for its = 1
   for ivar = vars:vare
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
   end
end

for ivar = vars:vare

   for its = 1

      nexttile((iconf-1)*16+(ivar-1)*4+1, [1,4]) % make sure it's on the right grid
      score_by_momcombo = score(iconf).(bintype{its}).(indvar_name{ivar});
      nanimagesc(score_by_momcombo)
      cb = colorbar;
      cb.Label.String = 'Score';
      caxis([.5 1])
      colormap(gca,cmaps.magma_r)
      title([indvar_ename{ivar} ' ' UorS 'AMP-' upper(bintype{its})],'FontWeight','normal')
      if contains(mconfig,'momcombo')
         xticks(2:nvar2)
         yticks(1:nvar1-1)
         xlim([1.5 nvar2+.5])
         ylim([0.5 nvar1-.5])
         xticklabels(extractAfter(var1_str(2:end),lettersPattern))
      else
         xticks(1:nvar2)
         yticks(1:nvar1)
         xticklabels(extractAfter(var1_str,lettersPattern))
      end
      yticklabels(extractAfter(var2_str,lettersPattern))
      xlab_key = extractBefore(var2_str,digitsPattern);
      ylab_key = extractBefore(var1_str,digitsPattern);
      xlab = [initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
      ylab = [initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
      xlabel(xlab)
      ylabel(ylab)

      rank_by_momcombo = ranking.(bintype{its}).(indvar_name{ivar});
      rank_str = sprintfc('%d', rank_by_momcombo);

   end

   % title(tl,[indvar_ename{ivar} indvar_units{ivar} ...
   %    ],'fontsize',20,'fontweight','bold')
end %
end

selected_cases = {[2 3], [4 4]};

for icase = 1:length(selected_cases)
   ivar1 = selected_cases{icase}(1); ivar2 = selected_cases{icase}(2);
   mconfig = mconfig_ls{1};
   its = 1;
   bintau_struct = loadnc('bin', indvar_name);
   amptau2m_struct = loadnc('amp', indvar_name);
   its = 2;
   binsbm_struct = loadnc('bin', indvar_name);
   ampsbm2m_struct = loadnc('amp', indvar_name);

   mconfig = mconfig_ls{2};
   its = 1;
   amptau4m_struct = loadnc('amp', indvar_name);
   its = 2;
   ampsbm4m_struct = loadnc('amp', indvar_name);

   time = bintau_struct.time;
   for ivar=vars:vare
      nexttile((icase-1)*2+(ivar-1)*4+9,[1,2])

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
      plot(time, var_comp_bintau, 'Color', color_order{1}, 'LineWidth', 2)
      plot(time, var_comp_binsbm, 'Color', color_order{2}, 'LineWidth', 2)
      plot(time, var_comp_amptau2m, 'Color', color_order{1}, 'LineWidth', 1, 'LineStyle', ':')
      plot(time, var_comp_ampsbm2m, 'Color', color_order{2}, 'LineWidth', 1, 'LineStyle', ':')
      plot(time, var_comp_amptau4m, 'Color', color_order{1}, 'LineWidth', 1, 'LineStyle', '--')
      plot(time, var_comp_ampsbm4m, 'Color', color_order{2}, 'LineWidth', 1, 'LineStyle', '--')
      hold off
      xlim([0 max(time)])
      xlabel('Time [s]')
      ylabel([indvar_ename{ivar} indvar_units{ivar}])
   end
end



exportgraphics(gcf,'plots/p2/cloudrain rank.pdf')
