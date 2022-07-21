clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2022-06-15';

global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
load('pfm_summary/2022-06-15_evaponly_pfm.mat');
get_var_comp


%%

% structure that summarizes sedimentation properties

var_name_mod={'diagM0_cloud','diagM3_cloud'};
var_name_output={'number','mass'};
nvar=length(var_name_mod);

evapsum=struct;
mconfig = 'evaponly';
case_dep_var

for ivar1=length(var1_str)
   for ivar2=length(var2_str)
      for its=1:length(bintype)
         [ivar1 ivar2 its]
         amp_struct = loadnc('amp');
         bin_struct = loadnc('bin');
         amp_fn=['amp_' bintype{its}];
         bin_fn=['bin_' bintype{its}];

         %%
         time = amp_struct.time;
         z = amp_struct.z;
         dz = z(2) - z(1);
         try
            rho = bin_struct.density;
         end

         for ivar=1:nvar

            % cloud_i(ivar)=sum(amp_struct.(var_name_mod{ivar})(1,:));
            % amp_cloud_path{ivar}=sum(amp_struct.(var_name_mod{ivar}),2);
            % bin_cloud_path{ivar}=sum(bin_struct.(var_name_mod{ivar}),2);

            cloud_i(ivar) = nansum(amp_struct.(var_name_mod{ivar})(1,:).*rho(1,:)*dz);
            for it = 1:length(time)
               amp_cloud_path{ivar}(it) = nansum(amp_struct.(var_name_mod{ivar})(it,:).*rho(it,:)*dz);
               bin_cloud_path{ivar}(it) = nansum(bin_struct.(var_name_mod{ivar})(it,:).*rho(it,:)*dz);
            end

            evapsum.(var_name_output{ivar})((its-1)*2+1,:)=...
               amp_cloud_path{ivar}/cloud_i(ivar);
            evapsum.(var_name_output{ivar})((its-1)*2+2,:)=...
               bin_cloud_path{ivar}(1:length(time))/cloud_i(ivar);
            ratios(ivar,its) = mean(pfm.(var_name_mod{ivar}).(bintype{its}).mr(:));
            rsq(ivar,its) = mean(pfm.(var_name_mod{ivar}).(bintype{its}).rsq(:));
         end
      end

      %% figures
      figure('Position',[1291 631 850 346])
      tl=tiledlayout(1,5);

      style_order={'-','--','-','--'};

      for ivar=1:nvar
         nexttile((ivar-1)*2+1, [1 2])
         for iline=1:4
            hold on
            plot(time,evapsum.(var_name_output{ivar})(iline,:),...
               'LineWidth',2,...
               'LineStyle',style_order{iline},...
               'color',color_order{ceil(iline/2)})
            % ylim([0 1])
         end
         grid
         hold off
         legend('AMP-TAU','bin-TAU','AMP-SBM','bin-SBM','Location','best')
         set(gca,'FontSize',18)
         title(['(' char(96+ivar) ')' ' Cloud ' var_name_output{ivar}],'fontweight','normal')
      end

      nexttile
      str1 = {'(a) Cloud number', ... 
         '% difference / R^2', ...
         sprintf('TAU: %0.1f%% / %0.3f', (ratios(1, 1)-1)*100, rsq(1, 1)), ...
         sprintf('SBM: %0.1f%% / %0.3f', (ratios(1, 2)-1)*100, rsq(1, 2)), ...
         };
      annotation('textbox',[0.75 0.5 0.20 0.3],'String', str1, ...
                 'FontSize', 14, 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'edgecolor', [.8 .8 .8])
      str1 = {'(b) Cloud mass', ... 
         '% difference / R^2', ...
         sprintf('TAU: %0.1f%% / %0.3f', (ratios(2, 1)-1)*100, rsq(2, 1)), ...
         sprintf('SBM: %0.1f%% / %0.3f', (ratios(2, 2)-1)*100, rsq(2, 2)), ...
         };
      annotation('textbox',[0.75 0.2 0.20 0.3],'String', str1, ...
                 'FontSize',14, 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'edgecolor', [.8 .8 .8])
      set(gca,'xcolor','none')
      set(gca,'ycolor','none')

      xlabel(tl,'Time [s]','fontsize',24)
      ylabel(tl,'Fraction left','fontsize',24)
      title(tl,'Evap. only - RH = 99%, Dm = 27\mum','fontsize',24,'fontweight','bold')
      exportgraphics(gcf,['plots/p1/evaponly_massnum.png'],'Resolution',300)
   end
end
