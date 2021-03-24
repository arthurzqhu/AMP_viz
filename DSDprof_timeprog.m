function DSDprof_timeprog(time_total, time_step, DSDprof_mphys,z,binmean,fn,...
    Cmap,clr_linORlog,massORnd,var_overlay)
close all
c_map = getPyPlot_cMap(Cmap);

if nargin<10
    var_overlay=nan;
end

time_length = floor(time_total/time_step);

for it_idx = 1:time_length+1
    close all
    
%     figure('Visible','off')
    itime = (it_idx-1)*time_step+1;
    
    if itime>time_total itime=time_total; end
    
    switch massORnd
        case 'mass'
            DSD_prof_is=reshape(DSDprof_mphys(itime,:,:),[],length(z));
        case 'nd'
            DSD_prof_is=mass2conc(reshape(DSDprof_mphys(itime,:,:),[],length(z)),binmean)/1e6;
        case 'mass_adv'
            DSD_prof_is=reshape(DSDprof_mphys(itime,:,:),[],length(z));
    end
%     tic

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
    set(gca,'Position',[0.1198 0.1100 0.7141 0.8150])
    grid
    switch massORnd
        case 'mass'
            cbar.Label.String = 'DSD [kg/kg/ln(r)]';
%             caxis([-1e-3 1e-3])
            caxis([1e-8 1e-2])
%             cbar.Label.String = 'AMP/TAU mass';
%             caxis([1e-4 1e4])
        case 'nd'
            cbar.Label.String = 'DSD [1/cc/ln(r)]';
            caxis([1e-8 1e0])
        case 'mass_adv'
            cbar.Label.String = 'DSD_adv [kg/kg/ln(r)/s]';
            caxis([-1e-8 1e-8])
    end
%     toc
%     tic
    set(gca,'colorscale',clr_linORlog)
    xlabel('Diameter [m]')
    ylabel('Altitude [m]')
    
    if ~isnan(var_overlay)
        ax1 = gca;
        ax1_pos = ax1.Position;
        ax2 = axes('Position',[0.1198 0.1100 0.7141 0.8150],...
                   'XAxisLocation','top',...
                   'YAxisLocation','left',...
                   'Color','none');
               
        line(var_overlay(itime,:),z,'Parent',ax2,'linewidth',2,'color','g')
        set(gca,'YColor','none')
%         xlim([30 110])
        xlim([-1e-5 1e-5]) 
%         xline(0,'color','r')
    end
    annotation('textbox',[.7 .7 .2 .2],'String',...
        sprintf('t = %.0f s', itime),'FitBoxToText','on')
%     title(sprintf('t = %.0f s', itime))
    F(it_idx) = getframe(gcf);
    
%     toc
%     title('')
end

% tic
v = VideoWriter(['time progress in DSD', massORnd, ' ', fn,' profile.mp4'],'MPEG-4');
v.FrameRate=60;
open(v)
writeVideo(v,F)
close(v)
% toc
% finishingTaskSound
end