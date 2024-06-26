clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name ...
   indvar_units indvar_ename indvar_ename_set indvar_units_set ...
   script_name

script_name = mfilename;

nikki = 'fullmic';
global_var

mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);

USconfs = [1 2];

mconfig = mconfig_ls{1};
get_var_comp([4 10 83])
case_dep_var
load([summ_dir,nikki,'_', mconfig, '_pfm.mat'])

ivar1 = 2; ivar2 = 2;

its = 1;
bin_struct{its} = loadnc('bin');
mconfig = mconfig_ls{1};
amp2m_struct{its} = loadnc('amp');
mconfig = mconfig_ls{2};
amp4m_struct{its} = loadnc('amp');

for TAUorSBM = 1
   figure('position',[0 0 1000 600])
   tl = tiledlayout(2,3,'TileSpacing','compact','padding','compact');

   its = TAUorSBM;
   if its==2
      binmean = load('diamg_sbm.txt')*1e3;
      krdrop=14;
   elseif its==1
      binmean = load('diamg_tau.txt')*1e3;
      krdrop=15;
   end

   time = amp2m_struct{its}.time;
   z = amp2m_struct{its}.z;

   bin_PSDprof = bin_struct{its}.mass_dist(:, 1:length(binmean), :);
   amp2m_PSDprof = amp2m_struct{its}.mass_dist_init(:, 1:length(binmean), :);
   amp4m_PSDprof = amp4m_struct{its}.mass_dist_init(:, 1:length(binmean), :);
   dt = time(2) - time(1);

   ti = 1;
   tf = max(time);

   real_time = 800;
   itime = double(real_time)/double(dt);

   for ivar = 1:3
      nexttile
      % ivar=1;
      var_comp_raw_amp2m = amp2m_struct{its}.(indvar_name{ivar});
      var_comp_amp2m = var2phys(var_comp_raw_amp2m,1,1);
      var_comp_raw_amp4m = amp4m_struct{its}.(indvar_name{ivar});
      var_comp_amp4m = var2phys(var_comp_raw_amp4m,1,1);
      var_comp_raw_bin = bin_struct{its}.(indvar_name{ivar});
      var_comp_bin = var2phys(var_comp_raw_bin,1,1);

      if ivar <= 2
         plot(time, var_comp_amp2m,'-o','linewidth',1.5,'color',color_order{ivar},...
            'markerindices',itime,'markerfacecolor',color_order{ivar},'markersize',5,'linestyle',':')
         hold on
         plot(time, var_comp_amp4m,'-o','linewidth',1,'color',color_order{ivar},...
            'markerindices',itime,'markerfacecolor',color_order{ivar},'markersize',5,'linestyle','--')
         plot(time, var_comp_bin,'-o','linewidth',0.5,'color',color_order{ivar},...
            'markerindices',itime,'markerfacecolor',color_order{ivar},'markersize',5,'linestyle','-')
         hold off

         xlabel('Time [s]')
         ylabel([indvar_ename{ivar} indvar_units{ivar}])
         set(gca,'fontsize',16)
         hold off
         grid on
         title(['(', Alphabet(ivar),')'],'fontweight','normal')
      else
         plot(var_comp_amp2m(itime,:), z, 'linewidth',1.5,'color',color_order{ivar+1},'linestyle',':',...
            'DisplayName',['S-AMP-' upper(bintype{its})])
         hold on
         plot(var_comp_amp4m(itime,:), z, 'linewidth',1,'color',color_order{ivar+1},'linestyle','--',...
            'DisplayName',['U-AMP-' upper(bintype{its})])
         plot(var_comp_bin(itime,:), z, 'linewidth',.5,'color',color_order{ivar+1},'linestyle','-',...
            'DisplayName',['BIN-' upper(bintype{its})])
         hold off

         xlabel([indvar_ename{ivar} indvar_units{ivar}])
         ylabel('Altitude [m]')
         set(gca,'fontsize',16)
         grid on
         title(['(', Alphabet(ivar),')'],'fontweight','normal')
         legend('show','location','best')
      end   
      if ivar == 1
         xlim([0 max(time)])
      elseif ivar == 2
         xlim([700 max(time)])
      end

   end

   nexttile
   nanimagesc(binmean, z, squeeze(amp2m_PSDprof(itime, :, :))')
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
   title(['(d) S-AMP-' upper(bintype{its})],'fontweight','normal')
   set(gca,'fontsize',16)

   nexttile
   nanimagesc(binmean, z, squeeze(bin_PSDprof(itime, :, :))')
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
   title(['(e) BIN-' upper(bintype{its})],'fontweight','normal')
   set(gca,'fontsize',16)


   nexttile
   nanimagesc(binmean, z, squeeze(amp4m_PSDprof(itime, :, :))')
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
   title(['(f) U-AMP-' upper(bintype{its})],'fontweight','normal')
   set(gca,'fontsize',16)


   title(tl,sprintf('Snapshot of Na200w04 @ t = %d s', real_time),...
      'fontweight','bold','fontsize',24)

   exportgraphics(gcf,['plots/p2/fs11_snapshot_fullmp ',bintype{TAUorSBM},'.pdf'])
   saveas(gcf,['plots/p2/fs11_snapshot_fullmp ',bintype{TAUorSBM},'.fig'])
end
