clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2022-02-04';

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};


%%

% structure that summarizes sedimentation properties

var_name_mod={'diagM0_rain','diagM3_rain'};
var_name_output={'number','mass'};
nvar=length(var_name_mod);

for iconf = 1%length(mconfig_ls)
   sedsum=struct;
   mconfig=mconfig_ls{iconf};
   run case_dep_var.m
   for ivar1=length(var1_str)
         %             close all
      for ivar2=2%length(var2_str)
            %                 close all
         for its=1:length(bintype)
            [its ivar1 ivar2]
            [~, ~, ~, ~, amp_struct]=...
               loadnc('amp');
            [~, ~, ~, ~, bin_struct]=...
               loadnc('bin');

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
            end % ivar
         end % its

        %% figures
        figure('Position',[1291 631 850 346])
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
              ylim([0 1])
           end % iline
           grid
           hold off
           legend('AMP-TAU','bin-TAU','AMP-SBM','bin-SBM','Location','best')
           set(gca,'FontSize',18)
           title(['(' char(96+ivar) ') ' 'Rain ' var_name_output{ivar}],'fontweight','normal')
        end % ivar
        
        xlabel(tl,'Time [s]','fontsize',24)
        ylabel(tl,'Fraction left','fontsize',24)
        title(tl,'Sed. only - Dm=600\mum, \nu=3','fontsize',24,'fontweight','bold')
        exportgraphics(gcf,['plots/p1/sedonly_massnum.jpg'],'Resolution',300)


      end % ivar2
   end % ivar1

   
end % iconf
