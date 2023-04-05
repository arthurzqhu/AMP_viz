clear
close all
clear global
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all mconfig

textclr = '#F6F4EC';
textclr_rgb = num2str(hex2rgb(textclr));
tilebg_color = '#414A5F';
figbg_color = '#2E3443';
wrapper_color = {'#16E8CF', '#FBE232'};

condonly_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_condnuc_4m_M3045_pfm.mat').pfm);
collonly_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_collonly_4m_M3045_pfm.mat').pfm);
evaponly_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_evaponly_4m_M3045_pfm.mat').pfm);
sedonly_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_sedonly_4m_M3045_pfm.mat').pfm);
condcoll_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_condcoll_4m_M3045_pfm.mat').pfm);
condcollsed_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_condcollsed_4m_M3045_pfm.mat').pfm);
fullmic_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_fullmic_4m_M3045_pfm.mat').pfm);

condonly_dev2 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_condnuc_2m_pfm.mat').pfm);
collonly_dev2 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_collonly_2m_pfm.mat').pfm);
evaponly_dev2 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_evaponly_2m_pfm.mat').pfm);
sedonly_dev2 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_sedonly_2m_pfm.mat').pfm);
condcoll_dev2 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_condcoll_2m_pfm.mat').pfm);
condcollsed_dev2 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_condcollsed_2m_pfm.mat').pfm);
fullmic_dev2 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_fullmic_2m_pfm.mat').pfm);

condonly_dev_bin = devfun_bin(load('pfm_summary/orig_thres_condnuc_pfm_bincomp.mat').pfm);
collonly_dev_bin = devfun_bin(load('pfm_summary/orig_thres_collonly_pfm_bincomp.mat').pfm);
evaponly_dev_bin = devfun_bin(load('pfm_summary/orig_thres_evaponly_pfm_bincomp.mat').pfm);
sedonly_dev_bin = devfun_bin(load('pfm_summary/orig_thres_sedonly_pfm_bincomp.mat').pfm);
condcoll_dev_bin = devfun_bin(load('pfm_summary/orig_thres_condcoll_pfm_bincomp.mat').pfm);
condcollsed_dev_bin = devfun_bin(load('pfm_summary/orig_thres_condcollsed_pfm_bincomp.mat').pfm);
fullmic_dev_bin = devfun_bin(load('pfm_summary/orig_thres_fullmic_pfm_bincomp.mat').pfm);


global_var

%%
close all
figure('Position',[0 59 1200 800])
tl=tiledlayout(8,8,'TileSpacing','loose');

% fullmic
nexttile(4,[2 2])
mconfig = 'fullmic'; get_var_comp
devcomp2fig(fullmic_dev1,fullmic_dev2,fullmic_dev_bin)
l=legend('U-AMP/TAU','U-AMP/SBM',...
   'bin-TAU/bin-SBM', ...
   'S-AMP/TAU','S-AMP/SBM',...
   'location','best','fontsize',12);
title('(a) Full MP','FontSize',16,'color',textclr)
set(gca,'Color',tilebg_color)
set(gca,'XColor',textclr)
set(gca,'YColor',textclr)

% condcollsed
nexttile(19,[2 2])
mconfig = 'condcollsed'; get_var_comp
devcomp2fig(condcollsed_dev1,condcollsed_dev2,condcollsed_dev_bin)
title('(b) Cond. Coll. Sed.','FontSize',16,'color',textclr)
set(gca,'Color',tilebg_color)
set(gca,'XColor',textclr)
set(gca,'YColor',textclr)

% condcoll
nexttile(34,[2 2])
mconfig = 'condcoll'; get_var_comp
devcomp2fig(condcoll_dev1,condcoll_dev2,condcoll_dev_bin)
title('(c) Cond. Coll.','FontSize',16,'color',textclr)
set(gca,'Color',tilebg_color)
set(gca,'XColor',textclr)
set(gca,'YColor',textclr)

% cond
nexttile(49,[2 2])
mconfig = 'condonly'; get_var_comp
devcomp2fig(condonly_dev1,condonly_dev2,condonly_dev_bin)
title('(d) Cond. + Nucl.','FontSize',16,'color',textclr)
set(gca,'Color',tilebg_color)
set(gca,'XColor',textclr)
set(gca,'YColor',textclr)

% coll
nexttile(51,[2 2])
mconfig = 'collonly'; get_var_comp
devcomp2fig(collonly_dev1,collonly_dev2,collonly_dev_bin)
title('(e) Coll. only','FontSize',16,'color',textclr)
set(gca,'Color',tilebg_color)
set(gca,'XColor',textclr)
set(gca,'YColor',textclr)

% sed
nexttile(53,[2 2])
mconfig = 'sedonly'; get_var_comp
devcomp2fig(sedonly_dev1,sedonly_dev2,sedonly_dev_bin)
title('(f) Sed. only','FontSize',16,'color',textclr)
set(gca,'Color',tilebg_color)
set(gca,'XColor',textclr)
set(gca,'YColor',textclr)

% evap
nexttile(55,[2 2])
mconfig = 'evaponly'; get_var_comp
devcomp2fig(evaponly_dev1,evaponly_dev2,evaponly_dev_bin)
title('(g) Evap. only','FontSize',16,'color',textclr)
set(gca,'Color',tilebg_color)
set(gca,'XColor',textclr)
set(gca,'YColor',textclr)

ax_pos{1}=tl.Children(end).OuterPosition;
for iax = 2:7
   ax_pos{iax}=tl.Children(end-iax).OuterPosition;
end

ax_map = {[2 7], [3 6], [4 5]};

str1 = {'CWP: ', 'RWP: ', 'LWP: ', 'N\fontsize{8}c\fontsize{12}: ', ...
   'N\fontsize{8}r\fontsize{12}: ', 'MSP: '};
str2 = {'cloud water path',...
   'rain water path',...
   'liquid water path',...
   'cloud droplet number',...
   'raindrop number',...
   'mean surface pcpt.'};

annotation('rectangle',[0.655 0.771 0.18 0.15],'facecolor',tilebg_color,...
           'edgecolor',textclr)
annotation('textbox',[0.665 0.763 0.18 0.15],'String', str1,...
           'FontSize',13,'edgecolor','none','color',textclr)
annotation('textbox',[0.700 0.766 0.18 0.15],'String', str2,...
           'FontSize',13,'edgecolor','none','color',textclr)

set(gca,'Color',tilebg_color)
set(gca,'XColor',textclr)
set(gca,'YColor',textclr)
set(l,'Position',[0.155 0.771 0.15 0.15],'FontSize',12,...
   'color',tilebg_color,'textcolor',textclr,'edgecolor',textclr)
set(gca,'GridColor',[1 1 1])


title(tl,sprintf(['\\color[rgb]{%s}U-AMP vs. S-AMP',...
   '\\color[rgb]{%s} & \\color[rgb]{%s}TAU\\color[rgb]{%s}-\\color[rgb]{%s}SBM',...
   '\\color[rgb]{%s} %% difference'], textclr_rgb, ...
   textclr_rgb, num2str(color_order{1}), ...
   textclr_rgb, num2str(color_order{2}), textclr_rgb),'FontSize',24,'FontWeight','bold')


exportgraphics(gcf,['plots/aguplots/pyramid_agu.png'],'Resolution',300,'BackgroundColor',figbg_color)
