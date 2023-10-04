clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype indvar_name indvar_name_set indvar_ename indvar_ename_set ...
   indvar_units indvar_units_set

vnum='0001'; % last four characters of the model output file.
nikki='Dt80';
global_var

mconfig='fullmic';
get_var_comp([3:7 10])

load(sprintf('pfm_summary/%s_%s_pfm.mat',nikki,mconfig))
var1_str = pfm.misc.var1_str;
var2_str = pfm.misc.var2_str;

tmpvarname=fieldnames(pfm(1));
fldnms=fieldnames(pfm(1).(tmpvarname{1}).(bintype{1}));
fldnms=fldnms(1:end-1);

plot_var={'liq_M1_path','cloud_M1_path','mean_surface_ppt'};

for ipvar=1:length(plot_var)
figure('position',[0 0 800 300])
tl=tiledlayout(4,4);
ifig = 0;
alb_idx=find(contains(indvar_name_set,plot_var{ipvar}));
ivar=alb_idx;
ifn=1;

title(tl, ['Full microphysics - ' indvar_ename_set{ivar} indvar_units_set{ivar}], ...
   'fontsize',18,'fontweight','bold')

for its=1:length(bintype)
   ifig = ifig + 1;
   nexttile(its*2+3,[3 2])
   nanimagesc(pfm.(indvar_name_set{ivar}).(bintype{its}).(fldnms{ifn}))

   cb=colorbar;
   if its==length(bintype)
      cb.Label.String='AMP/bin ratio'; 
   end

   title(['(',char(ifig+96),') ',upper(bintype{its})],'FontWeight','normal','FontSize',11)
   xticks(1:length(var2_str))
   yticks(1:length(var1_str))
   xticklabels(extractAfter(var2_str,lettersPattern))
   yticklabels(extractAfter(var1_str,lettersPattern))
   set(gca,'FontSize',11)

   colormap(cmaps.BrBG)
   set(gca,'ColorScale','log')
   caxis([.5 2])

   mpath=pfm.(indvar_name_set{ivar}).(bintype{its}).mpath_bin;
   [XX,YY]=meshgrid(1:length(var2_str),1:length(var1_str));
   mpath_bin_str=sprintfc('%0.3g',mpath);

   for ivar1=1:length(var1_str)
      for ivar2=1:length(var2_str)
         % ----- get text color -----
         ngrads=size(cmaps.coolwarm_r,1);
         clr_idx=roundfrac(pfm.(indvar_name_set{ivar}).(bintype{its}).rsq(ivar1,ivar2),1/ngrads)*ngrads;
         clr_idx=round(clr_idx); % in case prev line outputs double
         % ----- got text color -----
         if isnan(clr_idx) 
            continue
         end
         if clr_idx==0 
            clr_idx=1; 
         end

         text(ivar2+0.02,ivar1-0.02,mpath_bin_str{ivar1,ivar2},'FontSize',11,...
            'HorizontalAlignment','center',...
            'Color',cmaps.coolwarm_r(clr_idx,:)*.1)
         text(ivar2,ivar1,mpath_bin_str{ivar1,ivar2},'FontSize',11,...
            'HorizontalAlignment','center',...
            'Color',cmaps.coolwarm_r(clr_idx,:))
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
   set(gca,'FontSize',11)

   xlab_key=extractBefore(var2_str,digitsPattern);
   ylab_key=extractBefore(var1_str,digitsPattern);
   xlab=[initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
   ylab=[initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
   xlabel(tl,xlab,'fontsize',18)
   ylabel(tl,ylab,'fontsize',18)

   % exportgraphics(gcf,['plots/5 fullmp_grid ',indvar_ename_set{ivar},'.pdf'])
   saveas(gcf,['plots/5 fullmp_grid ',indvar_ename_set{ivar},'.fig'])

end

end

% exportgraphics(gcf,'plots/5 fullmp_grid.png','Resolution',300)
