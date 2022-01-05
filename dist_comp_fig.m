clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-11-23';

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

bg_color='#66789F';
light_color='#E7E6E6';
amp_color='#15E8CF';
bin_color='#FBE232';
%%
for iconf = length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   run case_dep_var.m
   %% read files
   
   for its = length(bintype)
      
      if its==2
         binmean = load('diamg_sbm.txt');
         nkr=33;
      elseif its==1
         binmean = load('diamg_tau.txt');
         nkr=34;
      end
      
      for ivar1 = 1:length(var1_str)
         for ivar2 = 1:length(var2_str)
            
            [~, ~, ~, ~, amp_struct]=...
               loadnc('amp');
            [~, ~, ~, ~, bin_struct]=...
               loadnc('bin');
            
            %%
            t1=580;
            t2=950;
            t3=1200;
            
            bin_dist_t1=bin_struct.mass_dist(t1,1:nkr,55);
            amp_dist_t1=amp_struct.mass_dist_init(t1,1:nkr,55);
            
            bin_dist_t2=bin_struct.mass_dist(t2,1:nkr,55);
            amp_dist_t2=amp_struct.mass_dist_init(t2,1:nkr,55);
            
            bin_dist_t3=bin_struct.mass_dist(t3,1:nkr,55);
            amp_dist_t3=amp_struct.mass_dist_init(t3,1:nkr,55);
            
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
            
            title('AMP (Cond. Coll.)','Color',light_color)
            l=legend('t=580s','t=950s','t=1200s',...
               'Location','north');
            l.TextColor=light_color;
            l.FontWeight='bold';
            l.Color=bg_color;
            l.EdgeColor=light_color;
            
            xlim([min(binmean) max(binmean)])
            ylim([1e-5 0.02])
            set(gca,'XScale','log')
            set(gca,'YScale','log')
            set(gca,'XColor',light_color)
            set(gca,'YColor',light_color)
            set(gca,'Color',bg_color)
            set(gca,'fontsize',16)
            grid
            
            nexttile
            hold on
            plot(binmean,bin_dist_t1,'Color',bin_color,'LineWidth',2)
            plot(binmean,bin_dist_t2,'Color',bin_color,...
               'LineWidth',2,'LineStyle','--')
            plot(binmean,bin_dist_t3,'Color',bin_color,...
               'LineWidth',2,'LineStyle',':')
            
            xlim([min(binmean) max(binmean)])
            ylim([1e-5 0.02])
            set(gca,'XScale','log')
            set(gca,'YScale','log')
            hold off
            
            set(gca,'XColor',light_color)
            set(gca,'YColor',light_color)
            title('bin','Color',light_color)
            l=legend('t=580s','t=950s','t=1200s',...
               'Location','north');
            l.Color=bg_color;
            l.FontWeight='bold';
            l.TextColor=light_color;
            l.EdgeColor=light_color;

            xlabel(tl,'Diameter [\mum]','color',light_color,'fontsize',18)
            ylabel(tl,'Mass concentration [kg/kg/dlogD]','color',light_color,'fontsize',18)
            set(gca,'Color',bg_color)
            set(gca,'fontsize',16)
            grid
         end
      end
   end
end