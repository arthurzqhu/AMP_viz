clear
close all
clear global
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all 

% old pfm files: {{{

% condonly_dev1=devfun(load('pfm_summary/2021-11-27_condnuc_noinit_pfm.mat').pfm);
% collonly_dev1=devfun(load('pfm_summary/2022-02-24_collonly_pfm.mat').pfm);
% evaponly_dev1=devfun(load('pfm_summary/2022-01-25_evaponly_cloud_pfm.mat').pfm);
% sedonly_dev1=devfun(load('pfm_summary/2022-02-04_sedonly_i_pfm.mat').pfm);
% collsed_dev1=devfun(load('pfm_summary/2021-11-23_collsed_pfm.mat').pfm);
% condcoll_dev1=devfun(load('pfm_summary/2021-11-27_condcoll_pfm.mat').pfm);
% evapsed_dev1=devfun(load('pfm_summary/2021-11-27_evapsed_pfm.mat').pfm);
% condcollsed_dev1=devfun(load('pfm_summary/2021-11-27_condcollsed_pfm.mat').pfm);
% collsedevap_dev1=devfun(load('pfm_summary/2021-11-27_collsedevap_pfm.mat').pfm);
% fullmic_dev1=devfun(load('pfm_summary/2021-11-27_fullmic_pfm.mat').pfm);

% condonly_dev2=devfun(load('pfm_summary/2021-11-27_condnuc_noinit_pfm.mat').pfm,"a");
% collonly_dev2=devfun(load('pfm_summary/2022-02-24_collonly_pfm.mat').pfm,"a");
% evaponly_dev2=devfun(load('pfm_summary/2022-01-25_evaponly_cloud_pfm.mat').pfm,"a");
% sedonly_dev2=devfun(load('pfm_summary/2022-02-04_sedonly_i_pfm.mat').pfm,"a");
% collsed_dev2=devfun(load('pfm_summary/2021-11-23_collsed_pfm.mat').pfm,"a");
% condcoll_dev2=devfun(load('pfm_summary/2021-11-27_condcoll_pfm.mat').pfm,"a");
% evapsed_dev2=devfun(load('pfm_summary/2021-11-27_evapsed_pfm.mat').pfm,"a");
% condcollsed_dev2=devfun(load('pfm_summary/2021-11-27_condcollsed_pfm.mat').pfm,"a");
% collsedevap_dev2=devfun(load('pfm_summary/2021-11-27_collsedevap_pfm.mat').pfm,"a");
% fullmic_dev2=devfun(load('pfm_summary/2021-11-27_fullmic_pfm.mat').pfm,"a");

% condonly_dev2 = devfun(load('pfm_summary/normal_threshold_condnuc_pfm.mat').pfm,"a");
% collonly_dev2 = devfun(load('pfm_summary/normal_threshold_collonly_pfm.mat').pfm,"a");
% evaponly_dev2 = devfun(load('pfm_summary/normal_threshold_evaponly_pfm.mat').pfm,"a");
% sedonly_dev2 = devfun(load('pfm_summary/normal_threshold_sedonly_pfm.mat').pfm,"a");
% condcoll_dev2 = devfun(load('pfm_summary/normal_threshold_condcoll_pfm.mat').pfm,"a");
% collsed_dev2 = devfun(load('pfm_summary/normal_threshold_collsed_pfm.mat').pfm,"a");
% evapsed_dev2 = devfun(load('pfm_summary/normal_threshold_evapsed_pfm.mat').pfm,"a");
% condcollsed_dev2 = devfun(load('pfm_summary/normal_threshold_condcollsed_pfm.mat').pfm,"a");
% collsedevap_dev2 = devfun(load('pfm_summary/normal_threshold_collsedevap_pfm.mat').pfm,"a");
% fullmic_dev2 = devfun(load('pfm_summary/normal_threshold_fullmic_pfm.mat').pfm,"a");

% condonly_dev2 = devfun(load('pfm_summary/2022-04-21_condnuc_pfm.mat').pfm,"a");
% collonly_dev2 = devfun(load('pfm_summary/2022-04-21_collonly_pfm.mat').pfm,"a");
% evaponly_dev2 = devfun(load('pfm_summary/2022-04-21_evaponly_pfm.mat').pfm,"a");
% sedonly_dev2 = devfun(load('pfm_summary/2022-04-21_sedonly_pfm.mat').pfm,"a");
% condcoll_dev2 = devfun(load('pfm_summary/2022-04-21_condcoll_pfm.mat').pfm,"a");
% collsed_dev2 = devfun(load('pfm_summary/2022-04-21_collsed_pfm.mat').pfm,"a");
% evapsed_dev2 = devfun(load('pfm_summary/2022-04-21_evapsed_pfm.mat').pfm,"a");
% condcollsed_dev2 = devfun(load('pfm_summary/2022-04-21_condcollsed_pfm.mat').pfm,"a");
% collsedevap_dev2 = devfun(load('pfm_summary/2022-04-21_collsedevap_pfm.mat').pfm,"a");
% fullmic_dev2 = devfun(load('pfm_summary/2022-04-21_fullmic_pfm.mat').pfm,"a");


% }}}

condonly_dev1 = devfun(load('pfm_summary/2022-06-15_condnuc_pfm.mat').pfm);
collonly_dev1 = devfun(load('pfm_summary/2022-06-15_collonly_pfm.mat').pfm);
evaponly_dev1 = devfun(load('pfm_summary/2022-06-15_evaponly_pfm.mat').pfm);
sedonly_dev1 = devfun(load('pfm_summary/2022-06-15_sedonly_pfm.mat').pfm);
condcoll_dev1 = devfun(load('pfm_summary/2022-06-15_condcoll_pfm.mat').pfm);
collsed_dev1 = devfun(load('pfm_summary/2022-06-15_collsed_pfm.mat').pfm);
evapsed_dev1 = devfun(load('pfm_summary/2022-06-15_evapsed_pfm.mat').pfm);
condcollsed_dev1 = devfun(load('pfm_summary/2022-06-15_condcollsed_pfm.mat').pfm);
collsedevap_dev1 = devfun(load('pfm_summary/2022-06-15_collsedevap_pfm.mat').pfm);
fullmic_dev1 = devfun(load('pfm_summary/2022-06-15_fullmic_pfm.mat').pfm);

% these aren't being plotted right now: {{{

condonly_dev2 = devfun(load('pfm_summary/2022-04-21_condnuc_pfm.mat').pfm);
collonly_dev2 = devfun(load('pfm_summary/2022-04-21_collonly_pfm.mat').pfm);
evaponly_dev2 = devfun(load('pfm_summary/2022-04-21_evaponly_pfm.mat').pfm);
sedonly_dev2 = devfun(load('pfm_summary/2022-04-21_sedonly_pfm.mat').pfm);
condcoll_dev2 = devfun(load('pfm_summary/2022-04-21_condcoll_pfm.mat').pfm);
collsed_dev2 = devfun(load('pfm_summary/2022-04-21_collsed_pfm.mat').pfm);
evapsed_dev2 = devfun(load('pfm_summary/2022-04-21_evapsed_pfm.mat').pfm);
condcollsed_dev2 = devfun(load('pfm_summary/2022-04-21_condcollsed_pfm.mat').pfm);
collsedevap_dev2 = devfun(load('pfm_summary/2022-04-21_collsedevap_pfm.mat').pfm);
fullmic_dev2 = devfun(load('pfm_summary/2022-04-21_fullmic_pfm.mat').pfm);

% }}}

global_var
get_var_comp([3:8 10 16])

%%
close all
figure('Position',[0 59 1200 800])
tl=tiledlayout(8,8,'TileSpacing','loose');

% fullmic
nexttile(4,[2 2])
[X_fullmic,Y_fullmic]=dev2fig(fullmic_dev1,fullmic_dev2);
l=legend('TAU','SBM','location','best','fontsize',12);
% l=legend('TAU (D_{th} = 80\mum)','SBM (D_{th} = 80\mum)',...
%    'TAU (D_{th} = 50\mum)','SBM (D_{th} = 50\mum)',...
%    'location','best','fontsize',12);
title('(a) Full MP','FontSize',16)

% condevapcoll
nexttile(19,[2 2])
[X_condevapcoll,Y_condevapcoll]=dev2fig(condcollsed_dev1,condcollsed_dev2);
title('(b) Cond. Coll. Sed.','FontSize',16)

% omitted cases: {{{

% % evapsedcoll
% nexttile(13,[1 2])
% [X_rainshaft,Y_rainshaft]=dev2fig(collsedevap_dev1,collsedevap_dev2);
% title('(c) Evap. Coll. Sed.','FontSize',16)

% % collsed
% nexttile(20,[1 2])
% [X_collsed,Y_collsed]=dev2fig(collsed_dev1,collsed_dev2);
% title('(e) Coll. Sed.','FontSize',16)

% % evapsed
% nexttile(22,[1 2])
% [X_evapsed,Y_evapsed]=dev2fig(evapsed_dev1,evapsed_dev2);
% title('(f) Evap. Sed.','FontSize',16)

% }}}

% condcoll
nexttile(34,[2 2])
[X_condcoll,Y_condcoll]=dev2fig(condcoll_dev1,condcoll_dev2);
title('(c) Cond. Coll.','FontSize',16)

% cond
nexttile(49,[2 2])
[X_condonly,Y_condonly]=dev2fig(condonly_dev1,condonly_dev2);
title('(d) Cond. + Nucl.','FontSize',16)

% coll
nexttile(51,[2 2])
[X_collonly,Y_collonly]=dev2fig(collonly_dev1,collonly_dev2);
title('(e) Coll. only','FontSize',16)

% sed
nexttile(53,[2 2])
[X_sedonly,Y_sedonly]=dev2fig(sedonly_dev1,sedonly_dev2);
title('(f) Sed. only','FontSize',16)

% evap
nexttile(55,[2 2])
[X_evaponly,Y_evaponly]=dev2fig(evaponly_dev1,evaponly_dev2);
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

set(l,'Position',[0.27 0.85 0.07 0.07],'FontSize',12);

str1 = {'CWP: ', 'RWP: ', 'LWP: ', 'N\fontsize{10}c\fontsize{14}: ', ...
   'N\fontsize{10}r\fontsize{14}: ', ...
   'MSP: '};
str2 = {'cloud water path',...
   'rain water path',...
   'liquid water path',...
   'cloud droplet number',...
   'raindrop number',...
   'mean surface pcpt.'};

annotation('textbox',[0.07 0.791 0.20 0.135],'String', str1,...
           'FontSize',14,'edgecolor','none')
annotation('textbox',[0.11 0.791 0.20 0.135],'String', str2,...
           'FontSize',14,'edgecolor','none')
annotation('rectangle',[0.07 0.791 0.18 0.135])

% % fullmic - ccs
% axes('Position',[.64 .53 .15 .1])
% devdiff2fig(condcollsed_dev1, fullmic_dev1)
% title('(a) - (b): effect of Evap.')

% % ccs - cc
% axes('Position',[.48 .38 .15 .1])
% devdiff2fig(condcoll_dev1, condcollsed_dev1)
% title('(b) - (c): effect of Sed.')
% % ylabel('                                            Change in error (pp)')

exportgraphics(gcf,['plots/p1/pyramid_onlyweighted_massconv.jpg'],'Resolution',300)
