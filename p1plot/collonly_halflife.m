clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='orig_thres';
global_var
get_var_comp([3:7 16])

mconfig='collonly';

load(['pfm_summary/' nikki '_' mconfig '_pfm.mat'])
case_dep_var

tmpvarname=fieldnames(pfm(1));
fldnms=fieldnames(pfm(1).(tmpvarname{1}).(bintype{1}));
fldnms=fldnms(1:end-1);

close all

plot_var={'half_life_c'};

for ipvar=1:length(plot_var)
figure('position',[1331 587 1250 300])
alb_idx=find(contains(indvar_name_set,plot_var{ipvar}));
ivar=alb_idx;
ifn=1;

tl=tiledlayout(4,4);
for its=1:length(bintype)
   nexttile(its*2-1,[4 2])
   nanimagesc(pfm.(indvar_name_set{ivar}).(bintype{its}).(fldnms{ifn}))
   cb=colorbar;
   if its==length(bintype), cb.Label.String='AMP/bin ratio'; end
   title(['(',char(96+its),') ',upper(bintype{its})],'FontWeight','normal')
   xticks(1:length(var2_str))
   yticks(1:length(var1_str))
   xticklabels(extractAfter(var2_str,lettersPattern))
   yticklabels(extractAfter(var1_str,lettersPattern))
   set(gca,'FontSize',16)

   if strcmp(fldnms{ifn},'mr')
      colormap(cmaps.BrBG)
      set(gca,'ColorScale','log')
      caxis([.5 2])

      mpath=pfm.(indvar_name_set{ivar}).(bintype{its}).mpath_bin;
      [XX,YY]=meshgrid(1:length(var2_str),1:length(var1_str));
      mpath_bin_str=sprintfc('%0.3g',mpath);

      vidx=~isnan(pfm.(indvar_name_set{ivar}).(bintype{its}).mpath_amp);

      if strcmp(indvar_name_set{ivar}, 'mean_surface_ppt')
         idx_ignore=mpath<0.01;
         mpath_bin_str(idx_ignore)={' '};
      end

      for ivar1=1:length(var1_str)
         for ivar2=1:length(var2_str)
            if vidx(ivar1,ivar2)==1
               text(ivar2+0.015,ivar1-0.015,mpath_bin_str{ivar1,ivar2},...
                  'FontSize',15,'HorizontalAlignment','center',...
                  'Color',cmaps.coolwarm_r11(9,:)*.1,'FontName','Menlo')
               text(ivar2,ivar1,mpath_bin_str{ivar1,ivar2},'FontSize',15,...
                  'HorizontalAlignment','center',...
                  'Color',cmaps.coolwarm_r11(9,:),'FontName','Menlo')
            end
         end
      end
   end
end

xlab_key=extractBefore(var2_str,digitsPattern);
ylab_key=extractBefore(var1_str,digitsPattern);
xlab=[initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
ylab=[initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
xlabel(tl,xlab,'fontsize',16)
ylabel(tl,ylab,'fontsize',16)

title(tl,['Collision-coalescence only - ' indvar_ename_set{ivar} indvar_units_set{ivar} ...
   ],'fontsize',20,'fontweight','bold')
end
exportgraphics(gcf,['plots/p1/collonly_halflife.png'],'Resolution',300)
