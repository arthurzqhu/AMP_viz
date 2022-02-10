clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2022-01-25';

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

bg_color='#66789F';
light_color='#E7E6E6';
%amp_color='#15E8CF';
%bin_color='#FBE232';
amp_color=color_order{3};
bin_color=color_order{4};
%%
for iconf = 1%length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   run case_dep_var.m
   %% read files
   
   for its = length(bintype)
      
      if its==2
         binmean = load('diamg_sbm.txt');
         nkr=33;
         krdrop=14;
      elseif its==1
         binmean = load('diamg_tau.txt');
         nkr=34;
         krdrop=15;
      end
      
      for ivar1 = length(var1_str)
         for ivar2 = length(var2_str)
            
            [~, ~, ~, ~, amp_struct]=...
               loadnc('amp');
            [~, ~, ~, ~, bin_struct]=...
               loadnc('bin');
            
            %%
            time=amp_struct.time;
            dt=time(2)-time(1);
            t1=int8(1/dt);
            t2=int8(10/dt);
            t3=int8(30/dt);
            
            bin_dist_t1=bin_struct.mass_dist(t1,1:nkr,48);
            amp_dist_t1=amp_struct.mass_dist_init(t1+1,1:nkr,48);
            
            bin_dist_t2=bin_struct.mass_dist(t2,1:nkr,48);
            amp_dist_t2=amp_struct.mass_dist_init(t2+1,1:nkr,48);
            
            bin_dist_t3=bin_struct.mass_dist(t3,1:nkr,48);
            amp_dist_t3=amp_struct.mass_dist_init(t3+1,1:nkr,48);
            
            figure('Position',[1000 491 640 486])
            tl=tiledlayout('flow','TileSpacing','compact');
            nexttile
            hold on

            plot(binmean,amp_dist_t1,'Color',amp_color,'LineWidth',2)
            plot(binmean,amp_dist_t2,'Color',amp_color,...
               'LineWidth',2,'LineStyle','--')
            plot(binmean,amp_dist_t3,'Color',amp_color,...
               'LineWidth',2,'LineStyle',':')
            hold off
            
            title('AMP-SBM')
            l=legend('t=1s','t=10s','t=30s',...
               'Location','best');
            l.FontWeight='bold';
            
            xlim([binmean(1) binmean(krdrop)])
            set(gca,'YScale','log')
            set(gca,'fontsize',16)
            grid
            
            nexttile
            hold on
            plot(binmean,bin_dist_t1,'Color',bin_color,'LineWidth',2)
            plot(binmean,bin_dist_t2,'Color',bin_color,...
               'LineWidth',2,'LineStyle','--')
            plot(binmean,bin_dist_t3,'Color',bin_color,...
               'LineWidth',2,'LineStyle',':')
            
            xlim([binmean(1) binmean(krdrop)])
            set(gca,'YScale','log')
            hold off
            
            title('bin-SBM')
            l=legend('t=1s','t=10s','t=30s',...
               'Location','best');
            l.FontWeight='bold';

            xlabel(tl,'Diameter [\mum]','fontsize',18)
            ylabel(tl,'Mass concentration [kg/kg/dlogD]','fontsize',18)
            set(gca,'fontsize',16)
            grid
            exportgraphics(gcf,['plots/p1/fig' num2str(9) 'test.jpg'],'Resolution',300)
         end
      end
   end
end
