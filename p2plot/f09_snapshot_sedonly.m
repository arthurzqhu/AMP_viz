clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str dt l_amp fn cloud_mr_th ...
   indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set ispath isproc isprof iscloud ...
   israin indvar_units_set indvar_units amp_only_var

nikki='sedonly';
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

mconfig = mconfig_ls{1};
get_var_comp([10])

figure('position',[0 0 1000 600])
tl=tiledlayout(2,3);


for its = 1:2
   bin_struct{its} = loadnc('bin');
   mconfig = mconfig_ls{1};
   amp2m_struct{its} = loadnc('amp');
   mconfig = mconfig_ls{2};
   amp4m_struct{its} = loadnc('amp');
end

time = amp2m_struct{its}.time;
z = amp2m_struct{its}.z;

for TAUorSBM = 1:2

its = TAUorSBM;

%% plot
if its==2
   binmean = load('diamg_sbm.txt')*1e3;
   krdrop=14;
elseif its==1
   binmean = load('diamg_tau.txt')*1e3;
   krdrop=15;
end

bin_PSDprof{its} = bin_struct{its}.mass_dist(:, 1:length(binmean), :);
amp2m_PSDprof{its} = amp2m_struct{its}.mass_dist_init(:, 1:length(binmean), :);
amp4m_PSDprof{its} = amp4m_struct{its}.mass_dist_init(:, 1:length(binmean), :);
dt = time(2) - time(1);

ti = 1;
tf = max(time);

itime = 900;
real_time = double(itime)/double(dt);
nexttile(4)
nanimagesc(binmean, z, squeeze(amp2m_PSDprof{its}(itime, :, :))')
xline(sqrt(binmean(krdrop)*binmean(krdrop+1)))
set(gca,'XScale','log')
set(gca,'YDir','normal')
xlim([min(binmean) max(binmean)])
xticks([1e-2 1e-1 1])
colormap(cmaps.Blues)
cbar = colorbar;
grid
cbar.Label.String = 'PSD [kg/kg/log(D)]';
caxis([1e-8 1e-2])
set(gca,'colorscale','log')
xlabel('Diameter [mm]')
ylabel('Altitude [m]')
title(['(c) S-AMP-' upper(bintype{its})],'fontweight','normal')
set(gca,'fontsize',16)

nexttile(5)
nanimagesc(binmean, z, squeeze(bin_PSDprof{its}(itime, :, :))')
xline(sqrt(binmean(krdrop)*binmean(krdrop+1)))
set(gca,'XScale','log')
set(gca,'YDir','normal')
xlim([min(binmean) max(binmean)])
xticks([1e-2 1e-1 1])
colormap(cmaps.Blues)
cbar = colorbar;
grid
cbar.Label.String = 'PSD [kg/kg/log(D)]';
caxis([1e-8 1e-2])
set(gca,'colorscale','log')
xlabel('Diameter [mm]')
ylabel('Altitude [m]')
title(['(d) BIN-' upper(bintype{its})],'fontweight','normal')
set(gca,'fontsize',16)

nexttile(6)
nanimagesc(binmean, z, squeeze(amp4m_PSDprof{its}(itime, :, :))')
xline(sqrt(binmean(krdrop)*binmean(krdrop+1)))
set(gca,'XScale','log')
set(gca,'YDir','normal')
xlim([min(binmean) max(binmean)])
xticks([1e-2 1e-1 1])
colormap(cmaps.Blues)
cbar = colorbar;
grid
cbar.Label.String = 'PSD [kg/kg/log(D)]';
caxis([1e-8 1e-2])
set(gca,'colorscale','log')
xlabel('Diameter [mm]')
ylabel('Altitude [m]')
title(['(e) U-AMP-' upper(bintype{its})],'fontweight','normal')
set(gca,'fontsize',16)

nexttile(1)
nanimagesc(binmean, z, squeeze(amp4m_PSDprof{its}(1, :, :))')
xline(sqrt(binmean(krdrop)*binmean(krdrop+1)))
set(gca,'XScale','log')
set(gca,'YDir','normal')
xlim([min(binmean) max(binmean)])
xticks([1e-2 1e-1 1])
colormap(cmaps.Blues)
cbar = colorbar;
grid
cbar.Label.String = 'PSD [kg/kg/log(D)]';
caxis([1e-8 1e-2])
set(gca,'colorscale','log')
xlabel('Diameter [mm]')
ylabel('Altitude [m]')
title('(a) Initial PSD profile','fontweight','normal')
set(gca,'fontsize',16)

nexttile(2, [1 2])
for its = TAUorSBM
   var_comp_raw_amp2m = amp2m_struct{its}.(indvar_name{1});
   var_comp_amp2m = var2phys(var_comp_raw_amp2m,1,1);
   var_comp_raw_amp4m = amp4m_struct{its}.(indvar_name{1});
   [var_comp_amp4m, linORlog, range] = var2phys(var_comp_raw_amp4m,1,1);
   var_comp_raw_bin = bin_struct{its}.(indvar_name{1});
   var_comp_bin = var2phys(var_comp_raw_bin,1,1);

   plot(time, var_comp_amp4m, '-o', 'linewidth', 1, 'color', color_order{its},...
      'MarkerIndices',itime,'MarkerFaceColor',color_order{its},'MarkerSize',5,'LineStyle','--',...
      'DisplayName',['U-AMP-' upper(bintype{its})])
   hold on
   plot(time, var_comp_bin, '-o', 'linewidth', 0.5, 'color', color_order{its},...
      'MarkerIndices',itime,'MarkerFaceColor',color_order{its},'MarkerSize',5,...
      'DisplayName',['BIN-' upper(bintype{its})])
   plot(time, var_comp_amp2m, '-o', 'linewidth', 1.5, 'color', color_order{its}, ...
      'MarkerIndices',itime, 'MarkerFaceColor',color_order{its},'MarkerSize',3,'LineStyle',':',...
      'DisplayName',['S-AMP-' upper(bintype{its})])
end

ylabel([indvar_ename{1} indvar_units{1}])
xlim([0 max(time)])
xlabel('Time [s]')
legend('show','Location','best')
title('(b) Precipitation rate comparison','fontweight','normal')
hold off
grid on
set(gca,'fontsize',16)

title(tl, ['Handling of multiple rain modes (sed. only @ t = ',num2str(itime),'s)'],...
   'FontWeight','bold','fontsize',24)
exportgraphics(gcf,['plots/p2/f09_snapshot_sedonly ', bintype{TAUorSBM},'.pdf'])
saveas(gcf,['plots/p2/f09_snapshot_sedonly ', bintype{TAUorSBM},'.fig'])

end
