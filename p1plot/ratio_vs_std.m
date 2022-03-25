clear
clear global
close all

run global_var

collonly_pfm = load('pfm_summary/2022-02-24_collonly_std.mat');
fullmp_pfm = load('pfm_summary/2021-11-27_fullmic_std.mat');

fm_sppt_err_sbm = fullmp_pfm.pfm.mean_surface_ppt.sbm.mr;
fm_stdtab_sbm = fullmp_pfm.pfm.stdtab_bin.sbm;
fm_sppt_err_tau = fullmp_pfm.pfm.mean_surface_ppt.tau.mr;
fm_stdtab_tau = fullmp_pfm.pfm.stdtab_bin.tau;


co_rwp_err_sbm = collonly_pfm.pfm.rain_M1_path.sbm.mr;
co_stdtab_sbm = collonly_pfm.pfm.stdtab_bin.sbm;
co_rwp_err_tau = collonly_pfm.pfm.rain_M1_path.tau.mr;
co_stdtab_tau = collonly_pfm.pfm.stdtab_bin.tau;

sz = ones(size(co_stdtab_sbm,1),size(co_stdtab_sbm,2));
clr = ones(size(co_stdtab_sbm,1),size(co_stdtab_sbm,2));
for ivar1 = 1:size(co_stdtab_sbm,1)
   sz(ivar1,:) = exp(ivar1)*2;
end

for ivar2 = 1:size(co_stdtab_sbm,2)
   clr(:,ivar2)=ivar2;
end


figure('position',[0 0 1000 350])
tl = tiledlayout('flow');

ax1=nexttile;
hold on
scatter(co_stdtab_sbm(:),co_rwp_err_sbm(:),sz(:),clr(:),'filled')
scatter(co_stdtab_sbm(:),co_rwp_err_sbm(:),sz(:),color_order{1},'linewidth',1.5)
scatter(co_stdtab_tau(:),co_rwp_err_tau(:),sz(:),clr(:),'filled')
scatter(co_stdtab_tau(:),co_rwp_err_tau(:),sz(:),color_order{2},'linewidth',1.5)

% --- annotate scatter size --- 
curr_xlim = xlim;
annt_xpos1 = 0.785;
annt_x1 = repelem(curr_xlim(1)*(1-annt_xpos1) + curr_xlim(2)*annt_xpos1, size(co_stdtab_sbm,1));
annt_y1 = linspace(0.2,0.45,size(co_stdtab_sbm,1));
scatter(annt_x1, annt_y1, sz(:,1),[.3 .3 .3],'linewidth',1.5)

text(annt_x1(1)*0.99, 0.52, '$\overline{D_m}$ [$\mu$m]','interpreter','latex')
text(annt_x1(1)*1.04, annt_y1(5), '27')
text(annt_x1(1)*1.04, annt_y1(4), '24')
text(annt_x1(1)*1.04, annt_y1(3), '21')
text(annt_x1(1)*1.04, annt_y1(2), '18')
text(annt_x1(1)*1.04, annt_y1(1), '15')
% --- finish annotating ... except box ---

cb=colorbar;
colormap(ax1,BrBG5)
cb.Ticks=[1.4 2.2 3 3.8 4.6];
cb.TickLabels={'1','3','5',7','9'};
cb.Label.String='shape parameter';
grid
ylabel('AMP/bin ratio (rain water path)')
l1 = legend('','sbm','','tau','location','southeast');
set(gca,'fontsize',12)
title('(a) Collision only','fontsize',24)


sz = ones(size(fm_stdtab_sbm,1),size(fm_stdtab_sbm,2));
clr = ones(size(fm_stdtab_sbm,1),size(fm_stdtab_sbm,2));
for ivar1 = 1:size(fm_stdtab_sbm,1)
   sz(ivar1,:) = exp(ivar1)*2;
end
sz = flipud(sz);

for ivar2 = 1:size(fm_stdtab_sbm,2)
   clr(:,ivar2)=ivar2;
end

ax2=nexttile;
hold on
scatter(fm_stdtab_sbm(:),fm_sppt_err_sbm(:),sz(:),clr(:),'filled')
scatter(fm_stdtab_sbm(:),fm_sppt_err_sbm(:),sz(:),color_order{1},'linewidth',1.5)
scatter(fm_stdtab_tau(:),fm_sppt_err_tau(:),sz(:),clr(:),'filled')
scatter(fm_stdtab_tau(:),fm_sppt_err_tau(:),sz(:),color_order{2},'linewidth',1.5)

% --- annotate scatter size --- 
curr_xlim = xlim;
annt_xpos2 = 0.845;
annt_x2 = repelem(curr_xlim(1)*(1-annt_xpos2) + curr_xlim(2)*annt_xpos2, size(fm_stdtab_sbm,1));
annt_y2 = linspace(0.2,0.45,size(fm_stdtab_sbm,1));
scatter(annt_x2, annt_y2, sz(end:-1:1,1),[.3 .3 .3],'linewidth',1.5)

text(annt_x2(1)*0.985, 0.52, '$N_a$ [$cm^{-3}$]','interpreter','latex')
text(annt_x2(1)*1.05, annt_y2(5), '100')
text(annt_x2(1)*1.05, annt_y2(4), '200')
text(annt_x2(1)*1.05, annt_y2(3), '400')
text(annt_x2(1)*1.05, annt_y2(2), '800')
text(annt_x2(1)*1.04, annt_y2(1), '1600')
% --- finish annotating ... except text ---

cb=colorbar;
colormap(ax2,coolwarm5)
cb.Ticks=[1.4 2.2 3 3.8 4.6];
cb.TickLabels={'1','2','4','8','16'};
cb.Label.String='w [m/s]';
grid
ylabel('AMP/bin ratio (mean surface precipitation)')
l2 = legend('','sbm','','tau','location','southeast');
set(gca,'fontsize',12)

% --- annotate scatter size box ---
xa = l1.Position(1);
ya = l1.Position(2)+l1.Position(4)+0.04;
dx = l1.Position(3);
dy = 0.285;
annotation('rectangle',[xa,ya,dx,dy])


xa = l2.Position(1);
ya = l2.Position(2)+l2.Position(4)+0.04;
dx = l2.Position(3);
dy = 0.285;
annotation('rectangle',[xa,ya,dx,dy])
% --- finishing annotating ---

xlabel(tl,'Standard deviation [\mum]','FontSize',16)
title('(b) Full microphysics','fontsize',24)
exportgraphics(gcf,'plots/p1/fullmp_error_corr.jpg','resolution',300)
