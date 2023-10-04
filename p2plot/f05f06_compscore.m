clearvars -except cmaps
clear global
close all

global mconfig script_name

script_name = mfilename;

nikki = 'conftest_fullmic';
global_var

% as opposed to mean ratio. should be set between 0 and 1. 0.5 means rsq and mr are equally important

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);

mconfig = mconfig_ls{1};
load([score_dir 'fullmic_scores_conftest.mat'])
% load('score_summary/fullmic_mval_conftest.mat')
% load('flags_summary/fullmic_flags_conftest.mat')
case_dep_var

indvar_name = fieldnames(score_trim(1).tau);
name_idx = contains(indvar_name_all,indvar_name);
indvar_ename = indvar_ename_all(name_idx);
indvar_units = indvar_units_all(name_idx);

vars = 1;
vare = length(indvar_name);
vars2plot = [4 2];

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
%          sum(mval.(indvar_name{ivar}).(bintype{its}))*16;
%    end
% end

for iconf = 1:length(score_trim)
   for its = 1:2
      for ivar = vars2plot
         score = score_trim(iconf).(bintype{its}).(indvar_name{ivar});
         score(isnan(score)) = -1;
         score(score<-1) = -1;
         score_lump.(bintype{its}).(indvar_name{ivar}) = ...
            score_lump.(bintype{its}).(indvar_name{ivar}) + score;
            % score_trim(iconf).(bintype{its}).(indvar_name{ivar}) * ...
            % mval_weight.(indvar_name{ivar}).(bintype{its})(iconf);
      end
   end
end

ifig = 0;
for ivar = vars2plot
   disp(ivar)

   figure(1)
   set(gcf,'position',[0 0 1000 600])
   tl = tiledlayout('flow');
   for its = 1:2
      nexttile(tl)
      set(gca,'XColor','none')
      set(gca,'YColor','none')

      nrow = 12;
      ncol = 10;
      tl_nest(its) = tiledlayout(tl,nrow,ncol,'TileSpacing','tight','padding','tight');
      tl_nest(its).Layout.Tile = its;
      score_lump_stretch = score_lump.(bintype{its}).(indvar_name{ivar});
      score_by_momcombo = mean(score_lump_stretch,2);
      score_by_momcombo(score_by_momcombo<0) = 0;
      score_by_sp = mean(score_lump_stretch,1);
      score_by_sp(score_by_sp<0)=0;

      % bar graph right outside of the heatmap
      nexttile(tl_nest(its),1,[1,ncol-1])
      clr = ceil(size(cmaps.magma_r,1) * score_by_sp/nconf);
      clr(clr<=0)=1;
      clr(isnan(clr))=1;
      for k = 1:length(score_by_sp)
         bar(k,score_by_sp(k),1,'FaceColor',cmaps.magma_r(clr(k),:),'FaceAlpha',.8)
         if k==1
            hold on
         end
      end
      hold off
      xlim([.5 length(score_by_sp)+.5])
      ylim([0 nconf])
      set(gca,'XColor','none')
      set(gca,'YColor','none')

      nexttile(tl_nest(its),2*ncol,[nrow-1,1])
      clr = ceil(size(cmaps.magma_r,1) * score_by_momcombo/nconf);
      clr(clr<=0)=1;
      clr(isnan(clr))=1;
      for k = 1:length(score_by_momcombo)
         barh(k,score_by_momcombo(k),1,'FaceColor',cmaps.magma_r(clr(k),:),'FaceAlpha',.8)
         if k==1
            hold on
         end
      end
      hold off
      xlim([0 nconf])
      ylim([.5 length(score_by_momcombo)+.5])
      set(gca,'XColor','none')
      set(gca,'YColor','none')
      cb = colorbar;
      cb.Label.String = 'Composite score';
      caxis([0 16])
      colormap(gca,cmaps.magma_r)
      set(gca,'fontsize',16)

      nexttile(tl_nest(its),ncol+1,[nrow-1,ncol-1])
      % score_lump_stretch = score_trim(iconf).(bintype{its}).(indvar_name{ivar});
      nanimagesc(score_lump_stretch)
      xline(5.5:5:25)


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

      caxis([0 16])
      colormap(gca,cmaps.magma_r)
      
      title(tl_nest(its),['(',Alphabet(its),') ',upper(bintype{its})],'FontWeight','normal')
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
      set(gca,'fontsize',16)
   end
   title(tl, ['Best configuration heatmap of ' indvar_ename{ivar}],...
      'fontsize',24,'fontweight','bold')
   exportgraphics(gcf,['plots/p2/f0',num2str(5+ifig),'_fullmic ' indvar_name{ivar}, ' score wbar.pdf'])
   saveas(gcf,['plots/p2/f0',num2str(5+ifig),'_fullmic ' indvar_name{ivar}, ' score wbar.fig'])
   ifig = ifig + 1;
   % exportgraphics(gcf,['plots/p2/individual_case/' indvar_name{ivar}, ' ', num2str(iconf), ' score.pdf'])
   % end
end
