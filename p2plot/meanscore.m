clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name ...
   indvar_ename indvar_ename_set

nikki = '2023-03-17';
global_var

load('score_summary/mean_score_fullmic2.mat');
load('score_summary/wmean_score_fullmic2.mat');
var_interest = [3 4 5 10 21];
indvar_name = indvar_name_all(var_interest);
indvar_ename = indvar_ename_all(var_interest);
indvar_units = indvar_units_all(var_interest);

figure('position',[0 0 1000 640])
tl = tiledlayout('flow');

for its = 1:2
   nexttile
   nanimagesc(wmean_score.(bintype{its}))
   colormap(cmaps.magma_r)
   cb = colorbar;
   cb.Label.String = 'Similarity score';
   caxis([.5 1])
   xticks([1:5])
   xticklabels(indvar_ename)
   yticks([1 2])
   yticklabels({'S-AMP','U-AMP'})
   title(['(',Alphabet(its),') ' upper(bintype{its})])
   % hold on
   % scatter(repelem([1:5],2)+.3, [1 2 1 2 1 2 1 2 1 2]-.3, 100, ...
   %    mean_score.(bintype{its})(:),'filled',...
   %    'MarkerEdgeColor',[1 1 1],'LineWidth',1)
   % colormap(cmaps.magma_r10)
   % hold off
end

title(tl,'Mean Score Comparison between U-AMP and S-AMP',...
   'fontweight','bold','fontsize',20)
% saveas(gcf,['plots/' nikki '/mean_score.png'])
exportgraphics(gcf,'plots/p2/mean_score2.pdf')
