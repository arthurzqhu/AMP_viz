clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name ...
   indvar_units indvar_ename indvar_ename_set indvar_units_set

nikki = '2023-03-18';
global_var

mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);
aux_line_color = [.5 .5 .5];
SBMorTAU = 1;

USconfs = [1 2];

figure('position',[0 0 900 600])
tl = tiledlayout(2,6);

mconfig = mconfig_ls{1};
get_var_comp([4 10])
case_dep_var
load(['pfm_summary/',nikki,'_', mconfig, '_pfm.mat'])
its = SBMorTAU;

ivar1 = 2; ivar2 = 3;
bin_struct = loadnc('bin');
amp2m_struct = loadnc('amp');
mconfig = mconfig_ls{2};
amp4m_struct = loadnc('amp');

if its==2
   binmean = load('diamg_sbm.txt')*1e3;
elseif its==1
   binmean = load('diamg_tau.txt')*1e3;
end

time = amp2m_struct.time;
z = amp2m_struct.z;

bin_DSDprof = bin_struct.mass_dist(:, 1:length(binmean), :);
amp2m_DSDprof = amp2m_struct.mass_dist_init(:, 1:length(binmean), :);
amp4m_DSDprof = amp4m_struct.mass_dist_init(:, 1:length(binmean), :);
dt = time(2) - time(1);

ti = 1;
tf = max(time);

real_time = 800;
itime = double(real_time)/double(dt);

nexttile(7,[1,2])
nanimagesc(binmean, z, squeeze(amp2m_DSDprof(itime, :, :))')
set(gca,'XScale','log')
set(gca,'YDir','normal')
xlim([min(binmean) max(binmean)])
xticks([1e-2 1e-1 1])
colormap(cmaps.Blues)
cbar = colorbar;
grid
cbar.Label.String = 'DSD [kg/kg/log(D)]';
caxis([1e-8 1e-2])
set(gca,'colorscale','log')
xlabel('Diameter [mm]')
ylabel('Altitude [m]')
title(['(c) S-AMP-' upper(bintype{its})],'fontweight','normal')
% set(gca,'fontsize',16)

nexttile(9,[1,2])
nanimagesc(binmean, z, squeeze(bin_DSDprof(itime, :, :))')
set(gca,'XScale','log')
set(gca,'YDir','normal')
xlim([min(binmean) max(binmean)])
xticks([1e-2 1e-1 1])
colormap(cmaps.Blues)
cbar = colorbar;
grid
cbar.Label.String = 'DSD [kg/kg/log(D)]';
caxis([1e-8 1e-2])
set(gca,'colorscale','log')
xlabel('Diameter [mm]')
ylabel('Altitude [m]')
title(['(d) BIN-' upper(bintype{its})],'fontweight','normal')
% set(gca,'fontsize',16)


nexttile(11,[1,2])
nanimagesc(binmean, z, squeeze(amp4m_DSDprof(itime, :, :))')
set(gca,'XScale','log')
set(gca,'YDir','normal')
xlim([min(binmean) max(binmean)])
xticks([1e-2 1e-1 1])
colormap(cmaps.Blues)
cbar = colorbar;
grid
cbar.Label.String = 'DSD [kg/kg/log(D)]';
caxis([1e-8 1e-2])
set(gca,'colorscale','log')
xlabel('Diameter [mm]')
ylabel('Altitude [m]')
title(['(e) U-AMP-' upper(bintype{its})],'fontweight','normal')
% set(gca,'fontsize',16)

nexttile(1,[1,3])
ivar=1; its=1;
var_comp_raw_amp2m = amp2m_struct.(indvar_name{ivar});
var_comp_amp2m = var2phys(var_comp_raw_amp2m,1,1);
var_comp_raw_amp4m = amp4m_struct.(indvar_name{ivar});
var_comp_amp4m = var2phys(var_comp_raw_amp4m,1,1);
var_comp_raw_bin = bin_struct.(indvar_name{ivar});
var_comp_bin = var2phys(var_comp_raw_bin,1,1);
hold on
plot(time, var_comp_amp2m,'LineStyle',':','LineWidth',1.5,'color',color_order{its})
plot(time, var_comp_amp4m,'LineStyle','--','LineWidth',1,'color',color_order{its})
plot(time, var_comp_bin,'LineStyle','-','LineWidth',0.5,'color',color_order{its})

its=2;
mconfig = mconfig_ls{1};
bin_struct = loadnc('bin');
amp2m_struct = loadnc('amp');
mconfig = mconfig_ls{2};
amp4m_struct = loadnc('amp');
var_comp_raw_amp2m = amp2m_struct.(indvar_name{ivar});
var_comp_amp2m = var2phys(var_comp_raw_amp2m,1,1);
var_comp_raw_amp4m = amp4m_struct.(indvar_name{ivar});
var_comp_amp4m = var2phys(var_comp_raw_amp4m,1,1);
var_comp_raw_bin = bin_struct.(indvar_name{ivar});
var_comp_bin = var2phys(var_comp_raw_bin,1,1);
plot(time, var_comp_amp2m,'LineStyle',':','LineWidth',1.5,'color',color_order{its})
plot(time, var_comp_amp4m,'LineStyle','--','LineWidth',1,'color',color_order{its})
plot(time, var_comp_bin,'LineStyle','-','LineWidth',0.5,'color',color_order{its})
xlabel('Time [s]')
ylabel([indvar_ename{1} indvar_units{1}])
% set(gca,'fontsize',16)
hold off
grid
title('(a)','fontweight','normal')

nexttile(4,[1,3])
ivar=2; its=1;
mconfig = mconfig_ls{1};
bin_struct = loadnc('bin');
amp2m_struct = loadnc('amp');
mconfig = mconfig_ls{2};
amp4m_struct = loadnc('amp');
var_comp_raw_amp2m = amp2m_struct.(indvar_name{ivar});
var_comp_amp2m = var2phys(var_comp_raw_amp2m,1,1);
var_comp_raw_amp4m = amp4m_struct.(indvar_name{ivar});
var_comp_amp4m = var2phys(var_comp_raw_amp4m,1,1);
var_comp_raw_bin = bin_struct.(indvar_name{ivar});
var_comp_bin = var2phys(var_comp_raw_bin,1,1);
hold on
plot(time, var_comp_bin,'LineStyle','-','LineWidth',0.5,'color',color_order{its},...
   'DisplayName','BIN-TAU')
plot(time, var_comp_amp4m,'LineStyle','--','LineWidth',1,'color',color_order{its},...
   'DisplayName','U-AMP-TAU')
plot(time, var_comp_amp2m,'LineStyle',':','LineWidth',1.5,'color',color_order{its},...
   'DisplayName','S-AMP-TAU')

its=2;
mconfig = mconfig_ls{1};
bin_struct = loadnc('bin');
amp2m_struct = loadnc('amp');
mconfig = mconfig_ls{2};
amp4m_struct = loadnc('amp');
var_comp_raw_amp2m = amp2m_struct.(indvar_name{ivar});
var_comp_amp2m = var2phys(var_comp_raw_amp2m,1,1);
var_comp_raw_amp4m = amp4m_struct.(indvar_name{ivar});
var_comp_amp4m = var2phys(var_comp_raw_amp4m,1,1);
var_comp_raw_bin = bin_struct.(indvar_name{ivar});
var_comp_bin = var2phys(var_comp_raw_bin,1,1);
plot(time, var_comp_bin,'LineStyle','-','LineWidth',0.5,'color',color_order{its},...
   'DisplayName','BIN-SBM')
plot(time, var_comp_amp4m,'LineStyle','--','LineWidth',1,'color',color_order{its},...
   'DisplayName','U-AMP-SBM')
plot(time, var_comp_amp2m,'LineStyle',':','LineWidth',1.5,'color',color_order{its},...
   'DisplayName','S-AMP-SBM')

legend('show','location','best')
xlabel('Time [s]')
ylabel([indvar_ename{ivar} indvar_units{ivar}])
% set(gca,'fontsize',16)
hold off
grid
title('(b)','fontweight','normal')

title(tl,sprintf('Snapshot of Na200w4 @ t = %d s', real_time),'fontweight','bold')

exportgraphics(gcf,'plots/p2/a200w4DSD.pdf')
