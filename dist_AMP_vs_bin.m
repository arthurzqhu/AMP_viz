clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
   bintype aero_N_str w_spd_str l_amp l_sbm fn cloud_mr_th %#ok<*NUSED>



l_amp=2;
l_sbm=1;

case_interest = 1;


nikki='2021-06-07';
% mconfig='noinit';

% last four characters of the model output file.
vnum='0001';


run global_var.m

mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

%%
for iconf = 1:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   run case_dep_var.m
   for its = 1:length(bintype)
      for ia = 1:length(aero_N_str)
         %% read files
         for iw = length(w_spd_str)
            for ici = case_interest
               
               if l_amp % load when == 1 or 2
                  [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
                     loadnc('amp',case_interest);
               end
               
               if l_amp~=1 % load when == 0 or 2
                  [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
                     loadnc('bin',case_interest);
               end
               
            end
            %% plot
            for ici = case_interest
               if l_sbm
                  binmean = load('diamg_sbm.txt');
               else
                  binmean = load('diamg_tau.txt');
               end
               
               for iab = ab_arr
                  
                  if iab==1
                     time = amp_struct(ici).time;
                     z = amp_struct(ici).z;
                     amp_DSDprof = amp_struct(ici).mass_dist_init;
                     amp_DSDprof(amp_DSDprof<cloud_mr_th(1))=0;
                     DSDprof = amp_DSDprof;
                  end
                  
                  if iab==2 % set when ==0 or 2
                     time = bin_struct(ici).time;
                     z = bin_struct(ici).z;
                     bin_DSDprof = bin_struct(ici).mass_dist;
                     bin_DSDprof(2:end,:,:)=bin_DSDprof(1:end-1,:,:);
                     bin_DSDprof(bin_DSDprof<cloud_mr_th(1))=0;
                     DSDprof = bin_DSDprof;
                     
                     if l_sbm
                        DSDprof=DSDprof(:,1:length(binmean),:);
                     end
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
                  
%                   DSD_rat=amp_DSDprof./bin_DSDprof;
                  fn = [ampORbin{iab},'-',bintype{its},' ',...
                     mconfig,'-',vnum,' '];
                  total_length=length(time);
                  time_step=5;
                  DSDprof_timeprog(total_length, time_step, DSDprof, z,...
                     binmean,'Blues','log','mass')
                  
               end
               
               
            end
         end
         
         
      end
   end
end