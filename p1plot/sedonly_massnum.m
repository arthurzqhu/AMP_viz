clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='normal_threshold';

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
load('pfm_summary/normal_threshold_sedonly_pfm.mat');


%%

% structure that summarizes sedimentation properties

var_name_mod={'diagM0_rain','diagM3_rain'};
var_name_output={'number','mass'};
nvar=length(var_name_mod);

for iconf = length(mconfig_ls)
   sedsum=struct;
   mconfig=mconfig_ls{iconf};
   run case_dep_var.m
   for ivar1=length(var1_str)
      %             close all
      for ivar2=2%length(var2_str)
         %                 close all
         for its=1:length(bintype)
            [its ivar1 ivar2]
            amp_struct = loadnc('amp');
            bin_struct = loadnc('bin');
            %%

            time = amp_struct.time;
            z = amp_struct.z;
            dz = z(2) - z(1);
            try
               rho = bin_struct.density;
            end

            for ivar=1:nvar
               rain_i(ivar) = nansum(amp_struct.(var_name_mod{ivar})(1,:).*rho(1,:)*dz);
               for it = 1:length(time)
                  amp_rain_path{ivar}(it) = nansum(amp_struct.(var_name_mod{ivar})(it,:).*rho(it,:)*dz);
                  bin_rain_path{ivar}(it) = nansum(bin_struct.(var_name_mod{ivar})(it,:).*rho(it,:)*dz);
               end

               sedsum.(var_name_output{ivar})((its-1)*2+1,:)=...
                  amp_rain_path{ivar}/rain_i(ivar);
               sedsum.(var_name_output{ivar})((its-1)*2+2,:)=...
                  bin_rain_path{ivar}(1:length(time))/rain_i(ivar);
               ratios(ivar,its) = mean(pfm.(var_name_mod{ivar}).(bintype{its}).mr(:));
               rsq(ivar,its) = mean(pfm.(var_name_mod{ivar}).(bintype{its}).rsq(:));
            end % ivar
         end % its

         %% figures
         figure('Position',[1291 631 850 346])
         tl=tiledlayout(1,5);

         style_order={'-','--','-','--'};

         for ivar=1:nvar
            nexttile((ivar-1)*2+1, [1 2])

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

         nexttile
         str1 = {'(a) Rain number', ... 
            '% difference / R^2', ...
            sprintf('TAU: %0.1f%% / %0.3f', (ratios(1, 1)-1)*100, rsq(1, 1)), ...
            sprintf('SBM: %0.1f%% / %0.3f', (ratios(1, 2)-1)*100, rsq(1, 2)), ...
            };
         annotation('textbox',[0.75 0.5 0.20 0.3],'String', str1, ...
                  'FontSize', 14, 'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', 'edgecolor', [.8 .8 .8])
         str1 = {'(b) Rain mass', ... 
            '% difference / R^2', ...
            sprintf('TAU: %0.1f%% / %0.3f', (ratios(2, 1)-1)*100, rsq(2, 1)), ...
            sprintf('SBM: %0.1f%% / %0.3f', (ratios(2, 2)-1)*100, rsq(2, 2)), ...
            };
         annotation('textbox',[0.75 0.2 0.20 0.3],'String', str1, ...
                  'FontSize', 14, 'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', 'edgecolor', [.8 .8 .8])
         set(gca,'xcolor','none')
         set(gca,'ycolor','none')

         xlabel(tl,'Time [s]','fontsize',24)
         ylabel(tl,'Fraction left','fontsize',24)
         title(tl,'Sed. only - D\fontsize{16}m\fontsize{24} = 600 \mum, \nu = 3','fontsize',24,'fontweight','bold')
         exportgraphics(gcf,['plots/p1/sedonly_massnum.jpg'],'Resolution',300)


      end % ivar2
   end % ivar1


end % iconf
