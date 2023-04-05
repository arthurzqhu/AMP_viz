clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str dt l_amp fn cloud_mr_th test

% l_amp = 0 for bin, 1 for amp, 2 for both
l_amp=1; 

nikki='2023-04-04';
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

%%
for iconf = [2]%:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   disp(mconfig)
   case_dep_var
   for its = 1:length(bintype)
      for ivar1 = 2%length(var1_str)
         %% read files
         for ivar2 = 3%:length(var2_str)

            if l_amp % load when == 1 or 2
               amp_struct = loadnc('amp');
            end

            if l_amp~=1 % load when == 0 or 2
               bin_struct = loadnc('bin');
            end

            %% plot
            if its==2
               binmean = load('diamg_sbm.txt');
            elseif its==1
               binmean = load('diamg_tau.txt');
            end

            for iab = ab_arr
               if iab==1
                  time = amp_struct.time;
                  z = amp_struct.z;
                  if contains(pltflag, 'number') && its == 1
                     amp_DSDprof = amp_struct.num_dist_init(:, 1:length(binmean), :);
                  else
                     amp_DSDprof = amp_struct.mass_dist_init(:, 1:length(binmean), :);
                     amp_DSDprof(amp_DSDprof<cloud_mr_th(1))=0;
                  end
                  DSDprof = amp_DSDprof;
                  RH=amp_struct.RH;
               end

               if iab==2 % set when ==0 or 2
                  time = bin_struct.time;
                  z = bin_struct.z;
                  if contains(pltflag, 'number') && its == 1
                     bin_DSDprof = bin_struct.num_dist;
                  else
                     bin_DSDprof = bin_struct.mass_dist(:, 1:length(binmean), :);
                     bin_DSDprof(bin_DSDprof<cloud_mr_th(1))=0;
                  end

                  bin_DSDprof(2:end, :, :)=bin_DSDprof(1:end-1, :, :);
                  DSDprof = bin_DSDprof;
                  RH=bin_struct.RH;
               end

               dt=time(2)-time(1);

               if any(strcmp(pltflag, {'mass_diff', 'number_diff'}))
                  if iab==1 
                     continue
                  elseif iab==2
                     bin_DSDprof(2:end, :, :)=bin_DSDprof(1:end-1, :, :);
                     DSD2beplt=amp_DSDprof-bin_DSDprof;
                  end
               elseif any(strcmp(pltflag, {'mass','number'}))
                  DSD2beplt=DSDprof;
               end

               for itime=1:length(time)
                  for iz=1:length(z)
                     mean_diag(itime, iz)=wmean(binmean, DSDprof(itime, :, iz));
                  end
               end

               fn = [mconfig, ' ', ampORbin{iab}, '-', bintype{its}, ...
                  ' ', vnum, ' '];

               ti = 0;
               tf = max(time);
               time_step=20;

               % ti = 620;
               % tf = 650;
               % time_step = 1;

               % Dns(:,:,1) = amp_struct.Dn_c;
               % Dns(:,:,2) = amp_struct.Dn_r;
               DSDprof_timeprog(ti, tf, time_step, DSD2beplt, z, ...
                  binmean, cmap, linorlog, pltflag)

               % DSDprof_timeprog(ti, tf, time_step, DSD2beplt, z, ...
               %    binmean, cmap, linorlog, pltflag)

            end
         end
      end
   end
end
