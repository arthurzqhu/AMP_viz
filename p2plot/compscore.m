clearvars -except cmaps
clear global
close all

global mconfig

nikki = 'conftest_diffsp';
global_var

% as opposed to mean ratio. should be set between 0 and 1. 0.5 means rsq and mr are equally important
rsq_importance = 0.5; 

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);

mconfig = mconfig_ls{1};
load('score_summary/scores_conftest.mat')
load('score_summary/mval_conftest.mat')
case_dep_var

indvar_name = fieldnames(score_trim(1).tau);
name_idx = contains(indvar_name_all,indvar_name);
indvar_ename = indvar_ename_all(name_idx);
indvar_units = indvar_units_all(name_idx);

% vars = 4;
% vare = 5;%length(indvar_name);
vars2plot = [1 4 5];

nvar1 = size(score_trim(1).(bintype{1}).(indvar_name{1}),1);
nvar2 = size(score_trim(1).(bintype{1}).(indvar_name{1}),2);

% create a structure for the final assessment
for its = 1:2
   for ivar = vars2plot
      score_lump.(bintype{its}).(indvar_name{ivar}) = zeros(nvar1, nvar2);
   end
end

% for ivar = 1:5
%    for its = 1:2
%       mval_weight.(indvar_name{ivar}).(bintype{its}) = mval.(indvar_name{ivar}).(bintype{its})/...
%          sum(mval.(indvar_name{ivar}).(bintype{its}))*15;
%    end
% end

for iconf = 1:length(score_trim)
   for ivar = vars2plot
      for its = 1:2
         score = score_trim(iconf).(bintype{its}).(indvar_name{ivar});
         score(isnan(score)) = 0;
         score_lump.(bintype{its}).(indvar_name{ivar}) = ...
            score_lump.(bintype{its}).(indvar_name{ivar}) + score;
            % score_trim(iconf).(bintype{its}).(indvar_name{ivar}) * ...
            % mval_weight.(indvar_name{ivar}).(bintype{its})(iconf);
      end
   end
end

for ivar = vars2plot
   figure(1)
   set(gcf,'position',[0 0 1200 400])
   tl = tiledlayout(1,2);
   for its = 1:2
      nexttile
      score_lump_stretch = exp(score_lump.(bintype{its}).(indvar_name{ivar}));
      nanimagesc(score_lump_stretch)

      % get the ranking from score_lump_stretch
      sorted_score = sort(score_lump_stretch(:), 'descend', 'MissingPlacement','last');
      [~, ranking] = ismember(score_lump_stretch, sorted_score);
      ranking = reshape(ranking, size(score_lump_stretch));

      ranking_str = sprintfc('%d', ranking);
      % note the ranking 1-10 on the grid
      for ivar1 = 1:nvar1
         for ivar2 = 1:nvar2
            if ranking(ivar1, ivar2)>10 || ranking(ivar1, ivar2)==0
               continue
            end
            text(ivar2+.03,ivar1-.03,ranking_str{ivar1,ivar2},...
               'HorizontalAlignment','center','color',[0 0 0])
            text(ivar2,ivar1,ranking_str{ivar1,ivar2},...
               'HorizontalAlignment','center','color',[1 1 1])
         end
      end

      cb = colorbar;
      cb.Label.String = 'Composite score';
      colormap(gca,cmaps.magma_r)
      title(['(',Alphabet(its),') ',upper(bintype{its})],'FontWeight','normal')
      xticks(1:nvar2)
      xticklabels(sp_combo_str)
      yticks(1:nvar1)
      yticklabels(momcombo_trimmed)
      xlab_key = extractBefore(var2_str,digitsPattern);
      ylab_key = extractBefore(var1_str,digitsPattern);
      xlab = [initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
      ylab = [initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
      xlabel(tl,xlab,'fontsize',16)
      ylabel(tl,ylab,'fontsize',16)
   end
   title(tl, ['Best configuration heatmap of ' indvar_ename{ivar}],...
      'fontsize',16,'fontweight','bold')
   exportgraphics(gcf,['plots/p2/' indvar_name{ivar}, ' score.pdf'])
end
