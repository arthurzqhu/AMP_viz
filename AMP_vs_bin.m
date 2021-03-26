clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
    bintype aero_N_str w_spd_str indvar_name %#ok<*NUSED>

mconfig='noinit';
nikki='2021-03-19';

icase=2;
vnum='0001';

run global_var.m

%% read files
close all
set(0, 'DefaultFigurePosition',[1553 458 1028 527])

for its = 1:length(bintype)
    for ia = 1:length(aero_N)-1
        %             close all
        for iw = 4%1:length(w_spd)
            %                 close all
            for ici = icase%case_interest
                
                [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
                    loadnc('amp');
                [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
                    loadnc('bin');
                
            end
            
            % plot
            for ivar = vars:vare
                
                % change linestyle according to cloud/rain
                if contains(indvar_ename{ivar},'cloud')
                    lsty='-';
                elseif contains(indvar_ename{ivar},'rain')
                    lsty=':';
                end
                
                for ici = icase%case_interest
                    
                    time = amp_struct(ici).time;
                    z = amp_struct(ici).z;
                    
                    var_comp_raw_amp = amp_struct(ici).(indvar_name{ivar});
                    [var_comp_amp,~,~] = var2phys(var_comp_raw_amp,ivar,1);
                    
                    var_comp_raw_bin = bin_struct(ici).(indvar_name{ivar});
                    [var_comp_bin,linORlog,range] = var2phys(var_comp_raw_bin,ivar,1);
                    
                    
                    if ~contains(indvar_name{ivar},'path')
                        fig_prof=figure(1);
                        for iab = 1:length(ampORbin)
                            % plot cloud/rain water profile
                            if iab==1
                                var_plt = var_comp_amp;
                            else
                                var_plt = var_comp_bin;
                            end

                            nanimagesc(time,z,var_plt')
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
                            hold off
                            title([ampORbin{iab},'-',...
                                bintype{its}, ' ', ...
                                indvar_ename{ivar}, ' ', ...
                                aero_N_str{ia},' ' ...
                                w_spd_str{iw}],...
                                'fontsize',20,...
                                'FontWeight','bold')
                            saveas(fig_prof,[plot_dir,...
                                indvar_ename{ivar},' ', ...
                                ampORbin{iab},'-',bintype{its},' ',...
                                case_list_str{ici},'-',...
                                vnum,' ',...
                                aero_N_str{ia}, ' ', w_spd_str{iw},'.png'])
                        end
                    else
                        % plot cloud/rain water path comparison
                        fig_path=figure(2);
                        
                        plot(time,var_comp_amp,...
                            'LineWidth',2,...
                            'LineStyle',lsty,...
                            'color',colororder(1,:))
                        hold on
                        plot(time,var_comp_bin,...
                            'LineWidth',2,...
                            'LineStyle',lsty,...
                            'color',colororder(2,:))

                        xlim([min(time) max(time)])
                        xlabel('Time [s]')
                        ylabel('liquid water path')
                        
                        if contains(indvar_name{ivar},'rain')
                            % only do these when both cloud and rain are plotted
                            
                            set(gca,'fontsize',16)
                            
                            legend(['amp-' bintype{its}, ' cloud'],...
                            ['bin-' bintype{its},' cloud'],...
                            ['amp-' bintype{its}, ' rain'],...
                            ['bin-' bintype{its},' rain'])
                            
                            title([bintype{its}, ...
                                ' cloud/rain water path ', ...
                                aero_N_str{ia},' ' ...
                                w_spd_str{iw}],...
                                'fontsize',20,...
                                'FontWeight','bold')
                            
                            hold off
                            saveas(fig_path,[plot_dir,...
                                'liquid water path ',...
                                'amp vs bin-',bintype{its},' ',...
                                case_list_str{ici},'-',vnum,' ',...
                                aero_N_str{ia}, ' ', w_spd_str{iw},'.png'])
                        end
                    end
                    pause(.5) % (optional) to prevent matlab from halting
                end
                
            end
            
            %% plot difference
            for ivar = vars:vare
                
                if contains(indvar_ename{ivar},'cloud')
                    lsty='-';
                elseif contains(indvar_ename{ivar},'rain')
                    hold on
                    lsty=':';
                end
                
                for ici = icase %case_interest
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
                    
                    if ~contains(indvar_name{ivar},'path')
                        % plot profile difference
                        fig_profdiff=figure(3);
                        nanimagesc(time,z,var_diff')
                        set(gca,'YDir','normal')
                        colormap(coolwarm)
                        caxis([-bound bound]);
                        set(gca,'ColorScale','lin')
                        cbar = colorbar;
                        cbar.Label.String = 'diff';
                        xlabel('Time [s]')
                        ylabel('Altitude [m]')
                        
                        title(['\Delta',bintype{its},'-amp ',...
                            indvar_ename{ivar}, ' ', ...
                            aero_N_str{ia},' ',...
                            w_spd_str{iw}, ' '],...
                            'fontsize',20,'FontWeight','bold')
                        
                    else
                        % plot path difference
                        fig_pathdiff=figure(4);
                        refline(0,0)
                        plot(time,var_diff,'LineWidth',2,...
                            'LineStyle',lsty,...
                            'color',colororder(1,:)) 
                        hold on
                        xlim([min(time) max(time)])
                        xlabel('Time [s]')
                        ylabel('liquid water path')
                    end
                    
                    set(gca,'fontsize',16)
                    if ~contains(indvar_name{ivar},'path')
                        %only save the comparison when both are plotted
                        saveas(fig_profdiff,[plot_dir,...
                            indvar_ename{ivar},' ',...
                            bintype{its},'-amp diff', ...
                            ' ',case_list_str{ici},'-',vnum,' ',...
                            aero_N_str{ia},' ',...
                            w_spd_str{iw},'.png'])
                    else
                        if contains(indvar_name{ivar},'rain')
                            title([bintype{its}, ...
                                    ' cloud/rain water path diff ', ...
                                    aero_N_str{ia},' ' ...
                                    w_spd_str{iw}],...
                                    'fontsize',20,...
                                    'FontWeight','bold')
                            legend('bin-amp cloud','','bin-amp rain')
                            hold off
                            saveas(fig_pathdiff,[plot_dir,...
                                'liquid water path ',...
                                bintype{its},'-amp diff', ...
                                ' ',case_list_str{ici},'-',vnum,' ',...
                                aero_N_str{ia},' ',...
                                w_spd_str{iw},'.png'])
                        end
                    end
                    
                    pause(.5)
                end
            end
        end
    end
end