clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str dt l_amp fn cloud_mr_th %#ok<*NUSED>

l_amp=2; 

nikki='2022-08-30';
vnum='0001';
global_var
mconfig_ls = get_mconfig_list(output_dir, nikki);
lvl_plt = 40; % z = 2000 m

for iconf = 3%:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   disp(mconfig)
   case_dep_var
   for its = 1:2%:length(bintype)
      for ivar1 = 1%length(var1_str)
         %% read files
         for ivar2 = 1%length(var2_str)

            if l_amp % load when == 1 or 2
               amp_struct = loadnc('amp');
               time = amp_struct.time;
               z = amp_struct.z;
               wrapper = 'amp';
               DSDplot = amp_struct.mass_dist_init;
            end

            if l_amp~=1 % load when == 0 or 2
               bin_struct = loadnc('bin');
               time = bin_struct.time;
               z = bin_struct.z;
               wrapper = 'bin';
               DSDplot = bin_struct.mass_dist;
            end

            if l_amp==2
               wrapper = 'amp vs bin';
            end

            %% plot
            if its==2
               binmean = load('diamg_sbm.txt');
               nkr = 33;
            elseif its==1
               binmean = load('diamg_tau.txt');
               nkr = 34;
            end
            
            dt=time(2)-time(1);

            ti = 1;
            tf = max(time);
            time_step = 20;

            time_length = floor((tf-ti)/time_step+1);
            F(time_length) = struct('cdata',[],'colormap',[]);
            
            iframe = 1;
            iti = int32(ti/dt);
            itf = int32(tf/dt);
            istep = int32(time_step/dt);

            for itime = iti:istep:itf
               real_time = double(itime)*double(dt);
               % plot(binmean, DSDplot(itime,1:nkr,lvl_plt))
               plot(binmean, amp_struct.mass_dist_init(itime,1:nkr,lvl_plt)); hold on
               plot(binmean, bin_struct.mass_dist(itime,1:nkr,lvl_plt)); hold off
               xlim([min(binmean) max(binmean)])
               % ylim([1e-10 7e-3])
               set(gca, 'XScale', 'log')
               set(gca, 'YScale', 'log')

               annotation('textbox',[.7 .7 .2 .2],'String',...
                  sprintf('t = %.1f s', real_time),'FitBoxToText','on')
               %     title(sprintf('t = %.0f s', real_time))
               cdata = print('-RGBImage','-r144');
               F(iframe) = im2frame(cdata);
               %F(real_time) = getframe(gcf);
               disp(['time=' num2str(real_time)])

               iframe = iframe + 1;

               delete(findall(gcf,'type','annotation'))
            end

            fn = [wrapper, '-', bintype{its}, ' ', ...
               mconfig, '-', vnum, ' '];

            saveVid(F,['DSD at level', num2str(lvl_plt), ' ', ...
               var1_str{ivar1} ' ' var2_str{ivar2} ' ' fn,...
               'profile ' num2str(ti) '-', num2str(tf)], 24)


         end
      end
   end
end
