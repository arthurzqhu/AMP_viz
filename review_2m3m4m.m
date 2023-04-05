clear
close all
clear global
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all mconfig

collonly_dev2m = devfun(load('pfm_summary/UAMPvsSAMP_thr0_collonly_2m_pfm.mat').pfm);
collonly_dev3m = devfun(load('pfm_summary/UAMPvsSAMP_thr0_collonly_3m_pfm.mat').pfm);
collonly_dev4m = devfun(load('pfm_summary/UAMPvsSAMP_thr0_collonly_4m_M3045_pfm.mat').pfm);
collonly_devbin = devfun_bin(load('pfm_summary/orig_thres_collonly_pfm_bincomp.mat').pfm);

fullmic_dev2m = devfun(load('pfm_summary/UAMPvsSAMP_thr0_fullmic_2m_pfm.mat').pfm);
fullmic_dev3m = devfun(load('pfm_summary/UAMPvsSAMP_thr0_fullmic_3m_pfm.mat').pfm);
fullmic_dev4m = devfun(load('pfm_summary/UAMPvsSAMP_thr0_fullmic_4m_M3045_pfm.mat').pfm);
fullmic_devbin = devfun_bin(load('pfm_summary/orig_thres_fullmic_pfm_bincomp.mat').pfm);

global_var

mconfig = 'collonly'; get_var_comp

Xc = {'CWP','RWP','LWP','N_c','N_r'};
X=categorical(Xc);
X=reordercats(X,Xc);
nvar = length(Xc);

Y_val2m = reshape(struct2array(collonly_dev2m.mean_ratio),[],nvar)';
Y_val3m = reshape(struct2array(collonly_dev3m.mean_ratio),[],nvar)';
Y_val4m = reshape(struct2array(collonly_dev4m.mean_ratio),[],nvar)';
Y_valbin = struct2array(collonly_devbin.mean_ratio)';

Y_val2m = [Y_val2m ones(size(Y_valbin))];
Y_val3m = [Y_val3m ones(size(Y_valbin))];
Y_val4m = [Y_val4m Y_valbin];

close all
figure('position',[0 0 800 300])
tl = tiledlayout('flow');
nexttile
hold on

b3 = bar(X, Y_val2m, 1);
b3(1).FaceColor = color_order{1};
b3(2).FaceColor = color_order{2};
b3(3).FaceColor = color_order{3};
b3(1).FaceAlpha = 0.5;
b3(2).FaceAlpha = 0.5;
b3(3).FaceAlpha = 0.5;
b3(1).LineWidth = 1;
b3(2).LineWidth = 1;
b3(1).BaseValue = 1;
b3(1).LineStyle=':';
b3(2).LineStyle=':';
b3(1).BaseLine.Color = [.8 .8 .8];

b2 = bar(X, Y_val3m, 1);
b2(1).FaceColor = color_order{1};
b2(2).FaceColor = color_order{2};
b2(3).FaceColor = color_order{3};
b2(1).FaceAlpha = 0.5;
b2(2).FaceAlpha = 0.5;
b2(3).FaceAlpha = 0.5;
b2(1).LineWidth = 1;
b2(2).LineWidth = 1;
b2(1).BaseValue = 1;
b2(1).LineStyle='--';
b2(2).LineStyle='--';
b2(1).BaseLine.Color = [.8 .8 .8];

b1 = bar(X, Y_val4m, 1);
b1(1).FaceColor = color_order{1};
b1(2).FaceColor = color_order{2};
b1(3).FaceColor = color_order{3};
b1(1).FaceAlpha = 0.5;
b1(2).FaceAlpha = 0.5;
b1(3).FaceAlpha = 0.5;
b1(1).LineWidth = 1;
b1(2).LineWidth = 1;
b1(1).BaseValue = 1;
b1(1).BaseLine.Color = [.8 .8 .8];


hold off

set(gca,'YScale','log')
ylim([0.3 2.5])
yticks([.3 0.50 0.8 1 1.5 2 2.5])
yticklabels({'-70', '-50','-20','0','+50','+100', '+150'})
box on

grid()

ylabel('AMP/bin % difference')
title('(a) Collision only')

% -----------------
mconfig = 'fullmic'; get_var_comp

Xc = {'CWP','RWP','LWP','N_c','N_r','MSP'};
X=categorical(Xc);
X=reordercats(X,Xc);
nvar = length(Xc);

Y_val2m = reshape(struct2array(fullmic_dev2m.mean_ratio),[],nvar)';
Y_val3m = reshape(struct2array(fullmic_dev3m.mean_ratio),[],nvar)';
Y_val4m = reshape(struct2array(fullmic_dev4m.mean_ratio),[],nvar)';
Y_valbin = struct2array(fullmic_devbin.mean_ratio)';

Y_val2m = [Y_val2m ones(size(Y_valbin))];
Y_val3m = [Y_val3m ones(size(Y_valbin))];
Y_val4m = [Y_val4m Y_valbin];

nexttile
hold on

b3 = bar(X, Y_val2m, 1);
b3(1).FaceColor = color_order{1};
b3(2).FaceColor = color_order{2};
b3(3).FaceColor = color_order{3};
b3(1).FaceAlpha = 0.5;
b3(2).FaceAlpha = 0.5;
b3(3).FaceAlpha = 0.5;
b3(1).LineWidth = 1;
b3(2).LineWidth = 1;
b3(1).BaseValue = 1;
b3(1).LineStyle=':';
b3(2).LineStyle=':';
b3(1).BaseLine.Color = [.8 .8 .8];

b2 = bar(X, Y_val3m, 1);
b2(1).FaceColor = color_order{1};
b2(2).FaceColor = color_order{2};
b2(3).FaceColor = color_order{3};
b2(1).FaceAlpha = 0.5;
b2(2).FaceAlpha = 0.5;
b2(3).FaceAlpha = 0.5;
b2(1).LineWidth = 1;
b2(2).LineWidth = 1;
b2(1).BaseValue = 1;
b2(1).LineStyle='--';
b2(2).LineStyle='--';
b2(1).BaseLine.Color = [.8 .8 .8];

b1 = bar(X, Y_val4m, 1);
b1(1).FaceColor = color_order{1};
b1(2).FaceColor = color_order{2};
b1(3).FaceColor = color_order{3};
b1(1).FaceAlpha = 0.5;
b1(2).FaceAlpha = 0.5;
b1(3).FaceAlpha = 0.5;
b1(1).LineWidth = 1;
b1(2).LineWidth = 1;
b1(1).BaseValue = 1;
b1(1).BaseLine.Color = [.8 .8 .8];


hold off

set(gca,'YScale','log')
ylim([0.3 2.5])
yticks([.3 0.50 0.8 1 1.5 2 2.5])
yticklabels({'-70', '-50','-20','0','+50','+100', '+150'})
box on

grid()

ylabel('AMP/bin % difference')
title('(b) Full Microphysics')
legend('AMP/TAU (2M)', 'AMP/SBM (2M)', 'bin-TAU/bin-SBM', 'AMP/TAU (3M)', 'AMP/SBM (3M)', ...
   '', 'AMP/TAU (4M)', 'AMP/SBM (4M)','Location','southwest')

exportgraphics(gcf,'plots/2-4m comparison.png','Resolution',300)
