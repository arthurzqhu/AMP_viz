clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units_set indvar_units

vnum='0001'; % last four characters of the model output file.
nikki='orig_thres';

global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir, nikki);

mconfig = 'collonly';
case_dep_var

ivar1 = 3;
ivar2 = 5;


for its = 1:2
   figure('position', [0 0 800 400])
   tl = tiledlayout('flow');

   amp_struct = loadnc('amp');
   time = amp_struct.time;
   z = amp_struct.z;
   dt = time(2) - time(1);

   nexttile
   nanimagesc(time, z, amp_struct.oflagc')
   xlabel('Time [s]')
   ylabel('Altitude [m]')
   set(gca, 'YDir', 'normal')
   cbar = colorbar;
   % cbar.Ticks = [-2/3 0 2/3];
   % cbar.Limits = [-1 1];
   % cbar.TickLabels = {'No cloud', 'Success', 'Failure'}; 
   colormap(flag3)
   set(gca, 'FontSize', 18)

   nexttile
   nanimagesc(time, z, amp_struct.oflagr')
   xlabel('Time [s]')
   ylabel('Altitude [m]')
   set(gca, 'YDir', 'normal')
   cbar = colorbar;
   % cbar.Ticks = [-2/3 0 2/3];
   % cbar.Limits = [-1 1];
   % cbar.TickLabels = {'No rain', 'Success', 'Failure'}; 
   colormap(flag3)
   set(gca, 'FontSize', 18)

   exportgraphics(gcf,['plots/collonly_flag_', bintype{its}, '_', nikki, '.png'],'Resolution',300)
end

