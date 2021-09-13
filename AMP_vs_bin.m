clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
   bintype aero_N_str w_spd_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set ispath isproc isprof iscloud ...
   israin indvar_units_set indvar_units%#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-09-09';
case_interest = [1]; % 1:length(case_list_num);

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

for iconf = 1:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   %     mconfig = 'adv_coll';
   run case_dep_var.m
   %% read files
   
   for its = 1:length(bintype)
      for ia = 1:length(aero_N_str)
         %             close all
         for iw = 1:length(w_spd_str)
            
            [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
               loadnc('amp',case_interest);
            [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
               loadnc('bin',case_interest);
            % indices of vars to compare
            vars=1;
            vare=length(indvar_name);
            
            % plot
            for ici = case_interest
               %%
               iclr=3; % color idx for proc rate
               time = amp_struct(ici).time;
               z = amp_struct(ici).z;
               % assuming all vertical layers have the same
               % thickness
               dz = z(2)-z(1);
               
               for ivar = vars:vare
                  
                  var_comp_raw_amp = amp_struct(ici).(indvar_name{ivar});
                  [var_comp_amp,~,~] = var2phys(var_comp_raw_amp,ivar,1);
                  
                  var_comp_raw_bin = bin_struct(ici).(indvar_name{ivar});
                  [var_comp_bin,linORlog,range] = var2phys(var_comp_raw_bin,ivar,1);
                  
                  % change linestyle according to cloud/rain
                  if israin
                     lsty=':';
                  else
                     lsty='-';
                  end
                  
                  if ispath
                     % plot cloud/rain water path comparison
                     set(0,'CurrentFigure',fig_path)
                     
                     plot(time,var_comp_amp,...
                        'LineWidth',2,...
                        'LineStyle',lsty,...
                        'color',color_order{1})
                     hold on
                     plot(time,var_comp_bin,...
                        'LineWidth',2,...
                        'LineStyle',lsty,...
                        'color',color_order{2})
                     
                     xlim([min(time) max(time)])
                     xlabel('Time [s]')
                     
                     if israin
                        % only do these when both cloud and rain are plotted
                        ylabel(['liquid water path' indvar_units{ivar}])
                        legend(['amp-' bintype{its}, ' cloud'],...
                           ['bin-' bintype{its},' cloud'],...
                           ['amp-' bintype{its}, ' rain'],...
                           ['bin-' bintype{its},' rain'],...
                           'Location','southwest')
                     else
                        ylabel([indvar_ename{ivar} indvar_units{ivar}])
                        legend(['amp-' bintype{its}],...
                           ['bin-' bintype{its}],...
                           'Location','southwest')
                        if contains(indvar_name{ivar},'albedo')
                           ylim([0 1])
                        end
                     end
                     
                     if israin || (~israin && ~iscloud)
                        % save fig when both cloud and rain are plotted or
                        % neither is being plotted
                        set(gca,'fontsize',16)
                        
                        title([mconfig ' ' bintype{its},' ', ...
                           aero_N_str{ia},' ' ...
                           w_spd_str{iw}],...
                           'fontsize',20,...
                           'FontWeight','bold')
                        
                        if israin
                           % variable name in file name
                           vnifn='liquid water path'; 
                        else
                           vnifn=indvar_ename{ivar};
                        end
                        
                        hold off
                        
                        if l_save
                           saveas(fig_path,[plot_dir,...
                              vnifn, ' ',...
                              'amp vs bin-',bintype{its},' ',...
                              case_list_str{ici},'-',vnum,' ',...
                              aero_N_str{ia}, ' ', w_spd_str{iw},'.png'])
                        end
                     end
                     
                  elseif isproc
                     % plot cloud/rain individual process
                     set(0,'CurrentFigure',fig_proc)
                     
                     amp_proc_path=col_intg(var_comp_amp,dz,...
                        amp_struct(ici).pressure*100,...
                        amp_struct(ici).temperature);
                     bin_proc_path=col_intg(var_comp_bin,dz,...
                        bin_struct(ici).pressure*100,...
                        bin_struct(ici).temperature);
                     
                     plot(time,amp_proc_path,...
                        'LineWidth',2,...
                        'LineStyle',':',...
                        'color',color_order{iclr},...
                        'DisplayName',['amp ' indvar_ename{ivar}])
                     hold on
                     plot(time,bin_proc_path,...
                        'LineWidth',1,...
                        'LineStyle','-',...
                        'color',color_order{iclr},...
                        'DisplayName',['bin ' indvar_ename{ivar}])
                     
                     xlim([min(time) max(time)])
                     xlabel('Time [s]')
                     ylabel('col integrated proc rates')
                     
                     % assuming the process rates var comes after
                     % all other ones
                     if ivar==vare
                        set(gca,'fontsize',16)
                        
                        legend('show','Location','southwest')
                        hold off
                        
                        if l_save
                           saveas(fig_proc,[plot_dir,...
                              'procrate ',...
                              'amp vs bin-',bintype{its},' ',...
                              case_list_str{ici},'-',vnum,' ',...
                              aero_N_str{ia}, ' ', w_spd_str{iw},'.png'])
                        end
                     end
                     
%                      if israin
                        % only change color if after there's a rain
                        % variable
                        iclr=iclr+1;
%                      end
                     
                  elseif isprof
                     set(0,'CurrentFigure',fig_prof)
                     for iab = 1:length(ampORbin)
                        % plot cloud/rain water profile
                        if iab==1
                           var_plt = var_comp_amp;
                        else
                           var_plt = var_comp_bin;
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
                        
                        title([mconfig ' ' ampORbin{iab},'-',...
                           bintype{its}, ' ', ...
                           indvar_ename{ivar}, ' ', ...
                           aero_N_str{ia},' ' ...
                           w_spd_str{iw}],...
                           'fontsize',20,...
                           'FontWeight','bold')
                        
                        if l_save
                           saveas(fig_prof,[plot_dir,...
                              indvar_ename{ivar},' ', ...
                              ampORbin{iab},'-',bintype{its},' ',...
                              case_list_str{ici},'-',...
                              vnum,' ',...
                              aero_N_str{ia}, ' ', w_spd_str{iw},'.png'])
                        end
                     end
                  end
                  pause(.5) % (optional) to prevent matlab from halting
               end
               
            end
            
            % plot difference
            for ici = case_interest
               %%
               iclr=3; % color idx for proc rate
               for ivar = vars:vare
                  
                  time = amp_struct(ici).time;
                  z = amp_struct(ici).z;
                  var_comp_raw_amp = amp_struct(ici).(indvar_name{ivar});
                  [var_comp_amp,~,~] = var2phys(var_comp_raw_amp,...
                     ivar,1);
                  
                  var_comp_raw_bin = bin_struct(ici).(indvar_name{ivar});
                  [var_comp_bin,linORlog,range] = var2phys(var_comp_raw_bin,...
                     ivar,1);
                  
                  if israin
                     lsty=':';
                  else
                     lsty='-';
                  end
                  
                  var_comp_amp(isnan(var_comp_amp))=0;
                  var_comp_bin(isnan(var_comp_bin))=0;
                  
                  var_diff = var_comp_bin-var_comp_amp;
                  
                  if isproc
                     amp_proc_path=col_intg(var_comp_amp,dz,...
                        amp_struct(ici).pressure*100,...
                        amp_struct(ici).temperature);
                     bin_proc_path=col_intg(var_comp_bin,dz,...
                        bin_struct(ici).pressure*100,...
                        bin_struct(ici).temperature);
                     var_diff=bin_proc_path-amp_proc_path;
                  end
                  
                  bound=10^(ceil(log10(prctile(abs(var_diff(:)),99))*2)/2);
                  
                  if bound==0
                     bound=10^(ceil(log10(max(abs(var_diff(:))))*2)/2);
                  end
                  
                  if ispath
                     % plot path difference
                     set(0,'CurrentFigure',fig_pathdiff)
                     
                     refline(0,0)
                     plot(time,var_diff,'LineWidth',2,...
                        'LineStyle',lsty,...
                        'color',color_order{1})
                     hold on
                     xlim([min(time) max(time)])
                     xlabel('Time [s]')
                     
                  elseif isproc
                     set(0,'CurrentFigure',fig_procdiff)
                     
                     rl=refline(0,0);
                     rl.HandleVisibility='off';
                     plot(time,var_diff,'LineWidth',2,...
                        'LineStyle',lsty,...
                        'color',color_order{iclr},...
                        'DisplayName',['bin-amp ' indvar_ename{ivar}])
                     hold on
                     xlim([min(time) max(time)])
                     xlabel('Time [s]')
                     ylabel('\Deltaind proc rate')
                     
                     if contains(indvar_name{ivar},'rain')
                        iclr=iclr+1;
                     end
                  elseif isprof
                     % plot profile difference
                     set(0,'CurrentFigure',fig_profdiff)
                     
                     nanimagesc(time,z,var_diff')
                     set(gca,'YDir','normal')
                     colormap(coolwarm)
                     caxis([-bound bound]);
                     set(gca,'ColorScale','lin')
                     cbar = colorbar;
                     cbar.Label.String = 'prof diff';
                     xlabel('Time [s]')
                     ylabel('Altitude [m]')
                     
                     title([mconfig ' ' '\Delta',bintype{its},'-amp ',...
                        indvar_ename{ivar}, ' ', ...
                        aero_N_str{ia},' ',...
                        w_spd_str{iw}, ' '],...
                        'fontsize',20,'FontWeight','bold')
                  end
                  
                  set(gca,'fontsize',16)
                  if ispath
                     if israin || (~israin && ~iscloud)
                        title([mconfig ' ' bintype{its}, ' ', ...
                           aero_N_str{ia},' ' ...
                           w_spd_str{iw}],...
                           'fontsize',20,...
                           'FontWeight','bold')
                        
                        if israin
                           ylabel('\Deltaliquid water path')
                           legend('bin-amp cloud','','bin-amp rain',...
                              'Location','southwest')
                           vnifn='liquid water path';
                        else
                           ylabel(['\Delta',indvar_ename{ivar} indvar_units{ivar}])
                           vnifn=indvar_name{ivar};
                        end
                        
                        hold off
                        if l_save
                           saveas(fig_pathdiff,[plot_dir,...
                              vnifn, ' ',...
                              bintype{its},'-amp diff', ...
                              ' ',case_list_str{ici},'-',vnum,' ',...
                              aero_N_str{ia},' ',...
                              w_spd_str{iw},'.png'])
                        end
                     end
                     
                  elseif isproc
                     if ivar==vare
                        title([mconfig ' column integrated process rate'])
                        legend('show','Location','southwest')
                        hold off
                        if l_save
                           saveas(fig_procdiff,[plot_dir,...
                              'procrate ',...
                              bintype{its},'-amp diff', ...
                              ' ',case_list_str{ici},'-',vnum,' ',...
                              aero_N_str{ia},' ',...
                              w_spd_str{iw},'.png'])
                        end
                     end
                  elseif isprof
                     %only save the comparison when both are plotted
                     hold off
                     if l_save
                        saveas(fig_profdiff,[plot_dir,...
                           indvar_ename{ivar},' ',...
                           bintype{its},'-amp diff', ...
                           ' ',case_list_str{ici},'-',vnum,' ',...
                           aero_N_str{ia},' ',...
                           w_spd_str{iw},'.png'])
                     end
                  end
                  
                  pause(.5)
               end
            end
         end
      end
   end
end
%%
% set(0,'CurrentFigure',fig_path)
% blk_meta=dir('/Volumes/ESSD/AMP output/2021-05-05/KiD_m-thompson09_b-+_u-Adele_c-0102_v-0001.nc');
% blk_info=ncinfo('/Volumes/ESSD/AMP output/2021-05-05/KiD_m-thompson09_b-+_u-Adele_c-0102_v-0001.nc');
% for ivar = 1:length(blk_info.Variables)
%    var_name{ivar,1} = blk_info.Variables(ivar).Name;
%    blk_struct(ici).(var_name{ivar}) = ncread('/Volumes/ESSD/AMP output/2021-05-05/KiD_m-thompson09_b-+_u-Adele_c-0102_v-0001.nc', var_name{ivar});
% end
% 
% hold on
% plot(time,blk_struct(2).cloud_M1_path,'LineWidth',2,...
%    'Color',color_order{3},'DisplayName','thompson cloud')
% plot(time,blk_struct(2).rain_M1_path,'LineWidth',2,'LineStyle',':',...
%    'Color',color_order{3},'DisplayName','thompson rain')
% saveas(gcf,'plots/amp vs bin vs thompson.png')