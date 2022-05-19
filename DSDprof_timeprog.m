function DSDprof_timeprog(ti, tf, ts_plot, DSDprof_mphys,z,binmean,...
   Cmap,clr_linORlog,pltflag,var_overlay)

global dt fn var1_str var2_str ivar1 ivar2 color_order %#ok<NUSED>

close all
c_map = getPyPlot_cMap(Cmap,20);

if ~exist('var_overlay','var') || isempty(var_overlay)
   var_overlay=nan;
end

time_length = floor((tf-ti+1)/ts_plot);
ts_output=ts_plot/dt;

loops = time_length;
F(loops) = struct('cdata',[],'colormap',[]);


if any(~isnan(var_overlay(:)))
   figure('position',[233 247 800 400])
else
   figure('position',[233 247 600 400])
end

tl=tiledlayout('flow');
nexttile(1)
iframe = 1;
for itime = ti:ts_plot:tf
   it_output = int32(itime*dt);

   switch pltflag
      case {'mass','mass_ratio','mass_adv'}
         DSD_prof_is=squeeze(DSDprof_mphys(it_output,:,:));
      case 'nd'
         DSD_prof_is=mass2conc(squeeze(DSDprof_mphys(it_output,:,:)),binmean)/1e6;
   end
   
   if length(binmean)<size(DSD_prof_is,1)
      DSD_prof_is = DSD_prof_is(1:length(binmean),:);
   end
   
   nanimagesc(binmean,z,DSD_prof_is')
   set(gca,'XScale','log')
   set(gca,'YDir','normal')
   
   xlim([min(binmean) max(binmean)])
   %     ylim([0 3000])
   colormap(c_map)
   cbar = colorbar;
   %     cbar.Visible = 'off';
   %set(gca,'Position',[0.1198 0.1100 0.7141 0.8150])
   grid
   switch pltflag
      case 'mass'
         cbar.Label.String = 'DSD [kg/kg/ln(r)]';
         caxis([1e-8 1e-2])
         %             cbar.Label.String = 'AMP/TAU mass';
         %             caxis([1e-4 1e4])
      case 'nd'
         cbar.Label.String = 'DSD [1/cc/ln(r)]';
         caxis([1e-8 1e0])
      case 'mass_adv'
         cbar.Label.String = 'DSD_adv [kg/kg/ln(r)/s]';
         caxis([-1e-8 1e-8])
      case 'mass_ratio'
         cbar.Label.String = 'AMP-BIN mass';
         caxis([-max(abs(DSDprof_mphys(:))) max(abs(DSDprof_mphys(:)))])
   end
        tic
   set(gca,'colorscale',clr_linORlog)
   xlabel('Diameter [m]')
   ylabel('Altitude [m]')
   
   if any(~isnan(var_overlay(:)))
   %   hold on
   %   plot(var_overlay(itime,:),z,'color',color_order{2},'linewidth',2)
   %   hold off
   %   ax1 = gca;
   %   ax1_pos = ax1.Position;
   %   ax2 = axes('Position',[0.1198 0.1100 0.7141 0.8150],...
   %      'XAxisLocation','top',...
   %      'YAxisLocation','left',...
   %      'Color','none');
   %   
   %   line(var_overlay(itime,:),z,'Parent',ax2,'linewidth',2,'color','g')
   %   set(gca,'YColor','none')
   %   %         xlim([30 110])
   %   %xlim([-1e-5 1e-5])
   %   xlim([min(binmean) max(binmean)])
   %   %         xline(0,'color','r')
      nexttile(2)
      plot(var_overlay(itime,:),z,'linewidth',2)
      xlabel('RH')
      xlim([min(var_overlay(:)) max(var_overlay(:))])

   end
   

   annotation('textbox',[.7 .7 .2 .2],'String',...
      sprintf('t = %.1f s', itime),'FitBoxToText','on')
   %     title(sprintf('t = %.0f s', itime))
   cdata = print('-RGBImage','-r144');
   F(iframe) = im2frame(cdata);
   %F(itime) = getframe(gcf);
   ['time=' num2str(itime)]

   iframe = iframe + 1;
   
   delete(findall(gcf,'type','annotation'))
   
        toc
   %     title('')
end

% tic

saveVid(F,['DSD', pltflag, ' ',...
   var1_str{ivar1} ' ' var2_str{ivar2} ' ' fn,...
   'profile'], 24)
%v = VideoWriter(['vids/time progress in DSD', pltflag, ' ',...
%   var1_str{ivar1} ' ' var2_str{ivar2} ' ' fn,...
%   'profile.mp4'],'MPEG-4');
%v.FrameRate=60;
%open(v)
%writeVideo(v,F)
%close(v)
% toc
% finishingTaskSound
end
