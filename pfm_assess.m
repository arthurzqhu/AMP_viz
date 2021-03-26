clear
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
    bintype aero_N_str w_spd_str indvar_name %#ok<*NUSED>

mconfig='noinit';
nikki='2021-03-19';

% last four characters of the model output file.
vnum='0001'; 

run global_var.m

%%

for its = 1:length(bintype)
    for ia = 1:length(aero_N)
        for iw = 4%1:length(w_spd)
            %%
            for ici = case_interest
                
                [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
                    loadnc('amp');
                [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
                    loadnc('bin');
            end
            
            for ivar = vars:vare
                %%
                ivar=1;
                time = amp_struct(ici).time;
                z = amp_struct(ici).z;
                
                var_comp_raw_amp = amp_struct(ici).(indvar_name{ivar});
                var_amp_flt = var2phys(var_comp_raw_amp,ivar,0,1);
                
                var_comp_raw_bin = bin_struct(ici).(indvar_name{ivar});
                var_bin_flt = var2phys(var_comp_raw_bin,ivar,0,1);
                
                plot(var_bin_flt,var_amp_flt,'.');
                refline(1,0)
                
                % get the non-nan indices for both bin and amp
                vidx=~isnan(var_amp_flt+var_bin_flt);
                
                weight=var_bin_flt(vidx)/sum(var_bin_flt(vidx));
                weight_log=log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));
                
                rss=sum((var_amp_flt(vidx)-var_bin_flt(vidx)).^2.*weight);
                tss=sum((var_bin_flt(vidx)-wmean(var_bin_flt(vidx),weight)).^2.*weight);
                
                
                pfm=1-rss/tss;
                disp(pfm)
                
            end
        end
    end
end