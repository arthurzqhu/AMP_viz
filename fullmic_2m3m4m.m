clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set ispath isproc isprof iscloud ...
   israin indvar_units_set indvar_units amp_only_var %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='UAMPvsSAMP_thr0';

global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir, nikki);
get_var_comp([10])

confs = [16 17 18];
mconfig = mconfig_ls{confs(1)};
disp(mconfig)
case_dep_var

figure
set(gcf,'position',[0 0 800 300])
tl=tiledlayout('flow');

ifig = 1;
for ivar1 = [3 2]
   ivar2 = 5-ivar1;
   % ivar2 = 2;
   for its = 1
      mconfig = mconfig_ls{confs(1)}; disp(mconfig)
      bin_struct = loadnc('bin', indvar_name_set);
      amp2m_struct = loadnc('amp', indvar_name_set);

      mconfig = mconfig_ls{confs(2)}; disp(mconfig)
      amp3m_struct = loadnc('amp', indvar_name_set);

      mconfig = mconfig_ls{confs(3)}; disp(mconfig)
      amp4m_struct = loadnc('amp', indvar_name_set);

      % indices of vars to compare
      vars=1;
      vare=length(indvar_name);

      iclr = 1;
      time = amp2m_struct.time;
      z = amp2m_struct.z;
      dz = z(2)-z(1);

      for ivar = vars:vare
         var_comp_raw_amp2m = amp2m_struct.(indvar_name{ivar});
         [var_comp_amp2m, linORlog, range] = var2phys(var_comp_raw_amp2m,ivar,1);

         var_comp_raw_amp3m = amp3m_struct.(indvar_name{ivar});
         [var_comp_amp3m, linORlog, range] = var2phys(var_comp_raw_amp3m,ivar,1);

         var_comp_raw_amp4m = amp4m_struct.(indvar_name{ivar});
         [var_comp_amp4m, linORlog, range] = var2phys(var_comp_raw_amp4m,ivar,1);

         if ~contains(indvar_name{ivar}, amp_only_var)
            var_comp_raw_bin = bin_struct.(indvar_name{ivar});
            var_comp_bin = var2phys(var_comp_raw_bin,ivar,1);
         end

         % change linestyle according to cloud/rain
         % if israin
            lsty='-';
         % else
         %    lsty='--';
         % end

         nexttile
         hold on
         var1_key = extractBefore(var1_str{ivar1},digitsPattern);
         var2_key = extractBefore(var2_str{ivar2},digitsPattern);
         var1_symb = initVarSymb_dict(var1_key);
         var1_val = extractAfter(var1_str{ivar1},lettersPattern);
         var1_units = initVarUnit_dict(var1_key);
         var1_titl = [var1_symb ' = ' var1_val ' ' var1_units(3:end-1)];
         var2_symb = initVarSymb_dict(var2_key);
         var2_val = extractAfter(var2_str{ivar2},lettersPattern);
         var2_units = initVarUnit_dict(var2_key);
         var2_titl = [var2_symb ' = ' var2_val ' ' var2_units(3:end-1)];

         title(['(',char(ifig+96), ') ', var1_titl ', ' var2_titl],'fontweight','normal')
         plot(time, var_comp_amp4m, 'linewidth', 2, 'linestyle', lsty, 'color', color_order{1})
         plot(time, var_comp_bin, 'linewidth', 2, 'linestyle', lsty, 'color', color_order{2})
         plot(time, var_comp_amp2m, 'linewidth', 1, 'linestyle', lsty, 'color', color_order{4})
         plot(time, var_comp_amp3m, 'linewidth', 1, 'linestyle', lsty, 'color', color_order{5})
         ylabel([indvar_ename{ivar} indvar_units{ivar}])

         xlim([0 max(time)])

         xlabel(tl,'Time [s]')
         legend('U-AMP','BIN','S-AMP (2M)','S-AMP (3M)','Location','best')
         grid
         hold off
         ifig = ifig + 1;
      end
   end
end

title(tl, 'U-AMP vs. S-AMP surface precipitation rate (Full MP)','fontweight','bold')
exportgraphics(gcf, ['plots/2m 3m 4m mean precip comparison (',bintype{its},').png'], 'Resolution', 300)
