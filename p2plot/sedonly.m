clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str dt l_amp fn cloud_mr_th ...
   indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set ispath isproc isprof iscloud ...
   israin indvar_units_set indvar_units amp_only_var

nikki='2023-03-29';
vnum='0001';
global_var
mconfig_ls = get_mconfig_list(output_dir, nikki);
pltflag='mass';

if any(strcmp(pltflag, {'mass', 'number'}))
   cmap='Blues';
   linorlog='log';
elseif contains(pltflag, {'mass_diff','number_diff'})
   cmap='coolwarm';
   linorlog='lin';
end


ivar1 = 3;
ivar2 = 1;
confs = [2 3];
mconfig = mconfig_ls{confs(1)};
get_var_comp([10])
time_plot = [120 900];
disp(mconfig)
case_dep_var

figure('position',[0 0 900 600])
tl=tiledlayout(2,3);

its=1;
mconfig = mconfig_ls{confs(1)}; disp(mconfig)
bintau_struct = loadnc('bin');
amptau2m_struct = loadnc('amp');
its=2;
binsbm_struct = loadnc('bin');
ampsbm2m_struct = loadnc('amp');
mconfig = mconfig_ls{confs(2)}; disp(mconfig)
its=1;
amptau4m_struct = loadnc('amp');
its=2;
ampsbm4m_struct = loadnc('amp');

its=1;
%% plot
if its==2
   binmean = load('diamg_sbm.txt')*1e3;
elseif its==1
   binmean = load('diamg_tau.txt')*1e3;
end

time = amptau2m_struct.time;
z = amptau2m_struct.z;

bintau_DSDprof = bintau_struct.mass_dist(:, 1:length(binmean), :);
amptau2m_DSDprof = amptau2m_struct.mass_dist_init(:, 1:length(binmean), :);
amptau4m_DSDprof = amptau4m_struct.mass_dist_init(:, 1:length(binmean), :);
binsbm_DSDprof = binsbm_struct.mass_dist(:, 1:length(binmean), :);
ampsbm2m_DSDprof = ampsbm2m_struct.mass_dist_init(:, 1:length(binmean), :);
ampsbm4m_DSDprof = ampsbm4m_struct.mass_dist_init(:, 1:length(binmean), :);
dt = time(2) - time(1);

ti = 1;
tf = max(time);

itime = 900;
real_time = double(itime)*double(dt);
nexttile(4)
nanimagesc(binmean, z, squeeze(amptau2m_DSDprof(itime, :, :))')
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

nexttile(5)
nanimagesc(binmean, z, squeeze(bintau_DSDprof(itime, :, :))')
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

nexttile(6)
nanimagesc(binmean, z, squeeze(amptau4m_DSDprof(itime, :, :))')
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

nexttile(1)
nanimagesc(binmean, z, squeeze(amptau4m_DSDprof(1, :, :))')
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
title('(a) Initial DSD profile','fontweight','normal')

nexttile(2, [1 2])

var_comp_raw_amptau2m = amptau2m_struct.(indvar_name{1});
var_comp_amptau2m = var2phys(var_comp_raw_amptau2m,1,1);
var_comp_raw_amptau4m = amptau4m_struct.(indvar_name{1});
[var_comp_amptau4m, linORlog, range] = var2phys(var_comp_raw_amptau4m,1,1);
var_comp_raw_bintau = bintau_struct.(indvar_name{1});
var_comp_bintau = var2phys(var_comp_raw_bintau,1,1);

var_comp_raw_ampsbm2m = ampsbm2m_struct.(indvar_name{1});
var_comp_ampsbm2m = var2phys(var_comp_raw_ampsbm2m,1,1);
var_comp_raw_ampsbm4m = ampsbm4m_struct.(indvar_name{1});
[var_comp_ampsbm4m, linORlog, range] = var2phys(var_comp_raw_ampsbm4m,1,1);
var_comp_raw_binsbm = binsbm_struct.(indvar_name{1});
var_comp_binsbm = var2phys(var_comp_raw_binsbm,1,1);

hold on
plot(time, var_comp_amptau4m, '-o', 'linewidth', 1, 'color', color_order{1},...
   'MarkerIndices',itime,'MarkerFaceColor',color_order{1},'MarkerSize',5,'LineStyle','--')
plot(time, var_comp_bintau, '-o', 'linewidth', 0.5, 'color', color_order{1},...
   'MarkerIndices',itime,'MarkerFaceColor',color_order{1},'MarkerSize',5)
plot(time, var_comp_amptau2m, '-o', 'linewidth', 1.5, 'color', color_order{1}, ...
   'MarkerIndices',itime, 'MarkerFaceColor',color_order{1},'MarkerSize',3,'LineStyle',':')

plot(time, var_comp_ampsbm4m, '-o', 'linewidth', 1, 'color', color_order{2},...
   'MarkerIndices',itime,'MarkerFaceColor',color_order{2},'MarkerSize',5,'LineStyle','--')
plot(time, var_comp_binsbm, '-o', 'linewidth', 0.5, 'color', color_order{2},...
   'MarkerIndices',itime,'MarkerFaceColor',color_order{2},'MarkerSize',5)
plot(time, var_comp_ampsbm2m, '-o', 'linewidth', 1.5, 'color', color_order{2}, ...
   'MarkerIndices',itime, 'MarkerFaceColor',color_order{2},'MarkerSize',3,'LineStyle',':')

ylabel([indvar_ename{1} indvar_units{1}])
xlim([0 max(time)])
xlabel('Time [s]')
legend('U-AMP-TAU','BIN-TAU','S-AMP-TAU','U-AMP-SBM','BIN-SBM','S-AMP-SBM','Location','best')
title('(b) Precipitation rate comparison','fontweight','normal')
hold off
grid

title(tl, ['Handling of multiple rain modes (sed. only @ t = ',num2str(itime),'s)'],...
   'FontWeight','bold')
exportgraphics(gcf,['plots/p2/sedonly_rainlayer_t=' num2str(real_time) '.pdf'])
