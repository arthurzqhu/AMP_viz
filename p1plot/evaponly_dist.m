clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2022-06-15';
global_var
mconfig = 'evaponly';
get_var_comp
case_dep_var

figure('Position',[1000 491 1000 280])
tl=tiledlayout(1,2,'TileSpacing','compact');
%% read files
for its = length(bintype)
   if its==2
      binmean = load('diamg_sbm.txt')*1e6;
      nkr=33;
      krdrop=14;
   elseif its==1
      binmean = load('diamg_tau.txt')*1e6;
      nkr=34;
      krdrop=15;
   end

   for ivar1 = length(var1_str)
      for ivar2 = length(var2_str)

         amp_struct = loadnc('amp');
         bin_struct = loadnc('bin');

         %%
         time=amp_struct.time;
         dt=time(2)-time(1);
         t1=int32(1/dt);
         t2=int32(10/dt);
         t3=int32(20/dt);

         bin_dist_t1=bin_struct.mass_dist(t1,1:nkr,24);
         amp_dist_t1=amp_struct.mass_dist_init(t1+1,1:nkr,24);

         bin_dist_t2=bin_struct.mass_dist(t2,1:nkr,24);
         amp_dist_t2=amp_struct.mass_dist_init(t2+1,1:nkr,24);

         bin_dist_t3=bin_struct.mass_dist(t3,1:nkr,24);
         amp_dist_t3=amp_struct.mass_dist_init(t3+1,1:nkr,24);

         nexttile
         hold on

         %shaded region
         xx=binmean((15-its):krdrop)';
         yy1=amp_dist_t1((15-its):krdrop);
         yy2=amp_dist_t3((15-its):krdrop);
         pt=patch([xx fliplr(xx)], [yy1 fliplr(yy2)], [.8 .8 .8],'edgecolor','none');
         set(get(get(pt,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

         plot(binmean,amp_dist_t1,'Color',color_order{5-its},'LineWidth',2)
         plot(binmean,amp_dist_t2,'Color',color_order{5-its},...
            'LineWidth',2,'LineStyle','--')
         plot(binmean,amp_dist_t3,'Color',color_order{5-its},...
            'LineWidth',2,'LineStyle',':')
         hold off

         title(['AMP-' upper(bintype{its})])
         l = legend('t = 1 s','t = 10 s','t = 20 s',...
            'Location','best');
         l.FontWeight='bold';
         rectangle('position',[binmean(15-its),amp_dist_t1(krdrop)/1.2,binmean(krdrop)-binmean(15-its),amp_dist_t1(15-its)*1.2],'facecolor',[0.1 0.1 0.1 0.1])

         xlim([0 binmean(krdrop)])
         ylim([1e-8 1e-3])
         set(gca,'YScale','log')
         set(gca,'fontsize',16)
         grid

         nexttile
         hold on
         %shaded region
         xx=binmean((15-its):krdrop)';
         yy1=bin_dist_t1((15-its):krdrop);
         yy2=bin_dist_t3((15-its):krdrop);
         pt=patch([xx fliplr(xx)], [yy1 fliplr(yy2)], [.8 .8 .8],'edgecolor','none');
         set(get(get(pt,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
         plot(binmean,bin_dist_t1,'Color',color_order{its},'LineWidth',2)
         plot(binmean,bin_dist_t2,'Color',color_order{its},...
            'LineWidth',2,'LineStyle','--')
         plot(binmean,bin_dist_t3,'Color',color_order{its},...
            'LineWidth',2,'LineStyle',':')

         xlim([0 binmean(krdrop)])
         ylim([1e-8 1e-3])
         set(gca,'YScale','log')
         hold off

         title(['bin-' upper(bintype{its})])
         l = legend('t = 1 s','t = 10 s','t = 20 s',...
            'Location','best');
         l.FontWeight='bold';
         rectangle('position',[binmean(15-its),bin_dist_t3(krdrop)/1.2,binmean(krdrop)-binmean(15-its),bin_dist_t1(15-its)*1.2],'facecolor',[0.1 0.1 0.1 0.1])

         xlabel(tl,'Diameter [\mum]','fontsize',18)
         ylabel(tl,'Mass conc. [kg/kg/dlogD]    ','fontsize',18)
         set(gca,'fontsize',16)
         grid
         exportgraphics(gcf,['plots/p1/evaponly_dist.jpg'],'Resolution',300)
      end
   end
end

% annotation('line',[0.485 0.485], [0.17 0.926], 'color',[.5 .5 .5 .8], 'linewidth', 1,'linestyle',':')
exportgraphics(gcf,['plots/p1/evaponly_dist.png'],'Resolution',300)
% print('plots/p1/evaponly_dist.png','-dpng','-r300')
