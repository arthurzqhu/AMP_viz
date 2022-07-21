clear
clear global
close all

global mconfig ivar2 ivar1 ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set %#ok<*NUSED>

textclr = '#F6F4EC';
tilebg_color = '#7F96C5';
figbg_color = '#7F96C5';
wrapper_color = {'#16E8CF', '#FBE232'};

vnum='0001'; % last four characters of the model output file.
nikki='lower_thres';
global_var

amp_color_str = num2str(hex2rgb(wrapper_color{1}));
bin_color_str = num2str(hex2rgb(wrapper_color{2}));
textclr_rgb = num2str(hex2rgb(textclr));
tau_color_str = num2str(color_order{1});
sbm_color_str = num2str(color_order{2});

mconfig='fullmic';
get_var_comp([3:8 10])

load(['pfm_summary/' nikki '_' mconfig '_pfm.mat'])
case_dep_var

tmpvarname=fieldnames(pfm(1));
fldnms=fieldnames(pfm(1).(tmpvarname{1}).(bintype{1}));
fldnms=fldnms(1:end-1);

titles = {sprintf(['\\color[rgb]{%s}AMP\\color[rgb]{%s}-\\color[rgb]{%s}TAU\\color[rgb]{%s} vs. ',...
   '\\color[rgb]{%s}bin\\color[rgb]{%s}-\\color[rgb]{%s}TAU\\color[rgb]{%s} (D_t = 80|50 \\mum)'],...
   amp_color_str, textclr_rgb, tau_color_str, textclr_rgb, bin_color_str, ...
   textclr_rgb, tau_color_str, textclr_rgb),...
   sprintf(['\\color[rgb]{%s}AMP\\color[rgb]{%s}-\\color[rgb]{%s}SBM\\color[rgb]{%s} vs. ', ...
   '\\color[rgb]{%s}bin\\color[rgb]{%s}-\\color[rgb]{%s}SBM\\color[rgb]{%s} (D_t = 80|50 \\mum)'],...
   amp_color_str, textclr_rgb, sbm_color_str, textclr_rgb, bin_color_str, ...
   textclr_rgb, sbm_color_str, textclr_rgb),...
   sprintf(['\\color[rgb]{%s}bin\\color[rgb]{%s}-\\color[rgb]{%s}TAU\\color[rgb]{%s} vs. ',...
   '\\color[rgb]{%s}bin\\color[rgb]{%s}-\\color[rgb]{%s}SBM'],...
   bin_color_str, textclr_rgb, tau_color_str, textclr_rgb, bin_color_str, textclr_rgb, sbm_color_str)};
plot_var={'cloud_M1_path','mean_surface_ppt'};

figure('position',[0 0 1250 1170])
tl=tiledlayout(10,4);

for itt = 1:length(titles)

   for ipvar=1:length(plot_var)
      alb_idx=find(contains(indvar_name_set,plot_var{ipvar}));
      ivar=alb_idx;
      ifn=1;

      if itt == 1
         title(tl,titles{itt},'fontsize',24,'fontweight','bold','color',textclr)
      elseif itt == 2
         annotation('textbox',[.2 .5 .6 .2], 'string', ...
            titles{itt}, ...
            'fontsize',24,'fontweight','bold',...
            'HorizontalAlignment','center','VerticalAlignment','middle',...
            'edgecolor','none','color',textclr)
      elseif itt == 3
         annotation('textbox',[.2 .21 .6 .2], 'string', ...
            titles{itt}, ...
            'fontsize',24,'fontweight','bold',...
            'HorizontalAlignment','center','VerticalAlignment','middle',...
            'edgecolor','none','color',textclr)
      end

      nexttile(ipvar*2+3 + (itt-1)*12, [3 2])


      ngrads=size(coolwarm_r,1);
      if itt < length(titles)
         lowthres = load(['pfm_summary/lower_thres_' mconfig '_pfm.mat']);
         orgthres = load(['pfm_summary/orig_thres_' mconfig '_pfm.mat']);
         lmat = lowthres.pfm.(indvar_name_set{ivar}).(bintype{itt}).mr;
         omat = orgthres.pfm.(indvar_name_set{ivar}).(bintype{itt}).mr;

         % weave two matrix together
         olmat = reshape([omat;lmat], size(omat,1), []);
         nanimagesc(.75:.5:5.25,1:5,olmat)
         cb=colorbar;
         if ipvar==length(plot_var)
            cb.Label.String='AMP/bin ratio'; 
         end
         mpath=pfm.(indvar_name_set{ivar}).(bintype{itt}).mpath_bin;
      else
         load(['pfm_summary/orig_thres_' mconfig '_pfm_bincomp.mat'])
         nanimagesc(pfm.(indvar_name_set{ivar}).mr)
         cb=colorbar;
         if ipvar==length(plot_var)
            cb.Label.String='TAU/SBM ratio'; 
         end
         mpath=pfm.(indvar_name_set{ivar}).mpath_sbm;
      end

      for ix = .5:1:5.5
         line([ix, ix], [.5, 5.5], 'LineWidth', 2, 'Color', textclr)
      end
      for iy = .5:1:5.5
         line([.5, 5.5], [iy, iy], 'LineWidth', 2, 'Color', textclr)
      end


      set(gca,'Color',tilebg_color)
      set(gca,'XColor',textclr)
      set(gca,'YColor',textclr)
      cb.Color = textclr;
      cb.Label.Color = textclr;

      title([indvar_ename_set{ivar} indvar_units_set{ivar}], 'FontWeight', 'normal','color',textclr)
      xticks(1:length(var2_str))
      yticks(1:length(var1_str))
      xticklabels(extractAfter(var2_str,lettersPattern))
      yticklabels(extractAfter(var1_str,lettersPattern))

      set(gca,'FontSize',16)
      colormap(BrBG)
      set(gca,'ColorScale','log')
      caxis([.5 2])

      [XX,YY]=meshgrid(1:length(var2_str),1:length(var1_str));
      mpath_bin_str=sprintfc('%0.3g',mpath);

      for ivar1=1:length(var1_str)
         for ivar2=1:length(var2_str)

            if indvar_name_set{ivar} == "mean_surface_ppt" && mpath(ivar1, ivar2) < sppt_th(1)
               continue
            end
            % ----- get text color -----
            if itt < length(titles)
               clr_idx=roundfrac(pfm.(indvar_name_set{ivar}).(bintype{itt}).rsq(ivar1,ivar2),...
                                 1/ngrads)*ngrads;
            else
               clr_idx=roundfrac(pfm.(indvar_name_set{ivar}).rsq(ivar1,ivar2),1/ngrads)*ngrads;
            end
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
               'Color',coolwarm_r(clr_idx,:)*.1,'FontName','Menlo')
            text(ivar2,ivar1,mpath_bin_str{ivar1,ivar2},'FontSize',15,...
               'HorizontalAlignment','center',...
               'Color',coolwarm_r(clr_idx,:),'FontName','Menlo')
         end
      end


      nexttile(2,[1,2])
      set(gca,'Color','none')
      set(gca,'XColor','none')
      set(gca,'YColor','none')
      colormap(gca,coolwarm_r)
      cb=colorbar('southoutside');
      cb.Label.String='R^2';
      cb.Label.Color = textclr;
      cb.Color = textclr;
      cb.Label.Position=[0.5000 3.3 0];
      set(gca,'FontSize',16)

      xlab_key=extractBefore(var2_str,digitsPattern);
      ylab_key=extractBefore(var1_str,digitsPattern);
      xlab=[initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
      ylab=[initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
      xlabel(tl,xlab,'fontsize',24,'color',textclr,'fontweight','bold')
      ylabel(tl,ylab,'fontsize',24,'color',textclr,'fontweight','bold')
   end
end

exportgraphics(gcf,['plots/cmmplots/fullmp_cmm_orig|low.png'],'Resolution',300,'BackgroundColor',figbg_color)
