clear
close all

colororder=colororder;
color_order={};
for i=1:size(colororder,1)
    color_order{i}=colororder(i,:);
end
rng(2)

gnuc=4;


rxc=1e-3;
nxc=300e6;
dnc=(rxc*6./pi/1000./nxc*gamma(gnuc)/gamma(gnuc+3)).^(1/3);

nkr=50;
nkr_smooth=200;
dmin=3e-6;
dmax=3e-3;

diams=logspace(log10(dmin),log10(dmax),nkr);
diams_gamm=logspace(log10(dmin),log10(dmax),nkr_smooth);
n0c=rxc/gamma(gnuc+3);


for kr=1:nkr_smooth
   exptermc=exp(-1*diams_gamm(kr)/dnc);
   dist_gammc(kr)=n0c*exptermc*(diams_gamm(kr)/dnc)^(gnuc+3);
end

rxr=.3e-3;
nxr=.03e6;
dnr=(rxr*6./pi/1000./nxr*gamma(gnuc)/gamma(gnuc+3)).^(1/3);
n0r=rxr/gamma(gnuc+3);

for kr=1:nkr_smooth
   exptermr=exp(-1*diams_gamm(kr)/dnr);
   dist_gammr(kr)=n0r*exptermr*(diams_gamm(kr)/dnr)^(gnuc+3);
end

dist_gamm = dist_gammc + dist_gammr;

dist_dicr=dist_gamm(1:4:end);
dist_after = dist_dicr.*(1+(rand(nkr,1)'-.5)*.7);

%%




hf=figure('Position',[0 0 1345 860]);
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
   'VerticalAlignment','middle','HorizontalAlignment','center')
annotation('textbox',[.465 .32 .1 .1], 'String','3. microphysics',...
   'fontsize',24,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center')
annotation('textbox',[.82 .36 0 .1], 'String','4. diagnose moments',...
   'fontsize',24,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center')
annotation('textbox',[.66 .72 .1 .1], 'String','5. non-MP processes',...
   'fontsize',24,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center')
annotation('textbox',[.66 .685 .1 .1], 'String','adv, div, etc.',...
   'fontsize',18,'EdgeColor','none',...
   'VerticalAlignment','middle','HorizontalAlignment','center')
annotation('textbox',[.27 .72 .1 .1], 'String','1. convert to bulk',...
   'fontsize',24,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center')
annotation('textbox',[.27 .685 .1 .1], 'String','while conserving moments',...
   'fontsize',18,'EdgeColor','none',...
   'VerticalAlignment','middle','HorizontalAlignment','center')
annotation('textbox',[.465 .465 .1 .1], 'String',...
   '$$M_k=\sum_{D_{min}}^{D_{max}} N(D)D^kdlogD$$',...
   'Interpreter','latex',...
   'fontsize',32,'EdgeColor','none','FontWeight','bold',...
   'VerticalAlignment','middle','HorizontalAlignment','center')

annotation('textbox',[0.442, 0.686, .15, .15],...
   'String',"$$M_3', M_0'$$ $$(M_x', M_y')$$",...
   'Interpreter','latex',...
   'FontSize',36,...
   'HorizontalAlignment','center',...
   'VerticalAlignment','middle',...
   'LineWidth',2,'BackgroundColor','w')

annotation('textbox',[.688, 0.5, .15, .15],...
   'String',"$$M_3, M_0$$ $$(M_x, M_y)$$",...
   'Interpreter','latex',...
   'FontSize',36,...
   'HorizontalAlignment','center',...
   'VerticalAlignment','middle',...
   'LineWidth',2,'BackgroundColor','w')

set(gca,'YColor','none')
set(gca,'XColor','none')
% set(gca,'Color',figbg_color)

hold on
axes('Position',[.2 .5 .15 .15])
plot(1:97,dist_gamm(1:97),'LineWidth',2); hold on
plot(97:nkr_smooth,dist_gamm(97:end),'LineWidth',2,'Color',color_order{2}); hold off
grid
% set(gca,'Color',tilebg_color)

set(gca,'YColor','none')
set(gca,'XColor','none')

axes('Position',[.3 .2 .15 .15])
bar(1:25,dist_dicr(1:25),1); hold on
bar(25:nkr,dist_dicr(25:nkr),1,'FaceColor',color_order{2}); hold off
% xlim([dmin dmax])
% ylim([0 0.5])
grid
% set(gca,'Color',tilebg_color)
set(gca,'YColor','none')
set(gca,'XColor','none')

axes('Position',[.6 .2 .15 .15])
bar(1:25,dist_after(1:25),1); hold on
bar(25:nkr,dist_after(25:nkr),1,'FaceColor',color_order{2}); hold off
grid
% set(gca,'Color',tilebg_color)
set(gca,'YColor','none')
set(gca,'XColor','none')



hold off

exportgraphics(gcf,'plots/p2/f01_uamp_mech.pdf')
saveas(gcf,'plots/p2/f01_uamp_mech.fig')
