clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2022-01-25';

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};


%%

% structure that summarizes sedimentation properties

var_name_mod={'diagM0_cloud','diagM3_cloud'};
var_name_output={'number','mass'};
nvar=length(var_name_mod);

for iconf = 1%:length(mconfig_ls)
   evapsum=struct;
   mconfig=mconfig_ls{iconf};
   run case_dep_var.m
   for ivar1=length(var1_str)
         %             close all
      for ivar2=length(var2_str)
            %                 close all
         for its=1:length(bintype)
            [ivar1 ivar2 its]
            [~, ~, ~, ~, amp_struct]=...
               loadnc('amp');
            [~, ~, ~, ~, bin_struct]=...
               loadnc('bin');

            amp_fn=['amp_' bintype{its}];
            bin_fn=['bin_' bintype{its}];

            %%
            time=amp_struct.time;

            for ivar=1:nvar
               cloud_i(ivar)=sum(amp_struct.(var_name_mod{ivar})(1,:));
               amp_cloud_path{ivar}=sum(amp_struct.(var_name_mod{ivar}),2);
               bin_cloud_path{ivar}=sum(bin_struct.(var_name_mod{ivar}),2);

               evapsum.(var_name_output{ivar})((its-1)*2+1,:)=...
                  amp_cloud_path{ivar}/cloud_i(ivar);
               evapsum.(var_name_output{ivar})((its-1)*2+2,:)=...
                  bin_cloud_path{ivar}(1:length(time))/cloud_i(ivar);
            end
         end

        %% figures
        figure('Position',[1291 631 850 346])
        tl=tiledlayout('flow');
        
        style_order={'-','--','-','--'};
        
        for ivar=1:nvar
           nexttile
           
           for iline=1:4
              hold on
              plot(time,evapsum.(var_name_output{ivar})(iline,:),...
                 'LineWidth',2,...
                 'LineStyle',style_order{iline},...
                 'color',color_order{ceil(iline/2)})
              ylim([0 1])
           end
           grid
           hold off
           legend('AMP-TAU','bin-TAU','AMP-SBM','bin-SBM','Location','best')
           set(gca,'FontSize',18)
           title(['(' char(96+ivar) ')' ' Cloud ' var_name_output{ivar}],'fontweight','normal')
        end
        
        xlabel(tl,'Time [s]','fontsize',24)
        ylabel(tl,'Fraction evaporated','fontsize',24)
        title(tl,'Evap. only - 99% RH, Dm=25\mum','fontsize',24,'fontweight','bold')
        exportgraphics(gcf,['plots/p1/fig' num2str(8) '.jpg'],'Resolution',300)


      end
   end

   
end
