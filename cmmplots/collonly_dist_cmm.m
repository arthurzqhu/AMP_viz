clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str 

textclr = '#F6F4EC';
tilebg_color = '#66789F';
figbg_color = '#7F96C5';
% shade_color = '#687799';
shade_color_rgb = [.8 .8 .8];
textclr_rgb = num2str(hex2rgb(textclr));
wrapper_color = {'#16E8CF', '#FBE232'};


vnum='0001'; % last four characters of the model output file.
nikki='orig_thres';
global_var
mconfig = 'collonly';
case_dep_var

figure('Position',[1000 491 1000 486])
tl=tiledlayout(2,2,'TileSpacing','compact');

ivar1 = 3;
ivar2 = length(var2_str);

%% read files
for its = 1:length(bintype)
   if its==2
      binmean = load('diamg_sbm.txt')*1e6;
      nkr=33;
      krdrop=14;
   elseif its==1
      binmean = load('diamg_tau.txt')*1e6;
      nkr=34;
      krdrop=15;
   end

   amp_struct = loadnc('amp');
   bin_struct = loadnc('bin');
   
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
   xx=binmean(10:krdrop+4)';
   yy1=amp_dist_t1(10:krdrop+4);
   yy2=amp_dist_t2(10:krdrop+4);
   pt=patch([xx fliplr(xx)], [yy1 fliplr(yy2)], shade_color_rgb,'edgecolor','none');
   set(get(get(pt,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
   plot(binmean,amp_dist_t1,'Color',wrapper_color{1},'LineWidth',2)
   plot(binmean,amp_dist_t2,'Color',wrapper_color{1},...
      'LineWidth',2,'LineStyle','--')
   plot(binmean,amp_dist_t3,'Color',wrapper_color{1},...
      'LineWidth',2,'LineStyle',':')
   hold off

   title(sprintf('\\color[rgb]{%s}AMP\\color[rgb]{%s}-\\color[rgb]{%s}%s',...
      num2str(hex2rgb(wrapper_color{1})), textclr_rgb, ...
      num2str(color_order{its}), upper(bintype{its})))
   lg=legend('t = 0 min','t = 6 min','t = 12 min',...
      'Location','northeast','AutoUpdate','off');
   lg.FontWeight='bold';
   lg.Color = tilebg_color;
   lg.TextColor = textclr;
   lg.EdgeColor = textclr;
   xline(binmean(krdrop),'linestyle','--','linewidth',3,'color',color_order{7})

   xlim([binmean(1) 500])
   ylim([1e-5 3e-3])
   set(gca,'YScale','log')
   set(gca,'XScale','log')
   set(gca,'fontsize',16)
   grid

   set(gca,'Color',tilebg_color)
   set(gca,'XColor',textclr)
   set(gca,'YColor',textclr)

   
   nexttile(2+its)
   hold on
   %shaded region
   xx=binmean(10:krdrop+4)';
   yy1=bin_dist_t1(10:krdrop+4);
   yy2=bin_dist_t2(10:krdrop+4);
   pt=patch([xx fliplr(xx)], [yy1 fliplr(yy2)], shade_color_rgb,'edgecolor','none');
   set(get(get(pt,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
   plot(binmean,bin_dist_t1,'Color',wrapper_color{2},'LineWidth',2)
   plot(binmean,bin_dist_t2,'Color',wrapper_color{2},...
      'LineWidth',2,'LineStyle','--')
   plot(binmean,bin_dist_t3,'Color',wrapper_color{2},...
      'LineWidth',2,'LineStyle',':')
   
   xlim([binmean(1) 500])
   ylim([1e-5 3e-3])
   set(gca,'YScale','log')
   set(gca,'XScale','log')
   hold off
   
   title(sprintf('\\color[rgb]{%s}bin\\color[rgb]{%s}-\\color[rgb]{%s}%s',...
      num2str(hex2rgb(wrapper_color{2})), textclr_rgb, ...
      num2str(color_order{its}), upper(bintype{its})))
   lg=legend('t = 0 min','t = 6 min','t = 12 min',...
      'Location','northeast','AutoUpdate','off');
   lg.FontWeight='bold';
   lg.Color = tilebg_color;
   lg.TextColor = textclr;
   lg.EdgeColor = textclr;
   xline(binmean(krdrop),'--','linewidth',3,'color',color_order{7})

   xlabel(tl,'Diameter [\mum]','fontsize',18,'color',textclr)
   ylabel(tl,'Mass conc. [kg/kg/dlogD]','fontsize',18,'color',textclr)
   set(gca,'fontsize',16)
   grid

   set(gca,'Color',tilebg_color)
   set(gca,'XColor',textclr)
   set(gca,'YColor',textclr)

end

annotation('line',[0.485 0.485], [0.125 0.927], 'color',[.5 .5 .5 .8], 'linewidth', 1,'linestyle',':')
exportgraphics(gcf,['plots/cmmplots/collonly_dist_cmm.png'],'Resolution',300,'BackgroundColor',figbg_color)
