clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str 

vnum='0001'; % last four characters of the model output file.
nikki='smaller_threshold';
run global_var.m
mconfig = 'collonly';
run case_dep_var.m

figure('Position',[1000 491 1000 486])
tl=tiledlayout(2,2,'TileSpacing','compact');
%% read files
for its = 1:length(bintype)
   if its==2
      binmean = load('diamg_sbm.txt');
      nkr=33;
      krdrop=12;
   elseif its==1
      binmean = load('diamg_tau.txt');
      nkr=34;
      krdrop=13;
   end
   
   for ivar1 = 2%length(var1_str)
      for ivar2 = length(var2_str)
         
         [~, ~, ~, ~, amp_struct]=...
            loadnc('amp',{'mass_dist_init'});
         [~, ~, ~, ~, bin_struct]=...
            loadnc('bin',{'mass_dist'});
         
         %%
         time=amp_struct.time;
         dt=time(2)-time(1);
         t1=int32(1/dt);
         t2=int32(360/dt);
         t3=int32(720/dt);
         
         bin_dist_t1=bin_struct.mass_dist(t1,1:nkr,24);
         amp_dist_t1=amp_struct.mass_dist_init(t1+1,1:nkr,24);
         
         bin_dist_t2=bin_struct.mass_dist(t2,1:nkr,24);
         amp_dist_t2=amp_struct.mass_dist_init(t2+1,1:nkr,24);
         
         bin_dist_t3=bin_struct.mass_dist(t3,1:nkr,24);
         amp_dist_t3=amp_struct.mass_dist_init(t3+1,1:nkr,24);
         
         nexttile
         hold on

         %shaded region
         xx=binmean(10:krdrop+5)';
         yy1=amp_dist_t1(10:krdrop+5);
         yy2=amp_dist_t2(10:krdrop+5);
         pt=patch([xx fliplr(xx)], [yy1 fliplr(yy2)], [.8 .8 .8],'edgecolor','none');
         set(get(get(pt,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
         plot(binmean,amp_dist_t1,'Color',color_order{5-its},'LineWidth',2)
         plot(binmean,amp_dist_t2,'Color',color_order{5-its},...
            'LineWidth',2,'LineStyle','--')
         plot(binmean,amp_dist_t3,'Color',color_order{5-its},...
            'LineWidth',2,'LineStyle',':')
         hold off

         title(['AMP-' upper(bintype{its})])
         lg=legend('t = 1 min','t = 6 min','t = 12 min',...
            'Location','northeast','AutoUpdate','off');
         lg.FontWeight='bold';
         xline(binmean(krdrop),'linestyle','--','linewidth',3,'color',[color_order{7} 0.2])

         xlim([binmean(1) 5e-4])
         ylim([1e-5 3e-3])
         set(gca,'YScale','log')
         set(gca,'XScale','log')
         set(gca,'fontsize',16)
         grid
         
         nexttile(2+its)
         hold on
         %shaded region
         xx=binmean(10:krdrop+5)';
         yy1=bin_dist_t1(10:krdrop+5);
         yy2=bin_dist_t2(10:krdrop+5);
         pt=patch([xx fliplr(xx)], [yy1 fliplr(yy2)], [.8 .8 .8],'edgecolor','none');
         set(get(get(pt,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
         plot(binmean,bin_dist_t1,'Color',color_order{its},'LineWidth',2)
         plot(binmean,bin_dist_t2,'Color',color_order{its},...
            'LineWidth',2,'LineStyle','--')
         plot(binmean,bin_dist_t3,'Color',color_order{its},...
            'LineWidth',2,'LineStyle',':')
         
         xlim([binmean(1) 5e-4])
         ylim([1e-5 3e-3])
         set(gca,'YScale','log')
         set(gca,'XScale','log')
         hold off
         
         title(['bin-' upper(bintype{its})])
         lg=legend('t = 0 min','t = 6 min','t = 12 min',...
            'Location','northeast','AutoUpdate','off');
         lg.FontWeight='bold';
         xline(binmean(krdrop),'--','linewidth',3,'color',[color_order{7} 0.2])

         xlabel(tl,'Diameter [\mum]','fontsize',18)
         ylabel(tl,'Mass concentration [kg/kg/dlogD]','fontsize',18)
         set(gca,'fontsize',16)
         grid
      end
   end
end

annotation('line',[0.485 0.485], [0.125 0.927], 'color',[.5 .5 .5 .8], 'linewidth', 1,'linestyle',':')
exportgraphics(gcf,['plots/p1/collonly_dist_lowerthres.jpg'],'Resolution',300)
