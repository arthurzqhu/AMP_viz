clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
   bintype aero_N_str w_spd_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-09-14';
case_interest = [1]; % 1:length(case_list_num);

run global_var.m
% bintype = {'sbm'};
% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};


%%

% structure that summarizes sedimentation properties

var_name_mod={'diagM0_rain','diagM3_rain','diagM6_rain'};
var_name_output={'rainM0','rainM3','rainM6'};
nvar=length(var_name_mod);

for iconf = 9:length(mconfig_ls)
   sedsum=struct;
   mconfig=mconfig_ls{iconf};
   run case_dep_var.m
   for its=1:length(bintype)
      for ia=1:length(aero_N_str)
         %             close all
         for iw=1:length(w_spd_str)
            %                 close all

            [~, ~, ~, ~, amp_struct]=...
               loadnc('amp',case_interest);
            [~, ~, ~, ~, bin_struct]=...
               loadnc('bin',case_interest);

            amp_fn=['amp_' bintype{its}];
            bin_fn=['bin_' bintype{its}];

   %          pause;
            %%
            time=amp_struct.time;

            for ivar=1:nvar
               rain_i(ivar)=sum(amp_struct.(var_name_mod{ivar})(1,:));
               amp_rain_path{ivar}=sum(amp_struct.(var_name_mod{ivar}),2);
               bin_rain_path{ivar}=sum(bin_struct.(var_name_mod{ivar}),2);

               try sedsum.(var_name_output{ivar})(1,(its-1)*2+1)=...
                  find(amp_rain_path{ivar}<rain_i(ivar)*.75,1,'first'); end
               try sedsum.(var_name_output{ivar})(2,(its-1)*2+1)=...
                  find(amp_rain_path{ivar}<rain_i(ivar)*.50,1,'first'); end
               try sedsum.(var_name_output{ivar})(3,(its-1)*2+1)=...
                  find(amp_rain_path{ivar}<rain_i(ivar)*.25,1,'first'); end
               try sedsum.(var_name_output{ivar})(4,(its-1)*2+1)=...
                  find(amp_rain_path{ivar}<rain_i(ivar)*.1,1,'first'); end

               try sedsum.(var_name_output{ivar})(1,(its-1)*2+2)=...
                  find(bin_rain_path{ivar}<rain_i(ivar)*.75,1,'first'); end
               try sedsum.(var_name_output{ivar})(2,(its-1)*2+2)=...
                  find(bin_rain_path{ivar}<rain_i(ivar)*.50,1,'first'); end
               try sedsum.(var_name_output{ivar})(3,(its-1)*2+2)=...
                  find(bin_rain_path{ivar}<rain_i(ivar)*.25,1,'first'); end
               try sedsum.(var_name_output{ivar})(4,(its-1)*2+2)=...
                  find(bin_rain_path{ivar}<rain_i(ivar)*.1,1,'first'); end
            end



         end
      end
   end

   %% figures
   close all
   figure('Position',[1291 631 1290 346])
   tl=tiledlayout('flow');
   nexttile
   bar(sedsum.rainM0)
   grid
   xticklabels({'25%','50%','75%','90%'})
   set(gca,'FontSize',18)
   legend('amp-tau','bin-tau','amp-sbm','bin-sbm','Location','best')
   title('Rain M0')
   ylim([0 4800])

   nexttile
   bar(sedsum.rainM3)
   grid
   xticklabels({'25%','50%','75%','90%'})
   set(gca,'FontSize',18)
   title('Rain M3')
   ylim([0 4800])

   nexttile
   bar(sedsum.rainM6)
   grid
   xticklabels({'25%','50%','75%','90%'})
   set(gca,'FontSize',18)
   title('Rain M6')
   ylim([0 4800])

   xlabel(tl,'percentage left the system','fontsize',24)
   ylabel(tl,'time [s]','fontsize',24)

   print(gcf,[plot_dir(1:end-1) '.jpg'],'-djpeg','-r300')
   
end