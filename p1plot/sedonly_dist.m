clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str 

vnum='0001'; % last four characters of the model output file.
nikki='2022-06-15';
global_var
mconfig = 'sedonly';
case_dep_var

figure('Position',[1000 491 1000 286])
tl=tiledlayout(1,2,'TileSpacing','compact');
%% read files
for its = 1:length(bintype)
   if its==2
      binmean = load('diamg_sbm.txt')*1e3;
      nkr=33;
      krdrop=14;
   elseif its==1
      binmean = load('diamg_tau.txt')*1e3;
      nkr=34;
      krdrop=15;
   end
   
   for ivar1 = 5%length(var1_str)
      for ivar2 = 2%length(var2_str)
         
         amp_struct = loadnc('amp');
         bin_struct = loadnc('bin');
         
         %%
         time=amp_struct.time;
         dt=time(2)-time(1);
         t1=int32(1/dt);
         t2=int32(60/dt);
         t3=int32(120/dt);
         
         bin_dist_t1=bin_struct.mass_dist(t1,1:nkr,104);
         amp_dist_t1=amp_struct.mass_dist_init(t1+1,1:nkr,104);
         
         bin_dist_t2=bin_struct.mass_dist(t2,1:nkr,104);
         amp_dist_t2=amp_struct.mass_dist_init(t2+1,1:nkr,104);
         
         bin_dist_t3=bin_struct.mass_dist(t3,1:nkr,104);
         amp_dist_t3=amp_struct.mass_dist_init(t3+1,1:nkr,104);
         
         nexttile
         hold on

         %shaded region
         xx=binmean(25:end-1)';
         yy1=amp_dist_t2(25:end-1);
         yy2=bin_dist_t2(25:end-1);
         pt=patch([xx fliplr(xx)], [yy1 fliplr(yy2)], [.8 .8 .8],'edgecolor','none');
         set(get(get(pt,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

         xx=binmean(25:end-1)';
         yy1=amp_dist_t3(25:end-1);
         yy2=bin_dist_t3(25:end-1);
         pt=patch([xx fliplr(xx)], [yy1 fliplr(yy2)], [.8 .8 .8],'edgecolor','none');
         set(get(get(pt,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

         plot(binmean,bin_dist_t1,'Color',color_order{its},'LineWidth',2)
         plot(binmean,bin_dist_t2,'Color',color_order{its},...
            'LineWidth',2,'LineStyle','--')
         plot(binmean,amp_dist_t2,'Color',color_order{5-its},...
            'LineWidth',2,'LineStyle','--')
         plot(binmean,bin_dist_t3,'Color',color_order{its},...
            'LineWidth',2,'LineStyle',':')
         plot(binmean,amp_dist_t3,'Color',color_order{5-its},...
            'LineWidth',2,'LineStyle',':')
         hold off

         title([upper(bintype{its})])
         lg=legend('t = 0 min','t = 1 min (bin)','t = 1 min (AMP)',...
                   't = 2 min (bin)','t = 2 min (AMP)',...
                   'Location','northeast','AutoUpdate','off');
         lg.FontWeight='bold';

         % xlim([binmean(krdrop+1) binmean(end)])
         ylim([1e-10 1e-3])
         set(gca,'YScale','log')
         % set(gca,'XScale','log')
         set(gca,'fontsize',16)
         % set(gca,'XMinorTick','on')
         grid

         xlabel(tl,'Diameter [mm]','fontsize',18)
         ylabel(tl,'Mass conc. [kg/kg/dlogD]','fontsize',18)
         set(gca,'fontsize',16)
      end
   end
end

exportgraphics(gcf,['plots/p1/sedonly_dist.png'],'Resolution',300)
