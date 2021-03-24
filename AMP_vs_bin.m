clear
clear global
close all
cd '~/MEGAsync/grad/research/AMP/AMP_viz/'
global mconfig iw ia its ici nikki output_dir case_list_str vnum ... 
    bintype aero_N_str w_spd_str indvar_name

mconfig='noinit';
nikki='2021-03-19';

icase=2;
vnum='0001';
output_dir='/Volumes/ESSD/AMP output/';

run global_var.m

%% read files

set(0, 'DefaultFigurePosition',[1553 458 1028 527])

for its = 1:length(bintype)
    for iab = 1:length(ampORbin)
        for ia = 1:length(aero_N)
%             close all
            for iw = 1:length(w_spd)
%                 close all
                for ici = icase%case_interest
                    
                    [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
                        loadnc('amp');
                    [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
                        loadnc('bin');
                    
                end
                % plot
                for ivar = vars:vare
                    close all
%                     figure('Position', [1553 458 1028 527]);
%                     tl = tiledlayout('flow');

                    for ici = icase%case_interest

                        time = amp_struct(ici).time;
                        z = amp_struct(ici).z;

                        var_comp_raw_amp = amp_struct(ici).(indvar_name{ivar});
                        [var_comp_amp,~,~] = var2phys(var_comp_raw_amp,...
                            ivar,amp_struct(ici),1);

                        var_comp_raw_bin = bin_struct(ici).(indvar_name{ivar});
                        [var_comp_bin,linORlog,range] = var2phys(var_comp_raw_bin,...
                            ivar,bin_struct(ici),1);

                        if iab==1
                            var_rat = var_comp_amp;
                        else
                            var_rat = var_comp_bin;
                        end

                        if isequal(size(var_rat),[length(time) length(z)])
                            nanimagesc(time,z,var_rat')
                            set(gca,'YDir','normal')
                            if ~contains(indvar_name{ivar},{'flag','adv','mphys'})
                                colormap(Blues)
                            else
                                colormap(coolwarm)
                            end
                            set(gca,'ColorScale',linORlog)
                            caxis(range)
                            cbar = colorbar;
                            cbar.Label.String = indvar_ename{ivar};
                            xlabel('Time [s]')
                            ylabel('Altitude [m]')
                        elseif isequal(size(var_comp_amp),[length(time) 1])
                            plot(time,var_comp_amp,time,var_comp_bin,...
                                'LineWidth',2)
                            xlim([min(time) max(time)])
                            xlabel('Time [s]')
                            ylabel(indvar_ename{ivar})
                            legend(['amp-' bintype{its}],['bin-' bintype{its}])
                            hold on
                        end
                        title([ampORbin{iab},'-',bintype{its}, ' ', ...
                            indvar_ename{ivar}, ' ', aero_N_str{ia},' ' ...
                            w_spd_str{iw}],'fontsize',20,'FontWeight','bold')
                    end


                    if ~contains(indvar_name{ivar},'path')
                        saveas(gcf,[plot_dir,ampORbin{iab},...
                            '-',bintype{its},' ',case_list_str{ici},'-',...
                            vnum,' ', indvar_ename{ivar},' ',...
                            aero_N_str{ia}, ' ', w_spd_str{iw},'.png'])
                    else
                        if iab == length(ampORbin)
                            saveas(gcf,[plot_dir,...
                                'amp vs bin-',bintype{its},' ',...
                                case_list_str{ici},'-',vnum,' ',...
                                indvar_ename{ivar},' ',...
                                aero_N_str{ia}, ' ', w_spd_str{iw},'.png'])
                        end
                    end
                end
                %%
                for ivar = vars:vare
                    close all
%                     figure('Position', [1553 458 1028 527]);
                    for ici = icase %case_interest
                        hold off
                        var_comp_raw_amp = amp_struct(ici).(indvar_name{ivar});
                        [var_comp_amp,~,~] = var2phys(var_comp_raw_amp,...
                            ivar,amp_struct(ici),1);
                        
                        var_comp_raw_bin = bin_struct(ici).(indvar_name{ivar});
                        [var_comp_bin,linORlog,range] = var2phys(var_comp_raw_bin,...
                            ivar,bin_struct(ici),1);

                        var_comp_amp(isnan(var_comp_amp))=0;
                        var_comp_bin(isnan(var_comp_bin))=0;

                        var_diff = var_comp_bin-var_comp_amp;
                        bound=10^(ceil(log10(prctile(abs(var_diff(:)),99))*2)/2);
                        
                        if bound==0
                            bound=10^(ceil(log10(max(abs(var_diff(:))))*2)/2);
                        end
                        
                        if isequal(size(var_diff),[length(time) length(z)])
                            nanimagesc(time,z,var_diff')
                            set(gca,'YDir','normal')
                            colormap(coolwarm)
                            caxis([-bound bound]);
                            set(gca,'ColorScale','lin')
                            cbar = colorbar;
                            cbar.Label.String = 'diff';
                            xlabel('Time [s]')
                            ylabel('Altitude [m]')
                        elseif isequal(size(var_diff),[length(time) 1])
                            plot(time,var_diff,'LineWidth',2)
                            xlim([min(time) max(time)])
                            xlabel('Time [s]')
                            ylabel(indvar_ename{ivar})
                        end
                        title(['\Delta',bintype{its},'-amp ',...
                            indvar_ename{ivar}, ' ', ...
                            aero_N_str{ia},' ',...
                            w_spd_str{iw}, ' '],...
                            'fontsize',20,'FontWeight','bold')
                    end

                    saveas(gcf,[plot_dir,bintype{its},'-amp diff', ' ',...
                        case_list_str{ici},'-',vnum,' ', indvar_ename{ivar},' ',...
                        aero_N_str{ia},' ', w_spd_str{iw},'.png'])
                end
            end
        end
    end
end