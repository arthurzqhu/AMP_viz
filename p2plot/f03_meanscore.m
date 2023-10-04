clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name ...
   indvar_ename indvar_ename_set summ_dir script_name

script_name = mfilename;

nikki = 'fullmic';
global_var

fullmic2m = load([summ_dir nikki, '_fullmic_2m_pfm.mat']);
fullmic4m = load([summ_dir nikki, '_fullmic_4m_pfm.mat']);

fldnms = fieldnames(fullmic2m.pfm);
indvar_name = fldnms(1:end-1);
name_idx = contains(indvar_name_all,indvar_name);
indvar_ename = indvar_ename_all(name_idx);
indvar_units = indvar_units_all(name_idx);

for ivar = 1:length(indvar_name)
   for its = 1:2
      % mean_score.(bintype{its})(1,ivar) = ...
      %    nanmean(fullmic2m.pfm.(indvar_name{ivar}).(bintype{its}).rsq(:));
      % mean_score.(bintype{its})(2,ivar) = ...
      %    nanmean(fullmic4m.pfm.(indvar_name{ivar}).(bintype{its}).rsq(:));
      mean_score.(bintype{its})(1,ivar) = ...
         wmean(fullmic2m.pfm.(indvar_name{ivar}).(bintype{its}).rsq(:),...
         fullmic2m.pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(:));
      mean_score.(bintype{its})(2,ivar) = ...
         wmean(fullmic4m.pfm.(indvar_name{ivar}).(bintype{its}).rsq(:),...
         fullmic4m.pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(:));
   end
end

figure('position',[0 0 1000 640])
tl = tiledlayout('flow');

for its = 1:2
   nexttile
   nanimagesc(mean_score.(bintype{its}))
   colormap(cmaps.magma_r)
   cb = colorbar;
   cb.Label.String = 'Mean Similarity Score';
   caxis([0 1])
   xticks([1:5])
   xticklabels(indvar_ename)
   yticks([1 2])
   yticklabels({'S-AMP','U-AMP'})
   title(['(',Alphabet(its),') ' upper(bintype{its})])
   set(gca,'fontsize',16)
   % hold on
   % scatter(repelem([1:4],2)+.3, [1 2 1 2 1 2 1 2]-.3, 100, ...
   %    mean_score.(bintype{its})(:),'filled',...
   %    'MarkerEdgeColor',[1 1 1],'LineWidth',1)
   % hold off
   colormap(cmaps.magma_r10)
end

title(tl,'Mean Score Comparison between U-AMP and S-AMP',...
   'fontweight','bold','fontsize',24)
exportgraphics(gcf,'plots/p2/f03_wmean_score.pdf')
saveas(gcf,'plots/p2/f03_wmean_score.fig')
