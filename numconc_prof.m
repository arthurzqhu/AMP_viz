clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set ispath isproc isprof iscloud ...
   israin indvar_units_set indvar_units%#ok<*NUSED>

vnum = '0001'; % last four characters of the model output file.
nikki = '2022-06-06';

global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir, nikki);

for iconf = 1%:length(mconfig_ls)
   mconfig = mconfig_ls{iconf}
   case_dep_var
   % get_var_comp([1 2 3 4 6 7 10 19])
   get_var_comp([38])

   for its = 1:length(bintype)
      for ivar1 = 3%1:length(var1_str)
         %             close all
         for ivar2 = 3%1:length(var2_str)
            [its ivar1 ivar2]    
            bin_struct = loadnc('bin');
            amp_struct = loadnc('amp');
            % indices of vars to compare
            vars = 1;
            vare = length(indvar_name);
            time = amp_struct.time;
            z = amp_struct.z;
            % assuming all vertical layers have the same
            % thickness
            dz = z(2)-z(1);
            
            for ivar = vars:vare
               
               var_comp_raw_amp = amp_struct.(indvar_name{ivar});
               [var_comp_amp, linORlog, range] = var2phys(var_comp_raw_amp,ivar,1);
            
               var_comp_raw_bin = bin_struct.(indvar_name{ivar});
               var_comp_bin = var2phys(var_comp_raw_bin,ivar,1);
            end

            hold on
            plot(var_comp_amp(end, :), z, 'displayname', ['AMP-' bintype{its}], 'linewidth', 2)
            plot(var_comp_bin(end, :), z, 'displayname', ['BIN-' bintype{its}], 'linewidth', 2)
            hold off
            legend('show','location','best')
         end
      end
   end
end

saveas(gcf,[plot_dir, '/supersat_prof.png'])
