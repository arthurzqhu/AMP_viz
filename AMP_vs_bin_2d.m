clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
   bintype aero_N_str w_spd_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-05-12';
case_interest = [7]; % 1:length(case_list_num);

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

%%
for iconf = 1:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   %     mconfig = 'adv_coll';
   run case_dep_var.m
   %% read files
   %     close all
   
   
   
   for its = 1:length(bintype)
      for ia = 1:length(aero_N_str)
         %             close all
         for iw = 1:length(w_spd_str)
            %                 close all
            
            [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
               loadnc('amp',case_interest);
            [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
               loadnc('bin',case_interest);
            % indices of vars to compare
            vars=1;
            vare=length(indvar_name);
            
            %%
            % plot
            for ici = case_interest
               time=amp_struct(ici).time;
               z=amp_struct(ici).z;
               x=amp_struct(ici).x;
               cloudm1=bin_struct(ici).cloud_M1;
               rainm1=bin_struct(ici).rain_M1;
               cloudm1(cloudm1==-999)=0;
               rainm1(rainm1==-999)=0;
               
               tidx=1;
               for itime = 1:length(time)
                  % reshaped cloud m1
                  cm1_rs = reshape(cloudm1(itime,:,:),length(x),[]);
                  nanimagesc(x,z,cm1_rs)
                  colormap(Blues)
                  colorbar
                  set(gca,'ColorScale','log')
                  caxis([1e-9 1e-3])
                  F(tidx)=getframe(gcf);
                  
                  tidx=tidx+1;
               end
               v = VideoWriter(['vids/2D cloud viz bin_sbm.mp4'],'MPEG-4');
               v.FrameRate=30;
               open(v)
               writeVideo(v,F)
               close(v)
            end
         end
      end
   end
end