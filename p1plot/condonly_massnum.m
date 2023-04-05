clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='orig_thres';

global_var

% get the list of configs. cant put it into globar_var
mconfig = 'condnuc';
load('pfm_summary/2022-06-15_condnuc_pfm.mat')


%%

% structure that summarizes sedimentation properties

var_name_mod={'diagM0_cloud','diagM3_cloud'};
var_name_output={'number','mass'};
var_name_label = {'Col-mean num. conc.', 'Col-mean mass conc.'};
var_units = {' [1/cc]', ' [g/kg]'};
nvar=length(var_name_mod);

condsum = struct;
mconfig = 'condnuc';
case_dep_var
ivar1 = 3;
ivar2 = 3;

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

   for ivar = 1:nvar

      for it = 1:length(time)
         amp_cloud_path{ivar}(it) = ...
            nansum(amp_struct.(var_name_mod{ivar})(it,:).*rho(it,:)*dz)/4500;
         bin_cloud_path{ivar}(it) = ...
            nansum(bin_struct.(var_name_mod{ivar})(it,:).*rho(it,:)*dz)/4500;
      end

      if ivar == 1
         amp_cloud_path{ivar} = amp_cloud_path{ivar}/1e6;
         bin_cloud_path{ivar} = bin_cloud_path{ivar}/1e6;
      elseif ivar == 2
         amp_cloud_path{ivar} = amp_cloud_path{ivar}*1e3;
         bin_cloud_path{ivar} = bin_cloud_path{ivar}*1e3;
      end

      condsum.(var_name_output{ivar})((its-1)*2+1,:)=...
         amp_cloud_path{ivar};
      condsum.(var_name_output{ivar})((its-1)*2+2,:)=...
         bin_cloud_path{ivar}(1:length(time));
      ratios(ivar,its) = mean(pfm.(var_name_mod{ivar}).(bintype{its}).mr(:));
      rsq(ivar,its) = mean(pfm.(var_name_mod{ivar}).(bintype{its}).rsq(:));
      % ratios(ivar,its) = wmean(pfm.(var_name_mod{ivar}).(bintype{its}).mr(:),...
      %    pfm.(var_name_mod{ivar}).(bintype{its}).mpath_bin(:));
      % rsq(ivar,its) = wmean(pfm.(var_name_mod{ivar}).(bintype{its}).rsq(:),...
      %    pfm.(var_name_mod{ivar}).(bintype{its}).mpath_bin(:));
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
      plot(time,condsum.(var_name_output{ivar})(iline,:),...
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
   ylabel([var_name_label{ivar} var_units{ivar}])
end

nexttile
str1 = {'(a) Cloud number', ... 
   '% difference / R^2', ...
   sprintf('TAU: %0.1f%% / %0.3f', (ratios(1, 1)-1)*100, rsq(1, 1)), ...
   sprintf('SBM: %0.1f%% / %0.3f', (ratios(1, 2)-1)*100, rsq(1, 2)), ...
   };
annotation('textbox',[0.75 0.48 0.20 0.28],'String', str1, ...
           'FontSize', 14, 'HorizontalAlignment', 'center', ...
           'VerticalAlignment', 'middle', 'edgecolor', [.8 .8 .8])
str1 = {'(b) Cloud mass', ... 
   '% difference / R^2', ...
   sprintf('TAU: %0.1f%% / %0.3f', (ratios(2, 1)-1)*100, rsq(2, 1)), ...
   sprintf('SBM: %0.1f%% / %0.3f', (ratios(2, 2)-1)*100, rsq(2, 2)), ...
   };
annotation('textbox',[0.75 0.2 0.20 0.28],'String', str1, ...
           'FontSize',14, 'HorizontalAlignment', 'center', ...
           'VerticalAlignment', 'middle', 'edgecolor', [.8 .8 .8])
set(gca,'xcolor','none')
set(gca,'ycolor','none')

xlabel(tl,'Time [s]','fontsize',24)
title(tl,'Cond. only - N\fontsize{16}a\fontsize{24} = 400/cc, w\fontsize{16}max\fontsize{24} = 4 m/s','fontsize',24,'fontweight','bold')

exportgraphics(gcf,['plots/p1/condonly_massnum.png'],'Resolution',300)
