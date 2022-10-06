clearvars -except cmaps
clear global
close all

global ivar1 ivar2 its nikki mconfig output_dir vnum ...
   bintype var1_str var2_str

doload = 0;

global_var

if ~doload

collonly_pfm_nt = load('pfm_summary/orig_thres_collonly_pfm.mat');
fullmp_pfm_nt = load('pfm_summary/orig_thres_fullmic_pfm.mat');
collonly_pfm_lt = load('pfm_summary/lower_threshold_collonly_pfm.mat');
fullmp_pfm_lt = load('pfm_summary/lower_threshold_fullmic_pfm.mat');

nikki = 'orig_thres';
mconfig = 'collonly';
case_dep_var
for its = 1:length(bintype)
   if its == 1
      binmean = load('diamg_tau.txt');
      nkr = 34;
   else
      binmean = load('diamg_sbm.txt');
      nkr = 33;
   end
   for ivar1 = 1:length(var1_str)
      for ivar2 = 1:length(var2_str)
         bin_struct = loadnc('bin');
         bin_struct.mass_dist(bin_struct.mass_dist < 0) = 0;
         time = bin_struct.time;
         z = bin_struct.z;
         lwcprof_tstd = bin_struct.diagM3_liq(1, :);
         collonly_pfm_nt.pfm.stdtab_bin.(bintype{its})(ivar1, ivar2) = ...
            wmean(arrayfun(@(x) exp(nanstd(log(binmean), ...
            bin_struct.mass_dist(1, 1:nkr, x))), 1:120), lwcprof_tstd);
      end
   end
end

mconfig = 'fullmic';
case_dep_var
for its = 1:length(bintype)
   if its == 1
      binmean = load('diamg_tau.txt');
      nkr = 34;
   else
      binmean = load('diamg_sbm.txt');
      nkr = 33;
   end
   for ivar1 = 1:length(var1_str)
      for ivar2 = 1:length(var2_str)
         bin_struct = loadnc('bin');
         bin_struct.mass_dist(bin_struct.mass_dist < 0) = 0;
         time = bin_struct.time;
         z = bin_struct.z;
         tstd = time(end) / 4;
         lwcprof_tstd = bin_struct.diagM3_liq(tstd, :);
         fullmp_pfm_nt.pfm.stdtab_bin.(bintype{its})(ivar1, ivar2) = ...
            wmean(arrayfun(@(x) exp(nanstd(log(binmean), ...
            bin_struct.mass_dist(tstd, 1:nkr, x))), 1:120), lwcprof_tstd);
      end
   end
end

nikki = 'lower_thres';
mconfig = 'collonly';
case_dep_var
for its = 1:length(bintype)
   if its == 1
      binmean = load('diamg_tau.txt');
      nkr = 34;
   else
      binmean = load('diamg_sbm.txt');
      nkr = 33;
   end
   for ivar1 = 1:length(var1_str)
      for ivar2 = 1:length(var2_str)
         bin_struct = loadnc('bin');
         bin_struct.mass_dist(bin_struct.mass_dist < 0) = 0;
         time = bin_struct.time;
         z = bin_struct.z;
         lwcprof_tstd = bin_struct.diagM3_liq(1, :);
         collonly_pfm_lt.pfm.stdtab_bin.(bintype{its})(ivar1, ivar2) = ...
            wmean(arrayfun(@(x) exp(nanstd(log(binmean), ...
            bin_struct.mass_dist(1, 1:nkr, x))), 1:120), lwcprof_tstd);
      end
   end
end

mconfig = 'fullmic';
case_dep_var
for its = 1:length(bintype)
   if its == 1
      binmean = load('diamg_tau.txt');
      nkr = 34;
   else
      binmean = load('diamg_sbm.txt');
      nkr = 33;
   end
   for ivar1 = 1:length(var1_str)
      for ivar2 = 1:length(var2_str)
         bin_struct = loadnc('bin');
         bin_struct.mass_dist(bin_struct.mass_dist < 0) = 0;
         time = bin_struct.time;
         z = bin_struct.z;
         tstd = time(end) / 4;
         lwcprof_tstd = bin_struct.diagM3_liq(tstd, :);
         fullmp_pfm_lt.pfm.stdtab_bin.(bintype{its})(ivar1, ivar2) = ...
            wmean(arrayfun(@(x) exp(nanstd(log(binmean), ...
            bin_struct.mass_dist(tstd, 1:nkr, x))), 1:120), lwcprof_tstd);
      end
   end
end

save('pfm_summary/collonly_pfm_nt_gs.mat','collonly_pfm_nt')
save('pfm_summary/collonly_pfm_lt_gs.mat','collonly_pfm_lt')
save('pfm_summary/fullmp_pfm_nt_gs.mat','fullmp_pfm_nt')
save('pfm_summary/fullmp_pfm_lt_gs.mat','fullmp_pfm_lt')

else
load('pfm_summary/collonly_pfm_nt_gs.mat')
load('pfm_summary/collonly_pfm_lt_gs.mat')
load('pfm_summary/fullmp_pfm_nt_gs.mat')
load('pfm_summary/fullmp_pfm_lt_gs.mat')
end

fm_sppt_err_sbm_nt = fullmp_pfm_nt.pfm.mean_surface_ppt.sbm.mr;
fm_sppt_err_tau_nt = fullmp_pfm_nt.pfm.mean_surface_ppt.tau.mr;
fm_sppt_err_sbm_lt = fullmp_pfm_lt.pfm.mean_surface_ppt.sbm.mr;
fm_sppt_err_tau_lt = fullmp_pfm_lt.pfm.mean_surface_ppt.tau.mr;
co_rwp_err_sbm_nt = collonly_pfm_nt.pfm.rain_M1_path.sbm.mr;
co_rwp_err_tau_nt = collonly_pfm_nt.pfm.rain_M1_path.tau.mr;
co_rwp_err_sbm_lt = collonly_pfm_lt.pfm.rain_M1_path.sbm.mr;
co_rwp_err_tau_lt = collonly_pfm_lt.pfm.rain_M1_path.tau.mr;


%% 

co_stdtab_tau_nt = collonly_pfm_nt.pfm.stdtab_bin.tau;
co_stdtab_sbm_nt = collonly_pfm_nt.pfm.stdtab_bin.sbm;
fm_stdtab_tau_nt = fullmp_pfm_nt.pfm.stdtab_bin.tau;
fm_stdtab_sbm_nt = fullmp_pfm_nt.pfm.stdtab_bin.sbm;
co_stdtab_tau_lt = collonly_pfm_lt.pfm.stdtab_bin.tau;
co_stdtab_sbm_lt = collonly_pfm_lt.pfm.stdtab_bin.sbm;
fm_stdtab_tau_lt = fullmp_pfm_lt.pfm.stdtab_bin.tau;
fm_stdtab_sbm_lt = fullmp_pfm_lt.pfm.stdtab_bin.sbm;

sz = ones(size(co_stdtab_sbm_nt, 1), size(co_stdtab_sbm_nt, 2));
clr = ones(size(co_stdtab_sbm_nt, 1), size(co_stdtab_sbm_nt, 2));
for ivar1 = 1:size(co_stdtab_sbm_nt, 1)
   sz(ivar1, :) = exp(ivar1)*2;
end

for ivar2 = 1:size(co_stdtab_sbm_nt, 2)
   clr(:, ivar2)=ivar2;
end

figure('position', [0 0 1000 700])
tl = tiledlayout('flow');

ax1=nexttile;
hold on
scatter(co_stdtab_sbm_nt(:), co_rwp_err_sbm_nt(:), sz(:), clr(:), 'filled')
scatter(co_stdtab_sbm_nt(:), co_rwp_err_sbm_nt(:), sz(:), color_order{1}, 'linewidth', 1.5)
scatter(co_stdtab_tau_nt(:), co_rwp_err_tau_nt(:), sz(:), clr(:), 'filled')
scatter(co_stdtab_tau_nt(:), co_rwp_err_tau_nt(:), sz(:), color_order{2}, 'linewidth', 1.5)
% xlim([0 40])
ylim([0 1])

% --- annotate scatter size --- 
curr_xlim = xlim;
curr_ylim = ylim;
annt_xpos1 = 0.845;
annt_x1 = repelem(curr_xlim(1)*(1-annt_xpos1) + curr_xlim(2)*annt_xpos1, size(co_stdtab_sbm_nt, 1));
% annt_y1 = linspace(0.24, 0.49, size(co_stdtab_sbm_nt, 1));
% annt_y1 = logspace(log10(0.24), log10(0.49), size(co_stdtab_sbm_nt, 1));
annt_y1 = logspace(log10((curr_ylim(2) - curr_ylim(1)) * 0.24) + curr_ylim(1), ...
                   log10((curr_ylim(2) - curr_ylim(1)) * 0.49) + curr_ylim(1), ...
                   size(co_stdtab_sbm_nt, 1));
scatter(annt_x1, annt_y1, sz(:, 1), [.3 .3 .3], 'linewidth', 1.5)

text(annt_x1(1)*0.985, (curr_ylim(2) - curr_ylim(1)) * 0.56 + curr_ylim(1), ...
                       '$\overline{D_m}$ [$\mu$m]', 'interpreter', 'latex')
text(annt_x1(1)*1.06, annt_y1(5), '27')
text(annt_x1(1)*1.06, annt_y1(4), '24')
text(annt_x1(1)*1.06, annt_y1(3), '21')
text(annt_x1(1)*1.06, annt_y1(2), '18')
text(annt_x1(1)*1.06, annt_y1(1), '15')
% --- finish annotating ... except box ---

cb=colorbar;
colormap(ax1, cmaps.BrBG5)
cb.Ticks=[1.4:0.8:4.6];
cb.TickLabels={'1', '3', '5', '7', '9'};
cb.Label.String='shape parameter';
grid
ylabel('AMP/bin ratio (rain water path)')
l1 = legend('', 'sbm', '', 'tau', 'location', 'southeast');
set(gca, 'fontsize', 12)
title('(a) Collision only (D\fontsize{16}t\fontsize{24} = 80 \mum)', 'fontsize', 24)


sz = ones(size(fm_stdtab_sbm_nt, 1), size(fm_stdtab_sbm_nt, 2));
clr = ones(size(fm_stdtab_sbm_nt, 1), size(fm_stdtab_sbm_nt, 2));
for ivar1 = 1:size(fm_stdtab_sbm_nt, 1)
   sz(ivar1, :) = exp(ivar1)*2;
end
sz = flipud(sz);

for ivar2 = 1:size(fm_stdtab_sbm_nt, 2)
   clr(:, ivar2)=ivar2;
end

ax2=nexttile;
hold on
scatter(fm_stdtab_sbm_nt(:), fm_sppt_err_sbm_nt(:), sz(:), clr(:), 'filled')
scatter(fm_stdtab_sbm_nt(:), fm_sppt_err_sbm_nt(:), sz(:), color_order{1}, 'linewidth', 1.5)
scatter(fm_stdtab_tau_nt(:), fm_sppt_err_tau_nt(:), sz(:), clr(:), 'filled')
scatter(fm_stdtab_tau_nt(:), fm_sppt_err_tau_nt(:), sz(:), color_order{2}, 'linewidth', 1.5)
% xlim([0 40])
ylim([0 1])

% --- annotate scatter size --- 
curr_xlim = xlim;
curr_ylim = ylim;
annt_xpos2 = 0.845;
annt_x2 = repelem(curr_xlim(1)*(1-annt_xpos2) + curr_xlim(2)*annt_xpos2, size(fm_stdtab_sbm_nt, 1));
% annt_y2 = linspace(0.24, 0.49, size(fm_stdtab_sbm_nt, 1));
annt_y2 = logspace(log10((curr_ylim(2) - curr_ylim(1)) * 0.24) + curr_ylim(1), ...
                   log10((curr_ylim(2) - curr_ylim(1)) * 0.49) + curr_ylim(1), ...
                   size(fm_stdtab_sbm_nt, 1));
scatter(annt_x2, annt_y2, sz(end:-1:1, 1), [.3 .3 .3], 'linewidth', 1.5)

text(annt_x2(1)*0.985, (curr_ylim(2) - curr_ylim(1)) * 0.56 + curr_ylim(1), ...
                       '$N_a$ [$cm^{-3}$]', 'interpreter', 'latex')
text(annt_x2(1)*1.045, annt_y2(5), '100')
text(annt_x2(1)*1.045, annt_y2(4), '200')
text(annt_x2(1)*1.045, annt_y2(3), '400')
text(annt_x2(1)*1.045, annt_y2(2), '800')
text(annt_x2(1)*1.035, annt_y2(1), '1600')
% --- finish annotating ... except text ---

cb=colorbar;
colormap(ax2, cmaps.coolwarm5)
cb.Ticks=[1.4 2.2 3 3.8 4.6];
cb.TickLabels={'1', '2', '4', '8', '16'};
cb.Label.String='w [m/s]';
grid
ylabel('AMP/bin ratio (mean surface precipitation)')
l2 = legend('', 'sbm', '', 'tau', 'location', 'southeast');
set(gca, 'fontsize', 12)
title('(b) Full MP (D\fontsize{16}t\fontsize{24} = 80 \mum)', 'fontsize', 24)

% lower threshold figures

sz = ones(size(co_stdtab_sbm_nt, 1), size(co_stdtab_sbm_nt, 2));
clr = ones(size(co_stdtab_sbm_nt, 1), size(co_stdtab_sbm_nt, 2));
for ivar1 = 1:size(co_stdtab_sbm_nt, 1)
   sz(ivar1, :) = exp(ivar1)*2;
end
for ivar2 = 1:size(co_stdtab_sbm_nt, 2)
   clr(:, ivar2)=ivar2;
end

ax3=nexttile;
hold on
scatter(co_stdtab_sbm_lt(:), co_rwp_err_sbm_lt(:), sz(:), clr(:), 'filled')
scatter(co_stdtab_sbm_lt(:), co_rwp_err_sbm_lt(:), sz(:), color_order{1}, 'linewidth', 1.5)
scatter(co_stdtab_tau_lt(:), co_rwp_err_tau_lt(:), sz(:), clr(:), 'filled')
scatter(co_stdtab_tau_lt(:), co_rwp_err_tau_lt(:), sz(:), color_order{2}, 'linewidth', 1.5)
% xlim([0 40])
ylim([0 1])

% --- annotate scatter size --- 
curr_xlim = xlim;
curr_ylim = ylim;
annt_xpos1 = 0.845;
annt_x1 = repelem(curr_xlim(1)*(1-annt_xpos1) + curr_xlim(2)*annt_xpos1, size(co_stdtab_sbm_lt, 1));
% annt_y1 = linspace(0.24, 0.49, size(co_stdtab_sbm_lt, 1));
% annt_y1 = logspace(log10(0.24), log10(0.49), size(co_stdtab_sbm_lt, 1));
annt_y1 = logspace(log10((curr_ylim(2) - curr_ylim(1)) * 0.24) + curr_ylim(1), ...
                   log10((curr_ylim(2) - curr_ylim(1)) * 0.49) + curr_ylim(1), ...
                   size(co_stdtab_sbm_lt, 1));
scatter(annt_x1, annt_y1, sz(:, 1), [.3 .3 .3], 'linewidth', 1.5)

text(annt_x1(1)*0.985, (curr_ylim(2) - curr_ylim(1)) * 0.56 + curr_ylim(1), ...
                       '$\overline{D_m}$ [$\mu$m]', 'interpreter', 'latex')
text(annt_x1(1)*1.06, annt_y1(5), '27')
text(annt_x1(1)*1.06, annt_y1(4), '24')
text(annt_x1(1)*1.06, annt_y1(3), '21')
text(annt_x1(1)*1.06, annt_y1(2), '18')
text(annt_x1(1)*1.06, annt_y1(1), '15')
% --- finish annotating ... except box ---

cb=colorbar;
colormap(ax3, cmaps.BrBG5)
cb.Ticks=[1.4:0.8:4.6];
cb.TickLabels={'1', '3', '5', '7', '9'};
cb.Label.String='shape parameter';
grid
ylabel('AMP/bin ratio (rain water path)')
l3 = legend('', 'sbm', '', 'tau', 'location', 'southeast');
set(gca, 'fontsize', 12)
title('(c) Collision only (D\fontsize{16}t\fontsize{24} = 50 \mum)', 'fontsize', 24)


sz = ones(size(fm_stdtab_sbm_lt, 1), size(fm_stdtab_sbm_lt, 2));
clr = ones(size(fm_stdtab_sbm_lt, 1), size(fm_stdtab_sbm_lt, 2));
for ivar1 = 1:size(fm_stdtab_sbm_lt, 1)
   sz(ivar1, :) = exp(ivar1)*2;
end
sz = flipud(sz);

for ivar2 = 1:size(fm_stdtab_sbm_lt, 2)
   clr(:, ivar2)=ivar2;
end

ax4=nexttile;
hold on
scatter(fm_stdtab_sbm_lt(:), fm_sppt_err_sbm_lt(:), sz(:), clr(:), 'filled')
scatter(fm_stdtab_sbm_lt(:), fm_sppt_err_sbm_lt(:), sz(:), color_order{1}, 'linewidth', 1.5)
scatter(fm_stdtab_tau_lt(:), fm_sppt_err_tau_lt(:), sz(:), clr(:), 'filled')
scatter(fm_stdtab_tau_lt(:), fm_sppt_err_tau_lt(:), sz(:), color_order{2}, 'linewidth', 1.5)
% xlim([0 40])
ylim([0 1])

% --- annotate scatter size --- 
curr_xlim = xlim;
curr_ylim = ylim;
annt_xpos2 = 0.845;
annt_x2 = repelem(curr_xlim(1)*(1-annt_xpos2) + curr_xlim(2)*annt_xpos2, size(fm_stdtab_sbm_lt, 1));
% annt_y2 = linspace(0.24, 0.49, size(fm_stdtab_sbm_lt, 1));
annt_y2 = logspace(log10((curr_ylim(2) - curr_ylim(1)) * 0.24) + curr_ylim(1), ...
                   log10((curr_ylim(2) - curr_ylim(1)) * 0.49) + curr_ylim(1), ...
                   size(fm_stdtab_sbm_lt, 1));
scatter(annt_x2, annt_y2, sz(end:-1:1, 1), [.3 .3 .3], 'linewidth', 1.5)

text(annt_x2(1)*0.985, (curr_ylim(2) - curr_ylim(1)) * 0.56 + curr_ylim(1), ...
                       '$N_a$ [$cm^{-3}$]', 'interpreter', 'latex')
text(annt_x2(1)*1.045, annt_y2(5), '100')
text(annt_x2(1)*1.045, annt_y2(4), '200')
text(annt_x2(1)*1.045, annt_y2(3), '400')
text(annt_x2(1)*1.045, annt_y2(2), '800')
text(annt_x2(1)*1.035, annt_y2(1), '1600')
% --- finish annotating ... except text ---

cb=colorbar;
colormap(ax4, cmaps.coolwarm5)
cb.Ticks=[1.4 2.2 3 3.8 4.6];
cb.TickLabels={'1', '2', '4', '8', '16'};
cb.Label.String='w [m/s]';
grid
ylabel('AMP/bin ratio (mean surface precipitation)')
l4 = legend('', 'sbm', '', 'tau', 'location', 'southeast');
set(gca, 'fontsize', 12)
title('(d) Full MP (D\fontsize{16}t\fontsize{24} = 50 \mum)', 'fontsize', 24)

% --- annotate scatter size box ---
xa = l1.Position(1);
ya = l1.Position(2)+l1.Position(4)+0.01;
dx = l1.Position(3);
dy = 0.285/2;
annotation('rectangle', [xa, ya, dx, dy])

xa = l2.Position(1);
ya = l2.Position(2)+l2.Position(4)+0.01;
dx = l2.Position(3);
dy = 0.285/2;
annotation('rectangle', [xa, ya, dx, dy])

xa = l3.Position(1);
ya = l3.Position(2)+l3.Position(4)+0.01;
dx = l3.Position(3);
dy = 0.285/2;
annotation('rectangle', [xa, ya, dx, dy])

xa = l4.Position(1);
ya = l4.Position(2)+l4.Position(4)+0.01;
dx = l4.Position(3);
dy = 0.285/2;
annotation('rectangle', [xa, ya, dx, dy])
% --- finishing annotating ---

xlabel(tl, 'Standard deviation [\mum]', 'FontSize', 16)
exportgraphics(gcf, 'plots/p1/error_std_corr_gstd.png', 'resolution', 300)
