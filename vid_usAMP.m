clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str dt l_amp fn cloud_mr_th %#ok<*NUSED>

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


confs = [1 2];
% confs = [1 3];
mconfig = mconfig_ls{confs(1)};
disp(mconfig)
case_dep_var

for its = 2
   for ivar1 = 2
   % for ivar12 = [2 1; 2 1]
      % ivar1 = ivar12(1);
      % ivar2 = ivar12(2);
      for ivar2 = 4
         mconfig = mconfig_ls{confs(1)}; disp(mconfig)
         bin_struct = loadnc('bin');
         amp2m_struct = loadnc('amp');
         mconfig = mconfig_ls{confs(2)}; disp(mconfig)
         amp4m_struct = loadnc('amp');

         %% plot
         if its==2
            binmean = load('diamg_sbm.txt');
         elseif its==1
            binmean = load('diamg_tau.txt');
         end

         time = amp2m_struct.time;
         z = amp2m_struct.z;

         bin_DSDprof = bin_struct.mass_dist(:, 1:length(binmean), :);
         amp2m_DSDprof = amp2m_struct.mass_dist_init(:, 1:length(binmean), :);
         amp4m_DSDprof = amp4m_struct.mass_dist_init(:, 1:length(binmean), :);
         dt = time(2) - time(1);

         ti = 1;
         tf = 3600;
         % tf = 1800;
         ts_plot = 20;

         figure('position',[0 0 1500 500])

         tl=tiledlayout('flow');
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
            colormap(cmaps.Blues)
            cbar = colorbar;
            grid
            cbar.Label.String = 'DSD [kg/kg/ln(r)]';
            caxis([1e-8 1e-2])
            set(gca,'colorscale','log')
            xlabel('Diameter [m]')
            ylabel('Altitude [m]')
            title(['S-AMP-' upper(bintype{its})])
            annotation('textbox',[.7 .7 .2 .2],'String',...
               sprintf('t = %.1f s', real_time),'FitBoxToText','on')


            nexttile(2)
            nanimagesc(binmean, z, squeeze(bin_DSDprof(itime, :, :))')
            set(gca,'XScale','log')
            set(gca,'YDir','normal')
            xlim([min(binmean) max(binmean)])
            colormap(cmaps.Blues)
            cbar = colorbar;
            grid
            cbar.Label.String = 'DSD [kg/kg/ln(r)]';
            caxis([1e-8 1e-2])
            set(gca,'colorscale','log')
            xlabel('Diameter [m]')
            ylabel('Altitude [m]')
            title(['BIN-' upper(bintype{its})])


            nexttile(3)
            nanimagesc(binmean, z, squeeze(amp4m_DSDprof(itime, :, :))')
            set(gca,'XScale','log')
            set(gca,'YDir','normal')
            xlim([min(binmean) max(binmean)])
            colormap(cmaps.Blues)
            cbar = colorbar;
            grid
            cbar.Label.String = 'DSD [kg/kg/ln(r)]';
            caxis([1e-8 1e-2])
            set(gca,'colorscale','log')
            xlabel('Diameter [m]')
            ylabel('Altitude [m]')
            title(['U-AMP-' upper(bintype{its})])

            cdata = print('-RGBImage','-r144');
            F(iframe) = im2frame(cdata);
            disp(['time=' num2str(real_time)])

            iframe = iframe + 1;

            delete(findall(gcf,'type','annotation'))
         end

         fn = [mconfig, ' ', bintype{its}, ' ', vnum, ' '];

         saveVid(F,[fn, 'DSD ', ...
            var1_str{ivar1} ' ' var2_str{ivar2}, ' ', ...
            num2str(ti) '-', num2str(tf)], 24)

      end
   end
end
