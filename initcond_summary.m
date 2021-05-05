clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
    bintype aero_N_str w_spd_str indvar_name indvar_name_set ...
    indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-05-04';
case_interest = 2; % 1:length(case_list_num);

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

set(0, 'DefaultFigurePosition',[1553 458 1028 527])

%%
coolwarm20 = getPyPlot_cMap('coolwarm_r',20);
% fig_prof=figure('visible','off');
% fig_path=figure('visible','off');
% fig_proc=figure('visible','off');
% fig_profdiff=figure('visible','off');
% fig_pathdiff=figure('visible','off');
% fig_procdiff=figure('visible','off');

% creating structures for performance analysis based on Rsq and ratio
pfm=struct;

for iconf = 1:length(mconfig_ls)
    mconfig = mconfig_ls{iconf};
    %     mconfig = 'adv_coll';
    run case_dep_var.m
    
    for its = 1:length(bintype)
        for ia = 1:length(aero_N_str)
            %             close all
            for iw = 1:length(w_spd_str)
                %                 close all
                
                [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
                    loadnc('amp',case_interest);
                [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
                    loadnc('bin',case_interest);
                
                % indices of vars to compare
                vars=1;
                vare=length(indvar_name);
                
                % plot
                for ici = case_interest
                    time = amp_struct(ici).time;
                    z = amp_struct(ici).z;
                    for ivar = vars:vare
                        var_comp_raw_amp = amp_struct(ici).(indvar_name{ivar});
                        var_amp_flt = var2phys(var_comp_raw_amp,ivar,0,1);
                        
                        var_comp_raw_bin = bin_struct(ici).(indvar_name{ivar});
                        var_bin_flt = var2phys(var_comp_raw_bin,ivar,0,1);
                        
                        % get the non-nan indices for both bin and amp
                        vidx=~isnan(var_amp_flt+var_bin_flt);
                        nzidx=var_amp_flt.*var_bin_flt>0;
                        
                        weight=var_bin_flt(vidx)/sum(var_bin_flt(vidx));
                        weight_log=log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));
                        
                        pfm(ici).(indvar_name{ivar}).(bintype{its}).rsq(ia,iw)=...
                            wrsq(var_amp_flt, var_bin_flt,weight);
                        
                    end
                end
            end
        end
    end
end

%% plot
close all
for iconf = 1:length(mconfig_ls)
    vars=1;
    vare=length(indvar_name);
    for ici = case_interest
        for ivar = vars:vare
            %%
            figure(ivar)
            tl=tiledlayout('flow');
            for its = 1:length(bintype)
                
                nexttile
                imagesc(pfm(ici).(indvar_name{ivar}).(bintype{its}).rsq)
                caxis([-1 1])
                colorbar
                colormap(coolwarm20)
                title(upper(bintype{its}),'FontWeight','normal')
                xlabel('max vertical velocity [m/s]')
                ylabel('aerosol concetration [1/cc]')
                xticks(1:length(w_spd_str))
                yticks(1:length(aero_N_str))
                xticklabels(extractAfter(w_spd_str,'w'))
                yticklabels(extractAfter(aero_N_str,'a'))
                set(gca,'FontSize',16)
            end
            
            title(tl,indvar_ename{ivar},'fontsize',20,'fontweight','bold')
        end
    end
end