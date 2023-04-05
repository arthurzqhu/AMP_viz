clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set ...
   indvar_name_all indvar_ename_all indvar_units_all cwp_th

vnum = '0001';
nikki = 'UAMPvsSAMP_thr0';
global_var
mconfig_ls = get_mconfig_list(output_dir, nikki);
get_var_comp([4 10])

confs = [16 18];
mconfig = mconfig_ls{confs(1)};
disp(mconfig)
case_dep_var
amp2m_summ = load(['pfm_summary/' nikki '_' mconfig '_pfm.mat']);

mconfig = mconfig_ls{confs(2)};
disp(mconfig)
amp4m_summ = load(['pfm_summary/' nikki '_' mconfig '_pfm.mat']);

its = 2;

figure('position',[0 0 800 300])
tl = tiledlayout('flow');
nexttile
nanimagesc(amp2m_summ.pfm.mean_surface_ppt.(bintype{its}).rsq)
colormap(cmaps.coolwarm_rs)
title(['S-AMP-' upper(bintype{its})],'FontWeight','normal')
caxis([0 1])
xticks(1:length(var2_str))
yticks(1:length(var1_str))
xticklabels(extractAfter(var2_str,lettersPattern))
yticklabels(extractAfter(var1_str,lettersPattern))
for ix = 1.5:4.5
   iy = ix;
   xline(ix)
   yline(iy)
end

maxr = amp2m_summ.pfm.mean_surface_ppt.(bintype{its}).maxr;
maxr_str = sprintfc('%0.3g',maxr);
for ivar1 = 1:length(var1_str)
   for ivar2 = 1:length(var2_str)
      if isnan(maxr(ivar1,ivar2))
         continue
      end
      text(ivar2,ivar1,maxr_str{ivar1, ivar2},'FontSize',15,...
         'HorizontalAlignment','center','FontName','Menlo')
      text(ivar2+0.015,ivar1-0.015,maxr_str{ivar1, ivar2},'FontSize',15,...
         'HorizontalAlignment','center','FontName','Menlo')
   end
end

nexttile
nanimagesc(amp4m_summ.pfm.mean_surface_ppt.(bintype{its}).rsq)
colormap(cmaps.coolwarm_rs)
title(['U-AMP-' upper(bintype{its})],'FontWeight','normal')
caxis([0 1])
xticks(1:length(var2_str))
yticks(1:length(var1_str))
xticklabels(extractAfter(var2_str,lettersPattern))
yticklabels(extractAfter(var1_str,lettersPattern))
for ix = 1.5:4.5
   iy = ix;
   xline(ix)
   yline(iy)
end

maxr = amp4m_summ.pfm.mean_surface_ppt.(bintype{its}).maxr;
maxr_str = sprintfc('%0.3g',maxr);
for ivar1 = 1:length(var1_str)
   for ivar2 = 1:length(var2_str)
      if isnan(maxr(ivar1,ivar2))
         continue
      end
      text(ivar2,ivar1,maxr_str{ivar1, ivar2},'FontSize',15,...
         'HorizontalAlignment','center','FontName','Menlo')
      text(ivar2+0.015,ivar1-0.015,maxr_str{ivar1, ivar2},'FontSize',15,...
         'HorizontalAlignment','center','FontName','Menlo')
   end
end



cb = colorbar;
cb.Label.String = 'R^2 of (U-/S-)AMP vs bin';
cb.Label.FontSize = 12;

xlab_key = extractBefore(var2_str,digitsPattern);
ylab_key = extractBefore(var1_str,digitsPattern);
xlab = [initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
ylab = [initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
xlabel(tl,xlab,'FontSize',16)
ylabel(tl,ylab,'FontSize',16)
title(tl,'Timing of precipitation and ratio of peak ppt. rate (AMP/bin)','FontWeight','bold','FontSize',16)

% exportgraphics(gcf,['plots/aguplots/rsq sppt ', bintype{its},'.png'], 'Resolution', 300)
saveas(gcf,['plots/aguplots/rsq sppt ', bintype{its},'.fig'])
