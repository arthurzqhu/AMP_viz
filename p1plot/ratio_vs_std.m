clear
clear global
close all

global ivar1 ivar2 its nikki mconfig output_dir vnum ...
   bintype var1_str var2_str


collonly_pfm = load('pfm_summary/smaller_threshold_collonly_pfm.mat');
fullmp_pfm = load('pfm_summary/smaller_threshold_fullmic_pfm.mat');

fm_sppt_err_sbm = fullmp_pfm.pfm.mean_surface_ppt.sbm.mr;
% fm_stdtab_sbm = fullmp_pfm.pfm.stdtab_bin.sbm;
fm_sppt_err_tau = fullmp_pfm.pfm.mean_surface_ppt.tau.mr;
% fm_stdtab_tau = fullmp_pfm.pfm.stdtab_bin.tau;

co_rwp_err_sbm = collonly_pfm.pfm.rain_M1_path.sbm.mr;
% co_stdtab_sbm = collonly_pfm.pfm.stdtab_bin.sbm;
co_rwp_err_tau = collonly_pfm.pfm.rain_M1_path.tau.mr;
% co_stdtab_tau = collonly_pfm.pfm.stdtab_bin.tau;

nikki = 'normal_threshold';
global_var
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
         [~, ~, ~, ~, bin_struct] = loadnc('bin');
         time = bin_struct.time;
         z = bin_struct.z;
         lwcprof_tstd = bin_struct.diagM3_liq(1, :);
         collonly_pfm.pfm.stdtab_bin.(bintype{its})(ivar1, ivar2) = ...
            wmean(arrayfun(@(x) nanstd(binmean, ...
            bin_struct.mass_dist(1, 1:nkr, x))*1e6, 1:120), lwcprof_tstd);
         % collonly_pfm.pfm.stdtab_bin.(bintype{its})(ivar1, ivar2) = ...
         %    nanstd(binmean, bin_struct.mass_dist(1, 1:nkr, 18))*1e6;
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
         [~, ~, ~, ~, bin_struct] = loadnc('bin');
         bin_struct.mass_dist(bin_struct.mass_dist < 0) = 0;
         time = bin_struct.time;
         z = bin_struct.z;
         % tstd = find(nansum(bin_struct.dm_liq_ce,2)*.1<nansum(bin_struct.dm_rain_coll, ...
         %    2), 1, 'first');
         tstd = time(end) / 4;
         lwcprof_tstd = bin_struct.diagM3_liq(tstd, :);
         fullmic_pfm.pfm.stdtab_bin.(bintype{its})(ivar1, ivar2) = ...
            wmean(arrayfun(@(x) nanstd(binmean, ...
            bin_struct.mass_dist(tstd, 1:nkr, x))*1e6, 1:120), lwcprof_tstd);
      end
   end
end

co_stdtab_tau = collonly_pfm.pfm.stdtab_bin.tau;
co_stdtab_sbm = collonly_pfm.pfm.stdtab_bin.sbm;
fm_stdtab_tau = fullmic_pfm.pfm.stdtab_bin.tau;
fm_stdtab_sbm = fullmic_pfm.pfm.stdtab_bin.sbm;

sz = ones(size(co_stdtab_sbm, 1), size(co_stdtab_sbm, 2));
clr = ones(size(co_stdtab_sbm, 1), size(co_stdtab_sbm, 2));
for ivar1 = 1:size(co_stdtab_sbm, 1)
   sz(ivar1, :) = exp(ivar1)*2;
end

for ivar2 = 1:size(co_stdtab_sbm, 2)
   clr(:, ivar2)=ivar2;
end

figure('position', [0 0 1000 350])
tl = tiledlayout('flow');

ax1=nexttile;
hold on
scatter(co_stdtab_sbm(:), co_rwp_err_sbm(:), sz(:), clr(:), 'filled')
scatter(co_stdtab_sbm(:), co_rwp_err_sbm(:), sz(:), color_order{1}, 'linewidth', 1.5)
scatter(co_stdtab_tau(:), co_rwp_err_tau(:), sz(:), clr(:), 'filled')
scatter(co_stdtab_tau(:), co_rwp_err_tau(:), sz(:), color_order{2}, 'linewidth', 1.5)
xlim([0 40])
ylim([0 1.2])

% --- annotate scatter size --- 
curr_xlim = xlim;
curr_ylim = ylim;
annt_xpos1 = 0.845;
annt_x1 = repelem(curr_xlim(1)*(1-annt_xpos1) + curr_xlim(2)*annt_xpos1, size(co_stdtab_sbm, 1));
% annt_y1 = linspace(0.2, 0.45, size(co_stdtab_sbm, 1));
% annt_y1 = logspace(log10(0.2), log10(0.45), size(co_stdtab_sbm, 1));
annt_y1 = logspace(log10((curr_ylim(2) - curr_ylim(1)) * 0.2) + curr_ylim(1), ...
                   log10((curr_ylim(2) - curr_ylim(1)) * 0.45) + curr_ylim(1), ...
                   size(co_stdtab_sbm, 1));
scatter(annt_x1, annt_y1, sz(:, 1), [.3 .3 .3], 'linewidth', 1.5)

text(annt_x1(1)*0.985, (curr_ylim(2) - curr_ylim(1)) * 0.52 + curr_ylim(1), ...
                       '$\overline{D_m}$ [$\mu$m]', 'interpreter', 'latex')
text(annt_x1(1)*1.05, annt_y1(5), '27')
text(annt_x1(1)*1.05, annt_y1(4), '24')
text(annt_x1(1)*1.05, annt_y1(3), '21')
text(annt_x1(1)*1.05, annt_y1(2), '18')
text(annt_x1(1)*1.05, annt_y1(1), '15')
% --- finish annotating ... except box ---

cb=colorbar;
colormap(ax1, BrBG5)
cb.Ticks=[1.4:0.8:4.6];
cb.TickLabels={'1', '3', '5', '7', '9'};
cb.Label.String='shape parameter';
grid
ylabel('AMP/bin ratio (rain water path)')
l1 = legend('', 'sbm', '', 'tau', 'location', 'southeast');
set(gca, 'fontsize', 12)
title('(a) Collision only', 'fontsize', 24)


sz = ones(size(fm_stdtab_sbm, 1), size(fm_stdtab_sbm, 2));
clr = ones(size(fm_stdtab_sbm, 1), size(fm_stdtab_sbm, 2));
for ivar1 = 1:size(fm_stdtab_sbm, 1)
   sz(ivar1, :) = exp(ivar1)*2;
end
sz = flipud(sz);

for ivar2 = 1:size(fm_stdtab_sbm, 2)
   clr(:, ivar2)=ivar2;
end

ax2=nexttile;
hold on
scatter(fm_stdtab_sbm(:), fm_sppt_err_sbm(:), sz(:), clr(:), 'filled')
scatter(fm_stdtab_sbm(:), fm_sppt_err_sbm(:), sz(:), color_order{1}, 'linewidth', 1.5)
scatter(fm_stdtab_tau(:), fm_sppt_err_tau(:), sz(:), clr(:), 'filled')
scatter(fm_stdtab_tau(:), fm_sppt_err_tau(:), sz(:), color_order{2}, 'linewidth', 1.5)
xlim([0 40])
ylim([0 1.2])

% --- annotate scatter size --- 
curr_xlim = xlim;
curr_ylim = ylim;
annt_xpos2 = 0.845;
annt_x2 = repelem(curr_xlim(1)*(1-annt_xpos2) + curr_xlim(2)*annt_xpos2, size(fm_stdtab_sbm, 1));
% annt_y2 = linspace(0.2, 0.45, size(fm_stdtab_sbm, 1));
annt_y2 = logspace(log10((curr_ylim(2) - curr_ylim(1)) * 0.2) + curr_ylim(1), ...
                   log10((curr_ylim(2) - curr_ylim(1)) * 0.45) + curr_ylim(1), ...
                   size(fm_stdtab_sbm, 1));
scatter(annt_x2, annt_y2, sz(end:-1:1, 1), [.3 .3 .3], 'linewidth', 1.5)

text(annt_x2(1)*0.985, (curr_ylim(2) - curr_ylim(1)) * 0.52 + curr_ylim(1), ...
                       '$N_a$ [$cm^{-3}$]', 'interpreter', 'latex')
text(annt_x2(1)*1.045, annt_y2(5), '100')
text(annt_x2(1)*1.045, annt_y2(4), '200')
text(annt_x2(1)*1.045, annt_y2(3), '400')
text(annt_x2(1)*1.045, annt_y2(2), '800')
text(annt_x2(1)*1.035, annt_y2(1), '1600')
% --- finish annotating ... except text ---

cb=colorbar;
colormap(ax2, coolwarm5)
cb.Ticks=[1.4 2.2 3 3.8 4.6];
cb.TickLabels={'1', '2', '4', '8', '16'};
cb.Label.String='w [m/s]';
grid
ylabel('AMP/bin ratio (mean surface precipitation)')
l2 = legend('', 'sbm', '', 'tau', 'location', 'southeast');
set(gca, 'fontsize', 12)
title('(b) Full microphysics', 'fontsize', 24)

% --- annotate scatter size box ---
xa = l1.Position(1);
ya = l1.Position(2)+l1.Position(4)+0.04;
dx = l1.Position(3);
dy = 0.285;
annotation('rectangle', [xa, ya, dx, dy])


xa = l2.Position(1);
ya = l2.Position(2)+l2.Position(4)+0.04;
dx = l2.Position(3);
dy = 0.285;
annotation('rectangle', [xa, ya, dx, dy])
% --- finishing annotating ---

xlabel(tl, 'Standard deviation [\mum]', 'FontSize', 16)
exportgraphics(gcf, 'plots/p1/error_std_corr_halfup_smallthres.jpg', 'resolution', 300)
