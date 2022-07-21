clear
close all
clear global
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all mconfig

condonly_dev = devfun(load('pfm_summary/orig_thres_condnuc_pfm.mat').pfm);
collonly_dev = devfun(load('pfm_summary/orig_thres_collonly_pfm.mat').pfm);
evaponly_dev = devfun(load('pfm_summary/orig_thres_evaponly_pfm.mat').pfm);
sedonly_dev = devfun(load('pfm_summary/orig_thres_sedonly_pfm.mat').pfm);
condcoll_dev = devfun(load('pfm_summary/orig_thres_condcoll_pfm.mat').pfm);
condcollsed_dev = devfun(load('pfm_summary/orig_thres_condcollsed_pfm.mat').pfm);
fullmic_dev = devfun(load('pfm_summary/orig_thres_fullmic_pfm.mat').pfm);

global_var

%%
close all
figure('Position',[0 59 1200 800])
tl=tiledlayout(8,8,'TileSpacing','loose');

% fullmic
nexttile(4,[2 2])
mconfig = 'fullmic'; get_var_comp
dev2fig(fullmic_dev);
l=legend('TAU','SBM','location','best','fontsize',12);
title('(a) Full MP','FontSize',16)

% condcollsed
nexttile(19,[2 2])
mconfig = 'condcollsed'; get_var_comp
dev2fig(condcollsed_dev);
title('(b) Cond. Coll. Sed.','FontSize',16)

% condcoll
nexttile(34,[2 2])
mconfig = 'condcoll'; get_var_comp
dev2fig(condcoll_dev);
title('(c) Cond. Coll.','FontSize',16)

% cond
nexttile(49,[2 2])
mconfig = 'condonly'; get_var_comp
dev2fig(condonly_dev);
title('(d) Cond. + Nucl.','FontSize',16)

% coll
nexttile(51,[2 2])
mconfig = 'collonly'; get_var_comp
dev2fig(collonly_dev);
title('(e) Coll. only','FontSize',16)

% sed
nexttile(53,[2 2])
mconfig = 'sedonly'; get_var_comp
dev2fig(sedonly_dev);
title('(f) Sed. only','FontSize',16)

% evap
nexttile(55,[2 2])
mconfig = 'evaponly'; get_var_comp
dev2fig(evaponly_dev);
title('(g) Evap. only','FontSize',16)

ylabel(tl,'AMP-bin % difference','fontsize',20,...
   'fontweight','bold')

ax_pos{1}=tl.Children(end).OuterPosition;
for iax = 2:7
   ax_pos{iax}=tl.Children(end-iax).OuterPosition;
end

% ax_map={[2 3],[4 5],[5 6],[7 8],[8 9],[9 10]};
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

set(l,'Position',[0.265 0.855 0.07 0.07],'FontSize',12)

str1 = {'CWP: ', 'RWP: ', 'LWP: ', 'N\fontsize{10}c\fontsize{14}: ', ...
   'N\fontsize{10}r\fontsize{14}: ', ...
   'MSP: '};
str2 = {'cloud water path',...
   'rain water path',...
   'liquid water path',...
   'cloud droplet number',...
   'raindrop number',...
   'mean surface pcpt.'};

annotation('textbox',[0.658 0.767 0.18 0.153],'String', str1,...
           'FontSize',14,'edgecolor','none')
annotation('textbox',[0.695 0.767 0.18 0.154],'String', str2,...
           'FontSize',14,'edgecolor','none')
annotation('rectangle',[0.655 0.773 0.18 0.154])

exportgraphics(gcf,['plots/p1/pyramid.png'],'Resolution',300)
