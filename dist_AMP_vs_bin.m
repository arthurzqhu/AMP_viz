clear
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str l_amp fn cloud_mr_th %#ok<*NUSED>



l_amp=2;

case_interest = 2;
nikki='2021-10-16';
% mconfig='noinit';

% last four characters of the model output file.
vnum='0001';

run global_var.m
% bintype = {'sbm'};
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

pltflag='mass';

if strcmp(pltflag,'mass')
   cmap='Blues';
   linorlog='log';
elseif strcmp(pltflag,'mass_ratio')
   cmap='coolwarm';
   linorlog='lin';
end

%%
for iconf = 2%length(mconfig_ls):-1:1
   mconfig = mconfig_ls{iconf};
   run case_dep_var.m
   for its = 1:length(bintype)
      for ivar1 = length(var1_str)
         %% read files
         for ivar2 = [1 length(var2_str)]
            for ici = case_interest
               
               if l_amp % load when == 1 or 2
                  [~, ~, ~, ~, amp_struct]=...
                     loadnc('amp',case_interest);
               end
               
               if l_amp~=1 % load when == 0 or 2
                  [~, ~, ~, ~, bin_struct]=...
                     loadnc('bin',case_interest);
               end
               
            end
            %% plot
            for ici = case_interest
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
                  
                  if its==2
                     DSDprof=DSDprof(:,1:length(binmean),:);
                  end
                  
                  %         generate the comparison animation with another figure
                  %         if l_amp==2
                  %             fn = ['amp vs bin - ',bintype{its},' ',mconfig,' '];
                  %             plot_DSDprof(1,:,:,:) = amp_DSDprof(:,1:length(binmean),:);
                  %             plot_DSDprof(1,2:end,:,:) = plot_DSDprof(1,1:end-1,:,:); % because bin saves DSD after mphys while amp saves before
                  %             tmp_mtx(1,:,:,:)=bin_DSDprof;
                  %             plot_DSDprof(1,1,:,:) = amp_DSDprof(1,1:length(binmean),:); % changed the first bin DSD to the initialized distribution
                  %             plot_DSDprof(2,:,:,:) = tmp_mtx(1,:,1:length(binmean),:); % !!!fix this part
                  %         end
                  
                  if strcmp(pltflag,'mass_ratio')
                     if iab==1 
                        continue
                     elseif iab==2
                        bin_DSDprof(2:end,:,:)=bin_DSDprof(1:end-1,:,:);
%                         bin_DSDprof(1,:,:)=amp_DSDprof(1,:,:);
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
                  time_step=20;
                  DSDprof_timeprog(total_length, time_step, DSD2beplt, z,...
                     binmean,cmap,linorlog,pltflag,RH)
               end
               
            end
         end
         
         
      end
   end
end
