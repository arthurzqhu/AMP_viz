clear
close all
clear global
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all mconfig

condonly_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_condnuc_3m_pfm.mat').pfm);
collonly_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_collonly_3m_pfm.mat').pfm);
evaponly_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_evaponly_3m_pfm.mat').pfm);
sedonly_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_sedonly_3m_pfm.mat').pfm);
condcoll_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_condcoll_3m_pfm.mat').pfm);
condcollsed_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_condcollsed_3m_pfm.mat').pfm);
fullmic_dev1 = devfun(load('pfm_summary/UAMPvsSAMP_thr0_fullmic_3m_pfm.mat').pfm);

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
l=legend('AMP/TAU (3M)','AMP/SBM (3M)',...
   'bin-TAU/bin-SBM', ...
   'AMP/TAU (2M)','AMP/SBM (2M)',...
   'location','best','fontsize',12);
title('(a) Full MP','FontSize',16)

% condcollsed
nexttile(19,[2 2])
mconfig = 'condcollsed'; get_var_comp
devcomp2fig(condcollsed_dev1,condcollsed_dev2,condcollsed_dev_bin)
title('(b) Cond. Coll. Sed.','FontSize',16)

% condcoll
nexttile(34,[2 2])
mconfig = 'condcoll'; get_var_comp
devcomp2fig(condcoll_dev1,condcoll_dev2,condcoll_dev_bin)
title('(c) Cond. Coll.','FontSize',16)

% cond
nexttile(49,[2 2])
mconfig = 'condonly'; get_var_comp
devcomp2fig(condonly_dev1,condonly_dev2,condonly_dev_bin)
title('(d) Cond. + Nucl.','FontSize',16)

% coll
nexttile(51,[2 2])
mconfig = 'collonly'; get_var_comp
devcomp2fig(collonly_dev1,collonly_dev2,collonly_dev_bin)
title('(e) Coll. only','FontSize',16)

% sed
nexttile(53,[2 2])
mconfig = 'sedonly'; get_var_comp
devcomp2fig(sedonly_dev1,sedonly_dev2,sedonly_dev_bin)
title('(f) Sed. only','FontSize',16)

% evap
nexttile(55,[2 2])
mconfig = 'evaponly'; get_var_comp
devcomp2fig(evaponly_dev1,evaponly_dev2,evaponly_dev_bin)
title('(g) Evap. only','FontSize',16)

ylabel(tl,'AMP-bin & TAU-SBM % difference','fontsize',20,...
   'fontweight','bold')

ax_pos{1}=tl.Children(end).OuterPosition;
for iax = 2:7
   ax_pos{iax}=tl.Children(end-iax).OuterPosition;
end

ax_map = {[2 7], [3 6], [4 5]};

for iax=1:length(ax_map)
   xul = ax_pos{iax}(1)+0.5*ax_pos{iax}(3);
   xur = ax_pos{iax}(1)+0.6*ax_pos{iax}(3);
   if iax==1
      xur = ax_pos{iax}(1)+0.55*ax_pos{iax}(3); % because (a) is wider than everyone else
   end
   xl = ax_pos{ax_map{iax}(1)}(1)+0.95*ax_pos{ax_map{iax}(1)}(3);
   xr = ax_pos{ax_map{iax}(2)}(1)+0.15*ax_pos{ax_map{iax}(2)}(3);
   
   yu = ax_pos{iax}(2);
   yl = ax_pos{ax_map{iax}(1)}(2)+0.95*ax_pos{ax_map{iax}(1)}(4);
   yr = ax_pos{ax_map{iax}(2)}(2)+0.95*ax_pos{ax_map{iax}(2)}(4);
   
   annotation('arrow',[xl xul],[yl yu],'LineWidth',1,'color',[.5 .5 .5 .8])
   annotation('arrow',[xr xur],[yr yu],'LineWidth',1,'color',[.5 .5 .5 .8])

end

set(l,'Position',[0.155 0.771 0.15 0.15],'FontSize',12)

str1 = {'CWP: ', 'RWP: ', 'LWP: ', 'N\fontsize{10}c\fontsize{14}: ', ...
   'N\fontsize{10}r\fontsize{14}: ', ...
   'MSP: '};
str2 = {'cloud water path',...
   'rain water path',...
   'liquid water path',...
   'cloud droplet number',...
   'raindrop number',...
   'mean surface pcpt.'};

annotation('textbox',[0.658 0.765 0.18 0.15],'String', str1,...
           'FontSize',14,'edgecolor','none')
annotation('textbox',[0.698 0.765 0.18 0.15],'String', str2,...
           'FontSize',14,'edgecolor','none')
annotation('rectangle',[0.655 0.771 0.18 0.15])

title(tl,['Pyramid figure - 3M vs. 2M'],'fontsize',24,'fontweight','bold')

exportgraphics(gcf,['plots/pyramid_2m3m.png'],'Resolution',300)
