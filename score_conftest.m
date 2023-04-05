clearvars -except cmaps
clear global
close all

global mconfig

nikki = 'conftest';
global_var

% as opposed to mean ratio. should be set between 0 and 1. 0.5 means rsq and mr are equally important
rsq_importance = 0.5; 

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);

mconfig = mconfig_ls{1};
load('score_summary/scores_conftest.mat')
case_dep_var

indvar_name = fieldnames(score_trim(1).tau);
name_idx = contains(indvar_name_all,indvar_name);
indvar_ename = indvar_ename_all(name_idx);
indvar_units = indvar_units_all(name_idx);

vars = 1;
vare = length(indvar_name);

nvar1 = size(score_trim(1).(bintype{1}).(indvar_name{1}),1);
nvar2 = size(score_trim(1).(bintype{1}).(indvar_name{1}),2);

% create a structure for the final assessment
for its = 1:2
   for ivar = vars:vare
      score_lump.(bintype{its}).(indvar_name{ivar}) = zeros(nvar1, nvar2);
   end
end

for iconf = 1:length(score_trim)
   for ivar = vars:vare
      for its = 1:2
         score_lump.(bintype{its}).(indvar_name{ivar}) = ...
            score_lump.(bintype{its}).(indvar_name{ivar}) + ...
            score_trim(iconf).(bintype{its}).(indvar_name{ivar});
      end
   end
end

for ivar = vars:vare
   figure(2)
   set(gcf,'position',[0 0 1250 600])
   tl = tiledlayout(2,1);
   for its = 1:2
      nexttile
      score_lump_stretch = exp(score_lump.(bintype{its}).(indvar_name{ivar}));
      nanimagesc(score_lump_stretch')

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
            text(ivar1+.015,ivar2-.015,ranking_str{ivar1,ivar2},...
               'HorizontalAlignment','center','color',[.5 .5 .5])
            text(ivar1,ivar2,ranking_str{ivar1,ivar2},...
               'HorizontalAlignment','center','color',[1 1 1])
         end
      end


      cb = colorbar;
      cb.Label.String = 'Score';
      % caxis([.5 1])
      colormap(gca,cmaps.magma_r)
      title(upper(bintype{its}),'FontWeight','normal')
      xticks(1:nvar1)
      xticklabels(momcombo_trimmed)
      yticklabels(extractAfter(var2_str,lettersPattern))
      xlab_key = extractBefore(var1_str,digitsPattern);
      ylab_key = extractBefore(var2_str,digitsPattern);
      xlab = [initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
      ylab = [initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
      xlabel(tl,xlab,'fontsize',16)
      ylabel(tl,ylab,'fontsize',16)
   end
   saveas(gcf,['plots/', nikki, '/',indvar_name{ivar},' score exp heat map.png'])
end
