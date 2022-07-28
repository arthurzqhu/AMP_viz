clear
close all

textclr = '#F6F4EC';
textclr_rgb = num2str(hex2rgb(textclr));
tilebg_color = '#3E475E';
figbg_color = '#606F92';
% shade_color = '#687799';
shade_color_rgb = [.8 .8 .8];
wrapper_color = {'#16E8CF', '#FBE232'};

gnuc=4;

rxc=1e-3;
nxc=300e6;
dnc=(rxc*6./pi/1000./nxc*gamma(gnuc)/gamma(gnuc+3)).^(1/3);

nkr=50;
nkr_smot=200;
dmin=1e-8;
dmax=1e-4;

diams=linspace(dmin,dmax,nkr);
diams_smot=linspace(dmin,dmax,nkr_smot);

n0c=rxc/gamma(gnuc+3);

fig_mat = openfig('Fig1.fig');
axObjs = fig_mat.Children;
dataObjs(1) = axObjs(1).Children;
dataObjs(2) = axObjs(2).Children;

diams=dataObjs(1).XData(1:2:end);
diams_smot=dataObjs(2).XData(1:50:end);

ffcd_pert=dataObjs(1).YData(1:2:end);
ffcd_smot=dataObjs(2).YData(1:50:end);
ffcd=ffcd_smot(1:4:end);

set(gcf,'visible','off')
%%

figure('Position',[0 0 1345 860])
% grid

annotation('arrow',[.2729 .3019],[.4711 .3767],'LineWidth',4,...
   'HeadWidth',20,'HeadLength',20)
annotation('arrow',[0.47 .57],[0.334 .334],'LineWidth',4,...
   'HeadWidth',20,'HeadLength',20)
annotation('arrow',[.74 .769],[.3767 .4711],'LineWidth',4,...
   'HeadWidth',20,'HeadLength',20)
annotation('arrow',[.715 .61],[.6688 .7151],'LineWidth',4,...
   'HeadWidth',20,'HeadLength',20)
annotation('arrow',[.42 .315],[.7151 .6688],'LineWidth',4,...
   'HeadWidth',20,'HeadLength',20)
annotation('textbox',[.17 .38 .1 .1], 'String','2. discretize',...
   'fontsize',24,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center', ...
   'Color',textclr)
annotation('textbox',[.465 .32 .1 .1], 'String','3. microphysics',...
   'fontsize',24,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center', ...
   'Color',textclr)
annotation('textbox',[.82 .36 0 .1], 'String','4. diagnose moments',...
   'fontsize',24,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center', ...
   'Color',textclr)
annotation('textbox',[.64 .72 .1 .1], 'String','5. dynamics',...
   'fontsize',24,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center', ...
   'Color',textclr)
annotation('textbox',[.64 .685 .1 .1], 'String','adv, div, etc.',...
   'fontsize',18,'EdgeColor','none',...
   'VerticalAlignment','middle','HorizontalAlignment','center', ...
   'Color',textclr)
annotation('textbox',[.27 .72 .1 .1], 'String','1. convert to bulk',...
   'fontsize',24,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center', ...
   'Color',textclr)
annotation('textbox',[.27 .685 .1 .1], 'String','while conserving moments',...
   'fontsize',18,'EdgeColor','none',...
   'VerticalAlignment','middle','HorizontalAlignment','center', ...
   'Color',textclr)
annotation('textbox',[.465 .465 .1 .1], 'String',...
   '$$M_k=\int_0^\infty n(D)D^kdD$$',...
   'Interpreter','latex',...
   'fontsize',32,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center', ...
   'Color',textclr)

annotation('textbox',[0.442, 0.686, .15, .15],...
   'String',"E.g., $$M_3', M_0', M_6'$$",...
   'Interpreter','latex',...
   'FontSize',36,...
   'HorizontalAlignment','center',...
   'VerticalAlignment','middle',...
   'LineWidth',2,'color',textclr,...
   'BackgroundColor',tilebg_color)

annotation('textbox',[.688, 0.5, .15, .15],...
   'String',"E.g., $$M_3, M_0, M_6$$",...
   'Interpreter','latex',...
   'FontSize',36,...
   'HorizontalAlignment','center',...
   'VerticalAlignment','middle',...
   'LineWidth',2,'color',textclr,...
   'BackgroundColor',tilebg_color)

set(gca,'XColor','none')
set(gca,'YColor','none')
set(gca,'Color',figbg_color)

hold on
axes('Position',[.2 .5 .15 .15])
plot(diams_smot,ffcd_smot,'LineWidth',2,'color',wrapper_color{1})
ylim([0 0.5])
grid
set(gca,'YColor','none')
set(gca,'XColor','none')
set(gca,'color',tilebg_color)

axes('Position',[.3 .2 .15 .15])
bar(ffcd,1,'facecolor',wrapper_color{2})
ylim([0 0.5])
grid
set(gca,'YColor','none')
set(gca,'XColor','none')
set(gca,'color',tilebg_color)

axes('Position',[.6 .2 .15 .15])
bar(ffcd_pert,1,'facecolor',wrapper_color{2})
ylim([0 0.5])
grid
set(gca,'YColor','none')
set(gca,'XColor','none')
set(gca,'color',tilebg_color)

hold off

exportgraphics(gcf,['plots/cmmplots/amp_mech_cmm.png'],'Resolution',300,'BackgroundColor',figbg_color)