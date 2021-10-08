clear
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-10-07';
case_interest=2; % 1:length(case_list_num);

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir=dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags=[mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2)=0; % ignore the current and parent dir
mconfig_ls={mconfig_ls_dir(mconfig_ls_dir_flags).name};

set(0, 'DefaultFigurePosition',[1331 587 1250 390])

%%

% read files
for iconf=1%:length(mconfig_ls)
   mconfig=mconfig_ls{iconf};
   %     mconfig='adv_coll';
   run case_dep_var.m
   for its=length(bintype)
      clear amp_struct bin_struct
      for ivar1=1%:length(var1_str)
         %             close all
         for ivar2=1:length(var2_str)
            [~, ~, ~, ~, ostruct]=...
               loadnc('amp',case_interest);
            amp_struct(ivar2)=ostruct;
            
            [~, ~, ~, ~, ostruct]=...
               loadnc('bin',case_interest);
            bin_struct(ivar2)=ostruct;

         end
      end
      
      
      % plot
      % indices of vars to compare
      vars=1;
      vare=length(indvar_name);
      
      for ivar=vars:vare
         close all
         for ivar2=1:length(var2_str)
            var_comp_raw_amp=amp_struct(ivar2).(indvar_name{ivar});
            var_amp_flt=var2phys(var_comp_raw_amp,ivar,0,0);

            var_comp_raw_bin=bin_struct(ivar2).(indvar_name{ivar});
            var_bin_flt=var2phys(var_comp_raw_bin,ivar,0,0);

            time=amp_struct(ivar2).time;

            figure(1)
            hold on
            plot(time,var_amp_flt,'LineWidth',2,...
               'DisplayName',var2_str{ivar2})
            legend('show')

            figure(2)
            hold on
            plot(time,var_bin_flt,'LineWidth',2,...
               'DisplayName',var2_str{ivar2})
            legend('show')
         end
         
         saveas(figure(1),['plots/dt test/' indvar_ename{ivar} ' amp-' bintype{its} '.png'])
         saveas(figure(2),['plots/dt test/' indvar_ename{ivar} ' bin-' bintype{its} '.png'])
         
         pause(.5)
      end
   end
end