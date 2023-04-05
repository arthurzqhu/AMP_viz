clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set ispath isproc isprof iscloud ...
   israin indvar_units_set indvar_units amp_only_var %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2022-12-05';

global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir, nikki);
get_var_comp([4 10])

confs = [3 4];
mconfig = mconfig_ls{confs(1)};
disp(mconfig)
case_dep_var

for its = 1
   for ivar1 = 3
      for ivar2 = 1
         mconfig = mconfig_ls{confs(1)}; disp(mconfig)
         bin_struct = loadnc('bin', indvar_name_set);
         amp2m_struct = loadnc('amp', indvar_name_set);

         mconfig = mconfig_ls{confs(2)}; disp(mconfig)
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

            var_comp_raw_amp4m = amp4m_struct.(indvar_name{ivar});
            [var_comp_amp4m, linORlog, range] = var2phys(var_comp_raw_amp4m,ivar,1);

            if ~contains(indvar_name{ivar}, amp_only_var)
               var_comp_raw_bin = bin_struct.(indvar_name{ivar});
               var_comp_bin = var2phys(var_comp_raw_bin,ivar,1);
            end

            % change linestyle according to cloud/rain
            if israin
               lsty=':';
            else
               lsty='-';
            end

            figure
            set(gcf,'position',[0 0 800 400])

            hold on
            plot(time, var_comp_amp4m, 'linewidth', 2, 'linestyle', lsty, 'color', color_order{1})
            plot(time, var_comp_bin, 'linewidth', 2, 'linestyle', lsty, 'color', color_order{2})
            plot(time, var_comp_amp2m, 'linewidth', 1, 'linestyle', lsty, 'color', color_order{4})

            xlim([min(time) max(time)])
            xlabel('Time [s]')

            if israin
               ylabel(['liquid water path' indvar_units{ivar}])
               legend(['uamp-' bintype{its}, ' cloud'],...
                  ['bin-' bintype{its},' cloud'],...
                  ['samp-' bintype{its}, ' cloud'],...
                  ['uamp-' bintype{its}, ' rain'],...
                  ['bin-' bintype{its},' rain'],...
                  ['samp-' bintype{its}, ' rain'],...
                  'Location','best')
            else
               ylabel([indvar_ename{ivar} indvar_units{ivar}])
               legend(['uamp-' bintype{its}],...
                  ['bin-' bintype{its}],...
                  ['samp-' bintype{its}],...
                  'Location','best')
            end

            if israin || (~israin && ~iscloud)
               % save fig when both cloud and rain are plotted or
               % neither is being plotted
               set(gca,'fontsize',16)
               title([mconfig ' ' bintype{its},' ', ...
                  var1_str{ivar1},' ' ...
                  var2_str{ivar2}],...
                  'interpreter', 'none', ...
                  'fontsize',20,...
                  'FontWeight','bold')
               if israin
                  % variable name in file name
                  vnifn='liquid water path'; 
               else
                  vnifn=indvar_ename{ivar};
               end
               hold off
               saveas(gcf,[plot_dir,'/',...
                  vnifn, ' ',...
                  'uAMP vs sAMP-',bintype{its},' ',vnum,' ',...
                  var1_str{ivar1}, ' ', var2_str{ivar2},'.png'])
               close
            end

         end

      end
   end
end

% saveas(gcf,['plots/aguplots/uAMP vs sAMP mean precip comparison.png'])
