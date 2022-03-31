clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str dt l_amp fn cloud_mr_th %#ok<*NUSED>

% l_amp = 0 for bin, 1 for amp, 2 for both
l_amp=2; 

nikki='2022-01-25';
vnum='0001';
run global_var.m
mconfig_ls = get_mconfig_list(output_dir,nikki);
pltflag='mass';

if contains(pltflag,{'mass','number'})
   cmap='Blues';
   linorlog='log';
elseif strcmp(pltflag,'mass_ratio')
   cmap='coolwarm';
   linorlog='lin';
end

%%
for iconf = 1%:length(mconfig_ls)
   mconfig = mconfig_ls{iconf}
   run case_dep_var.m
   for its = 1%length(bintype)
      for ivar1 = length(var1_str)
         %% read files
         for ivar2 = length(var2_str)
            
            if l_amp % load when == 1 or 2
               [~, ~, ~, ~, amp_struct]=...
                  loadnc('amp',{'mass_dist_init','RH'});
            end
            
            if l_amp~=1 % load when == 0 or 2
               [~, ~, ~, ~, bin_struct]=...
                  loadnc('bin',{'mass_dist','RH'});
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
                  amp_DSDprof = amp_struct.mass_dist_init;
                  amp_DSDprof(amp_DSDprof<cloud_mr_th(1))=0;
                  DSDprof = amp_DSDprof;
                  RH=amp_struct.RH;
               end
               
               if iab==2 % set when ==0 or 2
                  time = bin_struct.time;
                  z = bin_struct.z;
                  bin_DSDprof = bin_struct.mass_dist;
                  bin_DSDprof(2:end,:,:)=bin_DSDprof(1:end-1,:,:);
                  bin_DSDprof(bin_DSDprof<cloud_mr_th(1))=0;
                  DSDprof = bin_DSDprof;
                  RH=bin_struct.RH;
               end
               
               dt=time(2)-time(1);

               if its==2
                  DSDprof=DSDprof(:,1:length(binmean),:);
               end
               
               if strcmp(pltflag,'mass_ratio')
                  if iab==1 
                     continue
                  elseif iab==2
                     bin_DSDprof(2:end,:,:)=bin_DSDprof(1:end-1,:,:);
                     DSD2beplt=amp_DSDprof-bin_DSDprof;
                  end
               elseif strcmp(pltflag,'mass')
                  DSD2beplt=DSDprof;
               end
               
               for itime=1:length(time)
                  for iz=1:length(z)
                     mean_diag(itime,iz)=wmean(binmean,DSDprof(itime,:,iz));
                  end
               end
               
               fn = [ampORbin{iab},'-',bintype{its},' ',...
                  mconfig,'-',vnum,' '];
               total_length=max(time);
               time_step=1;
               DSDprof_timeprog(total_length, time_step, DSD2beplt, z,...
                  binmean,cmap,linorlog,pltflag)
            end
            
         end
         
         
      end
   end
end
