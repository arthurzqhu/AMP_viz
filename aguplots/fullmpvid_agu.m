clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str dt l_amp fn cloud_mr_th ...
   indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set ispath isproc isprof iscloud ...
   israin indvar_units_set indvar_units amp_only_var

nikki='UAMPvsSAMP_thr0';
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


confs = [11 12];
% confs = [1 3];
mconfig = mconfig_ls{confs(1)};
get_var_comp([10])
disp(mconfig)
case_dep_var

for its = 1:2
   for ivar1 = [3 2]
      ivar2 = 5-ivar1;
      mconfig = mconfig_ls{confs(1)}; disp(mconfig)
      bin_struct = loadnc('bin');
      amp2m_struct = loadnc('amp');
      mconfig = mconfig_ls{confs(2)}; disp(mconfig)
      amp4m_struct = loadnc('amp');

      %% plot
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
      ts_plot = 20;

      figure('position',[0 0 900 600])
      tl=tiledlayout(2,3);


      iframe = 1;
      iti = int32(ti/dt);
      itf = int32(tf/dt);
      istep = int32(ts_plot/dt);

      for itime = iti:istep:itf
         real_time = double(itime)*double(dt);
         nexttile(1)
         nanimagesc(binmean, z, squeeze(amp2m_DSDprof(itime, :, :))')
         set(gca,'XScale','log')
         set(gca,'YDir','normal')
         xlim([min(binmean) max(binmean)])
         xticks([1e-2 1e-1 1])
         colormap(cmaps.Blues)
         cbar = colorbar;
         grid
         cbar.Label.String = 'DSD [kg/kg/ln(r)]';
         caxis([1e-8 1e-2])
         set(gca,'colorscale','log')
         xlabel('Diameter [mm]')
         ylabel('Altitude [m]')
         title(['S-AMP-' upper(bintype{its})],'fontweight','normal')

         nexttile(2)
         nanimagesc(binmean, z, squeeze(bin_DSDprof(itime, :, :))')
         set(gca,'XScale','log')
         set(gca,'YDir','normal')
         xlim([min(binmean) max(binmean)])
         xticks([1e-2 1e-1 1])
         colormap(cmaps.Blues)
         cbar = colorbar;
         grid
         cbar.Label.String = 'DSD [kg/kg/ln(r)]';
         caxis([1e-8 1e-2])
         set(gca,'colorscale','log')
         xlabel('Diameter [mm]')
         ylabel('Altitude [m]')
         title(['BIN-' upper(bintype{its})],'fontweight','normal')


         nexttile(3)
         nanimagesc(binmean, z, squeeze(amp4m_DSDprof(itime, :, :))')
         set(gca,'XScale','log')
         set(gca,'YDir','normal')
         xlim([min(binmean) max(binmean)])
         xticks([1e-2 1e-1 1])
         colormap(cmaps.Blues)
         cbar = colorbar;
         grid
         cbar.Label.String = 'DSD [kg/kg/ln(r)]';
         caxis([1e-8 1e-2])
         set(gca,'colorscale','log')
         xlabel('Diameter [mm]')
         ylabel('Altitude [m]')
         title(['U-AMP-' upper(bintype{its})],'fontweight','normal')

         nexttile(4,[1 3])
         var_comp_raw_amp2m = amp2m_struct.(indvar_name{1});
         var_comp_amp2m = var2phys(var_comp_raw_amp2m,1,1);
         var_comp_raw_amp4m = amp4m_struct.(indvar_name{1});
         [var_comp_amp4m, linORlog, range] = var2phys(var_comp_raw_amp4m,1,1);
         var_comp_raw_bin = bin_struct.(indvar_name{1});
         var_comp_bin = var2phys(var_comp_raw_bin,1,1);
         plot(time, var_comp_amp4m, '-o', 'linewidth', 2, 'color', color_order{1},...
            'MarkerIndices',itime,'MarkerFaceColor',color_order{1},'MarkerSize',5)
         hold on
         plot(time, var_comp_bin, '-o', 'linewidth', 2, 'color', color_order{2},...
            'MarkerIndices',itime,'MarkerFaceColor',color_order{2},'MarkerSize',5)
         plot(time, var_comp_amp2m, '-o', 'linewidth', 1, 'color', color_order{4}, ...
            'MarkerIndices',itime, 'MarkerFaceColor',color_order{4},'MarkerSize',3)
         ylabel([indvar_ename{1} indvar_units{1}])
         xlim([0 max(time)])
         xlabel('Time [s]')
         legend('U-AMP','BIN','S-AMP','Location','best')
         title('Precipitation rate comparison')
         hold off
         grid on

         title(tl, ['Full microphysics (sed. only @ t = ',num2str(itime),'s)'],...
            'FontWeight','bold')

         cdata = print('-RGBImage','-r144');
         F(iframe) = im2frame(cdata);
         disp(['time=' num2str(real_time)])

         iframe = iframe + 1;

         delete(findall(gcf,'type','annotation'))
      end

      fn = [mconfig, ' ', bintype{its}, ' ', vnum, ' '];

      saveVid(F,[fn, 'DSD ', ...
         var1_str{ivar1} ' ' var2_str{ivar2}, ' ', ...
         num2str(ti) '-', num2str(tf)], 10)

   end
end
