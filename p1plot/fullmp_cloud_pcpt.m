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
get_var_comp([3:7 10])

load(['pfm_summary/' nikki '_' mconfig '_pfm.mat'])
case_dep_var

tmpvarname=fieldnames(pfm(1));
fldnms=fieldnames(pfm(1).(tmpvarname{1}).(bintype{1}));
fldnms=fldnms(1:end-1);

plot_var={'liq_M1_path','cloud_M1_path','mean_surface_ppt'};

figure('position',[0 0 1250 1170])
tl=tiledlayout(10,4);

ifig = 0;
for ipvar=1:length(plot_var)
alb_idx=find(contains(indvar_name_set,plot_var{ipvar}));
ivar=alb_idx;
ifn=1;

if ipvar == 1
   title(tl,['Full microphysics - ' indvar_ename_set{ivar} indvar_units_set{ivar} ...
      ],'fontsize',20,'fontweight','bold')
elseif ipvar == 2
   annotation('textbox',[.2 .5 .6 .2], 'string', ...
      ['Full microphysics - ' indvar_ename_set{ivar} indvar_units_set{ivar}], ...
      'fontsize',20,'fontweight','bold',...
      'HorizontalAlignment','center','VerticalAlignment','middle',...
      'edgecolor','none')
elseif ipvar == 3
   annotation('textbox',[.2 .21 .6 .2], 'string', ...
      ['Full microphysics - ' indvar_ename_set{ivar} indvar_units_set{ivar}], ...
      'fontsize',20,'fontweight','bold',...
      'HorizontalAlignment','center','VerticalAlignment','middle',...
      'edgecolor','none')
end

for its=1:length(bintype)
   ifig = ifig + 1;
   nexttile((ipvar-1)*12+its*2+3,[3 2])
   nanimagesc(pfm.(indvar_name_set{ivar}).(bintype{its}).(fldnms{ifn}))

   cb=colorbar;
   if its==length(bintype)
      cb.Label.String='AMP/bin ratio'; 
   end

   title(['(',char(ifig+96),') ',upper(bintype{its})],'FontWeight','normal')
   xticks(1:length(var2_str))
   yticks(1:length(var1_str))
   xticklabels(extractAfter(var2_str,lettersPattern))
   yticklabels(extractAfter(var1_str,lettersPattern))
   set(gca,'FontSize',16)

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

         text(ivar2+0.015,ivar1-0.015,mpath_bin_str{ivar1,ivar2},'FontSize',15,...
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
xlabel(tl,xlab,'fontsize',20)
ylabel(tl,ylab,'fontsize',20)
end

exportgraphics(gcf,['plots/p1/fullmp_grid.png'],'Resolution',300)
