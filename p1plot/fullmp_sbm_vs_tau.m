clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='orig_thres';
global_var

mconfig='fullmic';
get_var_comp

load(['pfm_summary/' nikki '_' mconfig '_pfm_bincomp.mat'])
case_dep_var

tmpvarname=fieldnames(pfm(1));
fldnms=fieldnames(pfm(1).(tmpvarname{1}));
fldnms=fldnms(1:end-1);

close all

plot_var={'cloud_M1_path','mean_surface_ppt'};

figure('position',[0 0 1250 750])
tl=tiledlayout(7,4);
for ipvar=1:length(plot_var)
alb_idx=find(contains(indvar_name_set,plot_var{ipvar}));
ivar=alb_idx;
ifn=1;

nexttile(ipvar*2+3,[3 2])
mr=pfm.(indvar_name_set{ivar}).(fldnms{ifn});
nanimagesc(mr)
cb=colorbar;
if ipvar==length(bintype), cb.Label.String='TAU/SBM ratio'; end
title(['(',char(ipvar+96),') ',indvar_ename_set{ivar} indvar_units_set{ivar}],'FontWeight','normal')
xticks(1:length(var2_str))
yticks(1:length(var1_str))
xticklabels(extractAfter(var2_str,lettersPattern))
yticklabels(extractAfter(var1_str,lettersPattern))
set(gca,'FontSize',16)

if strcmp(fldnms{ifn},'mr')
   colormap(cmaps.BrBG)
   set(gca,'ColorScale','log')
   caxis([.5 2])

   mpath=pfm.(indvar_name_set{ivar}).mpath_sbm;
   [XX,YY]=meshgrid(1:length(var2_str),1:length(var1_str));
   mpath_bin_str=sprintfc('%0.3g',mpath);

   for ivar1=1:length(var1_str)
      for ivar2=1:length(var2_str)

         % ----- get text color -----
         ngrads=size(cmaps.coolwarm_r,1);
         clr_idx=roundfrac(pfm.(indvar_name_set{ivar}).rsq(ivar1,ivar2),1/ngrads)*ngrads;
         clr_idx=round(clr_idx); % in case prev line outputs double
         % ----- got text color -----

         if isnan(clr_idx) continue, end
         if clr_idx==0 clr_idx=1; end

         text(ivar2+0.02,ivar1-0.02,mpath_bin_str{ivar1,ivar2},'FontSize',15,...
            'HorizontalAlignment','center',...
            'Color',cmaps.coolwarm_r(clr_idx,:)*.1,'FontName','Menlo')
         text(ivar2,ivar1,mpath_bin_str{ivar1,ivar2},'FontSize',15,...
            'HorizontalAlignment','center',...
            'Color',cmaps.coolwarm_r(clr_idx,:),'FontName','Menlo')


      end
   end

end

nexttile(2,[1,2])
set(gca,'Color','none')
set(gca,'XColor','none')
set(gca,'YColor','none')
colormap(gca,cmaps.coolwarm_r)
cb=colorbar('southoutside');
cb.Label.String='R^2';
cb.Label.Position=[0.5000 3.3 0];
set(gca,'FontSize',16)

xlab_key=extractBefore(var2_str,digitsPattern);
ylab_key=extractBefore(var1_str,digitsPattern);
xlab=[initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
ylab=[initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
xlabel(tl,xlab,'fontsize',16)
ylabel(tl,ylab,'fontsize',16)
end

title(tl,'Full microphysics - TAU vs SBM','fontsize',20,'fontweight','bold')
exportgraphics(gcf,['plots/p1/fullmp_sbm_vs_tau.png'],'Resolution',300)
% print('plots/p1/fullmp_sbm_vs_tau.png','-dpng','-r300')
