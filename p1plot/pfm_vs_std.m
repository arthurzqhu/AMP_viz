clear
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set

vnum='0001';
nikki='2021-11-27';
run global_var.m

mconfig='fullmic';
load(['pfm_summary/' nikki '_' mconfig '_std.mat'])
run case_dep_var.m

sz = ones(length(var1_str),length(var2_str));
clr = ones(length(var1_str),length(var2_str));
for ivar1 = 1:length(var1_str)
   sz(ivar1,:)=10*2^(ivar1-1);
end
sz=flipud(sz); % so that more aerosol -> smaller sizes

for ivar2 = 1:length(var2_str)
   clr(:,ivar2)=ivar2;
end

dmcoll_err_sbm = pfm.dm_cloud_coll.sbm.mr;
dmcoll_val_sbm = -pfm.dm_cloud_coll.sbm.mpath_bin;
rwp_err_sbm = pfm.rain_M1_path.sbm.mr;
sppt_err_sbm = pfm.mean_surface_ppt.sbm.mr;
stdtab_sbm = pfm.stdtab_bin.sbm;

dmcoll_err_tau = pfm.dm_cloud_coll.tau.mr;
dmcoll_val_tau = -pfm.dm_cloud_coll.tau.mpath_bin;
rwp_err_tau = pfm.rain_M1_path.tau.mr;
sppt_err_tau = pfm.mean_surface_ppt.tau.mr;
stdtab_tau = pfm.stdtab_bin.tau;

figure(1); set(gcf,'position',[0 0 400 300])
hold on
scatter(stdtab_sbm(:),rwp_err_sbm(:),sz(:),clr(:),'filled')
scatter(stdtab_sbm(:),rwp_err_sbm(:),sz(:),color_order{1},'linewidth',1)
scatter(stdtab_tau(:),rwp_err_tau(:),sz(:),clr(:),'filled')
scatter(stdtab_tau(:),rwp_err_tau(:),sz(:),color_order{2},'linewidth',1)
hold off
cb=colorbar;
colormap(BrBG5)
cb.Ticks=[1.4 2.2 3 3.8 4.6];
cb.TickLabels=extractAfter(var2_str,lettersPattern);
cb.Label.String=extractBefore(var2_str{1},digitsPattern);
ylim([0 1])
grid
xlabel('std [\mum]')
ylabel('AMP/bin rwp ratio')
legend('','sbm','','tau','location','southeast')
saveas(gcf,[plot_dir ' std vs rwp_err.png'])

figure(2); set(gcf,'position',[0 0 400 300])
hold on
scatter(stdtab_sbm(:),dmcoll_err_sbm(:),sz(:),clr(:),'filled')
scatter(stdtab_sbm(:),dmcoll_err_sbm(:),sz(:),color_order{1},'linewidth',1)
scatter(stdtab_tau(:),dmcoll_err_tau(:),sz(:),clr(:),'filled')
scatter(stdtab_tau(:),dmcoll_err_tau(:),sz(:),color_order{2},'linewidth',1)
cb=colorbar;
colormap(BrBG5)
cb.Ticks=[1.4 2.2 3 3.8 4.6];
cb.TickLabels=extractAfter(var2_str,lettersPattern);
cb.Label.String=extractBefore(var2_str{1},digitsPattern);
hold off
grid
xlabel('std [\mum]')
ylabel('AMP/bin dmcoll ratio')
legend('','sbm','','tau','location','southeast')
saveas(gcf,[plot_dir ' std vs dmcoll_err.png'])

figure(3); set(gcf,'position',[0 0 400 300])
hold on
scatter(stdtab_sbm(:),sppt_err_sbm(:),sz(:),clr(:),'filled')
scatter(stdtab_sbm(:),sppt_err_sbm(:),sz(:),color_order{1},'linewidth',1)
scatter(stdtab_tau(:),sppt_err_tau(:),sz(:),clr(:),'filled')
scatter(stdtab_tau(:),sppt_err_tau(:),sz(:),color_order{2},'linewidth',1)
cb=colorbar;
colormap(BrBG5)
cb.Ticks=[1.4 2.2 3 3.8 4.6];
cb.TickLabels=extractAfter(var2_str,lettersPattern);
cb.Label.String=extractBefore(var2_str{1},digitsPattern);
grid
xlabel('std [\mum]')
ylabel('AMP/bin sppt ratio')
legend('','sbm','','tau','location','southeast')
saveas(gcf,[plot_dir ' std vs sppt_err.png'])

figure(4); set(gcf,'position',[0 0 400 300])
hold on
scatter(dmcoll_val_sbm(:),dmcoll_err_sbm(:),sz(:),clr(:),'filled')
scatter(dmcoll_val_sbm(:),dmcoll_err_sbm(:),sz(:),color_order{1},'linewidth',1)
scatter(dmcoll_val_tau(:),dmcoll_err_tau(:),sz(:),clr(:),'filled')
scatter(dmcoll_val_tau(:),dmcoll_err_tau(:),sz(:),color_order{2},'linewidth',1)
cb=colorbar;
colormap(BrBG5)
cb.Ticks=[1.4 2.2 3 3.8 4.6];
cb.TickLabels=extractAfter(var2_str,lettersPattern);
cb.Label.String=extractBefore(var2_str{1},digitsPattern);
hold off
grid
xlabel('dm coll [kg/kg/s]')
ylabel('AMP/bin dmcoll ratio')
legend('','sbm','','tau','location','southeast')
saveas(gcf,[plot_dir ' dmcoll_err vs dmcoll_val.png'])
