clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set ispath isproc isprof iscloud ...
   israin indvar_units_set indvar_units amp_only_var script_name ...
   islink %#ok<*NUSED>

script_name = mfilename;

vnum='0001'; % last four characters of the model output file.
nikki='fullmic';

global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir, nikki);

iconf = 1;
mconfig = mconfig_ls{iconf};
disp(mconfig)
case_dep_var
get_var_comp([83 10])

for its = 1:2
   ivar1 = 3; ivar2 = 1;
   bin_struct = loadnc('bin', indvar_name_set);
   time = bin_struct.time;
   z = bin_struct.z;
   dz = z(2) - z(1);
   vars = 1;
   vare = length(indvar_name);

   figure(1)
   set(gcf,'position',[0 0 1200 400])
   tl = tiledlayout(1,2);
   ivar = 1;
   nexttile
   var_comp_raw_bin = bin_struct.(indvar_name{ivar});
   var_comp_bin = var2phys(var_comp_raw_bin,ivar,1);
   nanimagesc(time,z,var_comp_bin')
   colormap(cmaps.Blues)
   cbar = colorbar;
   cbar.Label.String = [indvar_ename{ivar} indvar_units{ivar}];
   set(gca,'YDir','normal')
   set(gca,'ColorScale','log')
   xlabel('Time [s]')
   ylabel('Altitude [m]')
   title('(a) Liquid Water Content [kg/kg]')
   set(gca,'fontsize',16)
   nexttile
   ivar = 2;
   var_comp_raw_bin = bin_struct.(indvar_name{ivar});
   var_comp_bin = var2phys(var_comp_raw_bin,ivar,1);
   plot(time,var_comp_bin,'LineWidth',2,'color',color_order{its})
   xlabel('Time [s]')
   ylabel('SPR [mm/hr]')
   title('(b) Surface Precipitation Rate [mm/hr]')
   xlim([0 max(time)])
   set(gca,'fontsize',16)

   title(tl,['Time-height view of ' var1_str{ivar1} var2_str{ivar2} ...
      ' (bin-',upper(bintype{its}),')'],...
      'fontsize',24, 'fontweight','bold')
   exportgraphics(gcf,['plots/p2/f02_lwp_spr_ev ' bintype{its} '.pdf'])
   saveas(gcf,['plots/p2/f02_lwp_spr_ev ' bintype{its} '.fig'])
end
