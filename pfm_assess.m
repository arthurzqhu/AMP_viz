clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
    bintype aero_N_str w_spd_str indvar_name indvar_ename %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-05-07';
case_interest = 2;

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};
%%

close all
doweight=1;

pfm=struct;

% testsno=2:3:length(mconfig_ls);


for iconf = 1:length(mconfig_ls)
    mconfig = mconfig_ls{iconf};
    run case_dep_var.m
    
    for its = 1:length(bintype)
        for ia = 2%length(aero_N_str)
            for iw = 3%length(w_spd_str)
                %%
                [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
                    loadnc('amp',case_interest);
                [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
                    loadnc('bin',case_interest);
                vars=1;
                vare=length(indvar_name);
                
                for ici = case_interest
                    for ivar = vars:vare
                        %%
                        time = amp_struct(ici).time;
                        z = amp_struct(ici).z;
                        
                        var_comp_raw_amp = amp_struct(ici).(indvar_name{ivar});
                        var_amp_flt = var2phys(var_comp_raw_amp,ivar,0,1);
                        
                        var_comp_raw_bin = bin_struct(ici).(indvar_name{ivar});
                        var_bin_flt = var2phys(var_comp_raw_bin,ivar,0,1);
                        
                        % get the non-nan indices for both bin and amp
                        vidx=~isnan(var_amp_flt+var_bin_flt);
                        
                        weight=var_bin_flt(vidx)/sum(var_bin_flt(vidx));
                        weight_log=log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));
                        
                        if ~doweight
                            weight=ones(size(weight));
                        end
                        
%                         pfm(iconf).(bintype{its})(ia,ivar)=...
%                             wrsq(var_amp_flt, var_bin_flt,weight);
%                         if its==2 && ivar==2

                        figure
                        plot(var_bin_flt,var_amp_flt,'.');
                        title([bintype{its} ' - ' indvar_ename{ivar}])
                        refline(1,0)
                    end
                end
            end
        end
    end
end