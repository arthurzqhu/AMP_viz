clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set ispath isproc isprof iscloud ...
   israin indvar_units_set indvar_units%#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-11-27';

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

set(0, 'DefaultFigurePosition',[1553 458 1028 527])
%%
% create separate figure widows for profile, path, process rates, and
% their differences between AMP and BIN

l_save=1; % set to 1 to save plots
l_visible=0; % set to 0 for faster output

fig_prof=figure('Position',[1553 458 1028 527]);
fig_path=figure('Position',[1553 458 1028 527]);
fig_proc=figure('Position',[1553 458 1028 527]);
fig_profdiff=figure('Position',[1553 458 1028 527]);
fig_pathdiff=figure('Position',[1553 458 1028 527]);
fig_procdiff=figure('Position',[1553 458 1028 527]);

%%

if ~l_visible
   set(fig_prof,'Visible','off')
   set(fig_path,'Visible','off')
   set(fig_proc,'Visible','off')
   set(fig_profdiff,'Visible','off')
   set(fig_pathdiff,'Visible','off')
   set(fig_procdiff,'Visible','off')
end

for iconf = 7%1:length(mconfig_ls)
   iconf
   mconfig = mconfig_ls{iconf}
   %     mconfig = 'adv_coll';
   run case_dep_var.m
   %% read files
   
   for ivar1 = 1:length(var1_str)
      %             close all
      for ivar2 = 1:length(var2_str)

         its=1;
         [~, ~, ~, ~, tau_struct]=...
            loadnc('bin');
         its=2;
         [~, ~, ~, ~, sbm_struct]=...
            loadnc('bin');
         % indices of vars to compare
         vars=1;
         vare=length(indvar_name);
         
         % plot
         %%
         iclr=3; % color idx for proc rate
         time = sbm_struct.time;
         z = sbm_struct.z;
         % assuming all vertical layers have the same
         % thickness
         dz = z(2)-z(1);
         
         for ivar = vars:vare
            
            var_comp_raw_tau = tau_struct.(indvar_name{ivar});
            [var_comp_tau,~,~] = var2phys(var_comp_raw_tau,ivar,1);
            
            var_comp_raw_sbm = sbm_struct.(indvar_name{ivar});
            [var_comp_sbm,linORlog,range] = var2phys(var_comp_raw_sbm,ivar,1);
            
            % change linestyle according to cloud/rain
            if israin
               lsty=':';
            else
               lsty='-';
            end
            
            if ispath
               % plot cloud/rain water path comparison
               set(0,'CurrentFigure',fig_path)
               
               plot(time,var_comp_tau,...
                  'LineWidth',2,...
                  'LineStyle',lsty,...
                  'color',color_order{1})
               hold on
               plot(time,var_comp_sbm,...
                  'LineWidth',2,...
                  'LineStyle',lsty,...
                  'color',color_order{2})
               
               xlim([min(time) max(time)])
               xlabel('Time [s]')
               
               if israin
                  % only do these when both cloud and rain are plotted
                  ylabel(['liquid water path' indvar_units{ivar}])
                  legend(['tau cloud'],...
                     ['sbm cloud'],...
                     ['tau rain'],...
                     ['sbm rain'],...
                     'Location','northwest')
               else
                  ylabel([indvar_ename{ivar} indvar_units{ivar}])
                  legend(['tau'],...
                     ['sbm'],...
                     'Location','northwest')
                  if contains(indvar_name{ivar},'albedo')
                     ylim([0 1])
                  end
               end
               
               if israin || (~israin && ~iscloud)
                  % save fig when both cloud and rain are plotted or
                  % neither is being plotted
                  set(gca,'fontsize',16)
                  
                  title([mconfig ' ' , ...
                     var1_str{ivar1},' ' ...
                     var2_str{ivar2}],...
                     'fontsize',20,...
                     'FontWeight','bold')
                  
                  if israin
                     % variable name in file name
                     vnifn='cloud rain water path'; 
                  else
                     vnifn=indvar_ename{ivar};
                  end
                  
                  hold off
                  
                  if l_save
                     saveas(fig_path,[plot_dir,'/bincomp',...
                        vnifn, ' ',...
                        'tau vs sbm ',...
                        var1_str{ivar1}, ' ', var2_str{ivar2},'.png'])
                  end
               end
               
            elseif isproc
               % plot cloud/rain individual process
               set(0,'CurrentFigure',fig_proc)
               
               tau_proc_path=col_intg(var_comp_tau,dz,...
                  tau_struct.pressure*100,...
                  tau_struct.temperature);
               sbm_proc_path=col_intg(var_comp_sbm,dz,...
                  sbm_struct.pressure*100,...
                  sbm_struct.temperature);
               
               plot(time,tau_proc_path,...
                  'LineWidth',2,...
                  'LineStyle',':',...
                  'color',color_order{iclr},...
                  'DisplayName',['tau ' indvar_ename{ivar}])
               hold on
               plot(time,sbm_proc_path,...
                  'LineWidth',1,...
                  'LineStyle','-',...
                  'color',color_order{iclr},...
                  'DisplayName',['sbm ' indvar_ename{ivar}])
               
               xlim([min(time) max(time)])
               xlabel('Time [s]')
               ylabel('col integrated proc rates')
               
               % assuming the process rates var comes after
               % all other ones
               if ivar==vare
                  set(gca,'fontsize',16)
                  
                  legend('show','Location','northwest')
                  hold off
                  
                  if l_save
                     saveas(fig_proc,[plot_dir,'/bincomp',...
                        'procrate ',...
                        'tau vs sbm ',...
                        var1_str{ivar1}, ' ', var2_str{ivar2},'.png'])
                  end
               end
               
%                if israin
                  % only change color if after there's a rain
                  % variable
                  iclr=iclr+1;
%                end
               
            elseif isprof
               set(0,'CurrentFigure',fig_prof)
               for iab = 1:length(ampORbin)
                  % plot cloud/rain water profile
                  if iab==1
                     var_plt = var_comp_tau;
                  else
                     var_plt = var_comp_sbm;
                  end
                  
                  nanimagesc(time,z,var_plt')
                  set(gca,'YDir','normal')
                  if ~contains(indvar_name{ivar},{'flag','adv','mphys'})
                     colormap(Blues)
                  else
                     colormap(coolwarm)
                  end
                  set(gca,'ColorScale',linORlog)
                  caxis(range)
                  cbar = colorbar;
                  cbar.Label.String = [indvar_ename{ivar} indvar_units{ivar}];
                  xlabel('Time [s]')
                  ylabel('Altitude [m]')
                  hold off
                  set(gca,'fontsize',16)
                  
                  title([mconfig ' ', ...
                     indvar_ename{ivar}, ' ', ...
                     var1_str{ivar1},' ' ...
                     var2_str{ivar2}],...
                     'fontsize',20,...
                     'FontWeight','bold')
                  
                  if l_save
                     saveas(fig_prof,[plot_dir,'/bincomp'...
                        indvar_ename{ivar},' ',...
                        var1_str{ivar1}, ' ', var2_str{ivar2},'.png'])
                  end
               end
            end
            pause(.5) % (optional) to prevent matlab from halting
         end
      end
   end
end
