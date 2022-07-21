clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units_set indvar_units

vnum='0001'; % last four characters of the model output file.
nikki='2022-06-27';

global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir, nikki);

mconfig = 'condnuc_dt0.1';
case_dep_var

its = 2;
ivar1 = 3;
ivar2 = 3;

[bin_struct, bin_maskc, bin_maskr, bin_maskl] = loadnc('bin');
[amp_struct, amp_maskc, amp_maskr, amp_maskl] = loadnc('amp');
time = amp_struct.time;
z = amp_struct.z;
dt = time(2) - time(1);

close all
% tplot = 84.8/dt;
tplot = 45.5/dt;
zplot = 15;

figure('position', [0 0 800 400])
tl = tiledlayout(1, 5);

nexttile([1 2])
bar([amp_struct.mass_dist_init(tplot+1,:,zplot); bin_struct.mass_dist(tplot,:,zplot)]', ...
   'FaceAlpha', .7, 'LineWidth', 1)

xlim([0 5])
xticks([1:4])
xlabel('Bin number')
ylabel('Mass conc. [kg/kg/dlogD]')
legend('AMP-SBM', 'bin-SBM')
title('   (a) PSD')
set(gca, 'FontSize', 18)

nexttile([1 3])
nanimagesc(time(1:9000), z, amp_struct.oflagc(1:9000,:)')
xlabel('Time [s]')
ylabel('Altitude [m]')
set(gca, 'YDir', 'normal')
cbar = colorbar;
cbar.Ticks = [-2/3 0 2/3];
cbar.TickLabels = {'No cloud', 'Success', 'Failure'}; 
colormap(flag3)
set(gca, 'FontSize', 18)
annotation('ellipse', [.470 .220 .025 .050], 'LineWidth', 2, ...
   'color', [.6 .6 .6])
annotation('line', [.4910 .356], [.264 .907], 'LineWidth', 2, ...
   'LineStyle', '--', 'color', [.6 .6 .6])
annotation('line', [.4825 .356], [.220 .152], 'LineWidth', 2, ...
   'LineStyle', '--', 'color', [.6 .6 .6])
title('(b) Number conc. conservation flags')
exportgraphics(gcf,['plots/p1/condonly_dist.png'],'Resolution',300)
% print(gcf,'plots/p1/condonly_dist.png','-dpng','-r300')
