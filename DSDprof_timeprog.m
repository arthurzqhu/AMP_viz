function DSDprof_timeprog(ti, tf, ts_plot, DSDprof_mphys,z,binmean,...
   Cmap,clr_linORlog,pltflag,var_overlay)

global its bintype dt fn var1_str var2_str ivar1 ivar2 color_order test

close all
c_map = getPyPlot_cMap(Cmap,20);

if ~exist('var_overlay','var') || isempty(var_overlay)
   var_overlay=nan;
end

time_length = floor((tf-ti)/ts_plot+1);
ts_output=ts_plot/dt;

F(time_length-1) = struct('cdata',[],'colormap',[]);


if any(~isnan(var_overlay(:)))
   figure('position',[233 247 800 400])
else
   figure('position',[233 247 600 400])
end

tl=tiledlayout('flow');
nexttile(1)
iti = int32(ti/dt);
itf = int32(tf/dt);
istep = int32(ts_plot/dt);
time_series=iti:istep:itf;

parfor iframe = 1:length(time_series)
   itime = time_series(iframe);
   if itime<=0
      itime = 1;
   end
   real_time = double(itime)*double(dt);

   % switch pltflag
   %    case {'mass','mass_diff','mass_adv'}
   %       DSD_prof_is=squeeze(DSDprof_mphys(itime,:,:));
   %    case {'number','number_diff'}
   %       if bintype{its}=="tau"
   %          DSD_prof_is=squeeze(DSDprof_mphys(itime,:,:))/1e6;
   %       else
   %          DSD_prof_is=mass2conc(squeeze(DSDprof_mphys(itime,:,:)),binmean)/1e6;
   %       end
   % end
   
   % if length(binmean)<size(DSD_prof_is,1)
   %    DSD_prof_is = DSD_prof_is(1:length(binmean),:);
   % end
   
   nanimagesc(binmean,z,squeeze(DSDprof_mphys(itime,1:length(binmean),:))')
   set(gca,'XScale','log')
   set(gca,'YDir','normal')
   
   if any(~isnan(var_overlay(:)))
      xlim([1e-7 max(var_overlay(:))])
   else
      xlim([min(binmean) max(binmean)])
   end
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
      case 'number'
         cbar.Label.String = 'DSD [1/cc/ln(r)]';
         caxis([1e-10 1e3])
      case 'mass_adv'
         cbar.Label.String = 'DSD_adv [kg/kg/ln(r)/s]';
         caxis([-1e-8 1e-8])
      case 'mass_diff'
         cbar.Label.String = 'AMP-BIN mass';
         caxis([-max(abs(DSDprof_mphys(:))) max(abs(DSDprof_mphys(:)))])
      case 'number_diff'
         cbar.Label.String = 'AMP-BIN number';
         caxis([-1e2 1e2])
   end
   set(gca,'colorscale',clr_linORlog)
   xlabel('Diameter [m]')
   ylabel('Altitude [m]')
   
   if any(~isnan(var_overlay(:)))

      hold on
      % nexttile(2)
      plot(var_overlay(itime,:,1),z,'linewidth',1,'color',color_order{1})
      plot(var_overlay(itime,:,2),z,'linewidth',1,'color',color_order{2})
      xlabel('Dn_c, Dn_r')
      set(gca,'XScale','log')
      hold off

   end
   

   annotation('textbox',[.7 .7 .2 .2],'String',...
      sprintf('t = %.1f s', real_time),'FitBoxToText','on')
   %     title(sprintf('t = %.0f s', real_time))
   cdata = print('-RGBImage','-r144');
   F(iframe) = im2frame(cdata);
   %F(real_time) = getframe(gcf);
   disp(['time=' num2str(real_time)])

   delete(findall(gcf,'type','annotation'))
   
   %     title('')
end

% tic
test = F;

if isempty(var1_str)
   saveVid(F,[fn, 'DSD', pltflag, ' ',...
      num2str(ti) '-', num2str(tf)], 10)
else
   saveVid(F,[fn, 'DSD', pltflag, ' ',...
      var1_str{ivar1} ' ' var2_str{ivar2}, ...
      ' ', num2str(ti) '-', num2str(tf)], 10)
end
%v = VideoWriter(['vids/time progress in DSD', pltflag, ' ',...
%   var1_str{ivar1} ' ' var2_str{ivar2} ' ' fn,...
%   'profile.mp4'],'MPEG-4');
%v.FrameRate=60;
%open(v)
%writeVideo(v,F)
%close(v)
% finishingTaskSound
end
