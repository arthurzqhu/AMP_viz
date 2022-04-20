clear
close all
clear global
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all

condonly_dev=devfun(load('pfm_summary/2021-11-27_condnuc_noinit_pfm.mat').pfm);
collonly_dev=devfun(load('pfm_summary/2022-02-24_collonly_pfm.mat').pfm);
evaponly_dev=devfun(load('pfm_summary/2022-01-25_evaponly_cloud_pfm.mat').pfm);
sedonly_dev=devfun(load('pfm_summary/2022-02-04_sedonly_i_pfm.mat').pfm);

collsed_dev=devfun(load('pfm_summary/2021-11-23_collsed_pfm.mat').pfm);
condcoll_dev=devfun(load('pfm_summary/2021-11-27_condcoll_pfm.mat').pfm);
evapsed_dev=devfun(load('pfm_summary/2021-11-27_evapsed_pfm.mat').pfm);

condcollsed_dev=devfun(load('pfm_summary/2021-11-27_condcollsed_pfm.mat').pfm);
collsedevap_dev=devfun(load('pfm_summary/2021-11-27_collsedevap_pfm.mat').pfm);

fullmic_dev=devfun(load('pfm_summary/2021-11-27_fullmic_pfm.mat').pfm);


condonly_dev_a=devfun(load('pfm_summary/2021-11-27_condnuc_noinit_pfm.mat').pfm,"a");
collonly_dev_a=devfun(load('pfm_summary/2022-02-24_collonly_pfm.mat').pfm,"a");
evaponly_dev_a=devfun(load('pfm_summary/2022-01-25_evaponly_cloud_pfm.mat').pfm,"a");
sedonly_dev_a=devfun(load('pfm_summary/2022-02-04_sedonly_i_pfm.mat').pfm,"a");

collsed_dev_a=devfun(load('pfm_summary/2021-11-23_collsed_pfm.mat').pfm,"a");
condcoll_dev_a=devfun(load('pfm_summary/2021-11-27_condcoll_pfm.mat').pfm,"a");
evapsed_dev_a=devfun(load('pfm_summary/2021-11-27_evapsed_pfm.mat').pfm,"a");

condcollsed_dev_a=devfun(load('pfm_summary/2021-11-27_condcollsed_pfm.mat').pfm,"a");
collsedevap_dev_a=devfun(load('pfm_summary/2021-11-27_collsedevap_pfm.mat').pfm,"a");

fullmic_dev_a=devfun(load('pfm_summary/2021-11-27_fullmic_pfm.mat').pfm,"a");

global_var
get_var_comp([3:8 10 16])

%%
close all
figure('Position',[0 59 1200 800])
tl=tiledlayout(4,8,'TileSpacing','loose');

% fullmic
nexttile(3,[1 4])
[X_fullmic,Y_fullmic]=dev2fig(fullmic_dev,fullmic_dev_a);
l=legend('TAU (weighted mean)','SBM (weighted mean)',...
   'TAU (arithmatic mean)','SBM (arithmatic mean)',...
   'location','best','fontsize',12);
title('(a) Full MP','FontSize',16)

% condevapcoll
nexttile(11,[1 2])
[X_condevapcoll,Y_condevapcoll]=dev2fig(condcollsed_dev,condcollsed_dev_a);
title('(b) Cond. Coll. Sed.','FontSize',16)


% evapsedcoll
nexttile(13,[1 2])
[X_rainshaft,Y_rainshaft]=dev2fig(collsedevap_dev,collsedevap_dev_a);
title('(c) Evap. Coll. Sed.','FontSize',16)


% condcoll
nexttile(18,[1 2])
[X_condcoll,Y_condcoll]=dev2fig(condcoll_dev,condcoll_dev_a);
title('(d) Cond. Coll.','FontSize',16)


% collsed
nexttile(20,[1 2])
[X_collsed,Y_collsed]=dev2fig(collsed_dev,collsed_dev_a);
title('(e) Coll. Sed.','FontSize',16)


% evapsed
nexttile(22,[1 2])
[X_evapsed,Y_evapsed]=dev2fig(evapsed_dev,evapsed_dev_a);
title('(f) Evap. Sed.','FontSize',16)


% cond
nexttile(25,[1 2])
[X_condonly,Y_condonly]=dev2fig(condonly_dev,condonly_dev_a);
title('(g) Cond. (incl. Nucl.)','FontSize',16)


% coll
nexttile(27,[1 2])
[X_collonly,Y_collonly]=dev2fig(collonly_dev,collonly_dev_a);
title('(h) Coll. only','FontSize',16)

% sed
nexttile(29,[1 2])
[X_sedonly,Y_sedonly]=dev2fig(sedonly_dev,sedonly_dev_a);
title('(i) Sed. only','FontSize',16)


% evap
nexttile(31,[1 2])
[X_evaponly,Y_evaponly]=dev2fig(evaponly_dev,evaponly_dev_a);

title('(j) Evap. only','FontSize',16)

ylabel(tl,'AMP-bin % difference','fontsize',20,...
   'fontweight','bold')

ax_pos{1}=tl.Children(end).OuterPosition;
for iax = 2:10
   ax_pos{iax}=tl.Children(end-iax).OuterPosition;
end

ax_map={[2 3],[4 5],[5 6],[7 8],[8 9],[9 10]};

for iax=1:6
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

set(l,'Position',[0.73 0.85 0.15 0.07],'FontSize',12);

str={'CWP: cloud water path',...
   'RWP: rain water path',...
   'LWP: liquid water path',...
   'N_c:    cloud droplet number',...
   'N_r:     raindrop number',...
   't_{1/2,c}: cloud half-life',...
   'MSP:  mean surface pcpt.'};

annotation('textbox',[0.07 0.528 0.19 0.41],'String', str,...
           'FitBoxToText','on','FontSize',14)
exportgraphics(gcf,['plots/p1/pyramid.jpg'],'Resolution',300)
