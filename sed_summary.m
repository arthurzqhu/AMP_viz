clear
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-11-04';
case_interest = [2]; % 1:length(case_list_num);

run global_var.m

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

for iconf = 3%:length(mconfig_ls)
   sedsum=struct;
   mconfig=mconfig_ls{iconf};
   run case_dep_var.m
   for ivar1=1:length(var1_str)
         %             close all
      for ivar2=1:length(var2_str)
            %                 close all
         for its=1:length(bintype)
            [ivar1 ivar2 its]
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

               sedsum.(var_name_output{ivar})((its-1)*2+1,:)=...
                  amp_rain_path{ivar}/rain_i(ivar);
               sedsum.(var_name_output{ivar})((its-1)*2+2,:)=...
                  bin_rain_path{ivar}(1:length(time))/rain_i(ivar);
            end
         end

        %% figures
        figure('Position',[1291 631 1290 346])
        tl=tiledlayout('flow');
        
        style_order={'-','--','-','--'};
        
        for ivar=1:nvar
           nexttile
           
           for iline=1:4
              hold on
              plot(time,sedsum.(var_name_output{ivar})(iline,:),...
                 'LineWidth',2,...
                 'LineStyle',style_order{iline},...
                 'color',color_order{ceil(iline/2)})
              %if ivar<3 ylim([0 1]), end
           end
           grid
           hold off
           legend('amp-tau','bin-tau','amp-sbm','bin-sbm','Location','best')
           set(gca,'FontSize',18)
           title(['Rain ' var_name_output{ivar}(end-1:end)])
        end
        
        xlabel(tl,'time [s]','fontsize',24)
        ylabel(tl,'fractional change','fontsize',24)
        print(gcf,[plot_dir(1:end-1) ' ' var1_str{ivar1} ' ' ...
           var2_str{ivar2} '.jpg'],'-djpeg','-r300')


      end
   end

   
end
