clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ... 
    bintype aero_N_str w_spd_str l_amp l_sbm fn %#ok<*NUSED>



l_amp=0;
l_sbm=0;

case_interest = 2;

ampORbin = {'bin'};
bintype = {'tau'};

nikki='2021-04-15';
mconfig='adv_only';

% last four characters of the model output file.
vnum='0001'; 


run global_var.m

%%

run case_dep_var.m
for ia = 1:length(aero_N_str)
    %% read files    
    for iw = 1:length(w_spd_str)
        for ici = case_interest

            if l_amp % load when == 1 or 2
                [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
                                loadnc('amp');
            end

            if l_amp~=1 % load when == 0 or 2
                [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
                                loadnc('bin');
            end

        end
        %% plot
        for ici = case_interest
            if l_sbm
                binmean = load('sbm_binmean.txt')*2*.01;
            else
                binmean = load('tau_binmean.txt')*2;
            end

            for iab = ab_arr

                if iab==1
                    time = amp_struct(ici).time;
                    z = amp_struct(ici).z;
                    amp_DSDprof = amp_struct(ici).mass_dist_init;
                    DSDprof = amp_DSDprof;
                end

                if iab==2 % set when ==0 or 2
                    time = bin_struct(ici).time;
                    z = bin_struct(ici).z;
                    bin_DSDprof = bin_struct(ici).mass_dist;
                    DSDprof = bin_DSDprof;

                    if l_sbm
                        DSDprof=DSDprof(:,1:length(binmean),:);
                    end
                end

                fn = [ampORbin{iab},'-',bintype{its},' ',mconfig,'-',vnum,' '];

        %         generate the comparison animation with another figure
        %         if l_amp==2
        %             fn = ['amp vs bin - ',bintype{its},' ',mconfig,' '];
        %             plot_DSDprof(1,:,:,:) = amp_DSDprof(:,1:length(binmean),:);
        %             plot_DSDprof(1,2:end,:,:) = plot_DSDprof(1,1:end-1,:,:); % because bin saves DSD after mphys while amp saves before
        %             tmp_mtx(1,:,:,:)=bin_DSDprof;
        %             plot_DSDprof(1,1,:,:) = amp_DSDprof(1,1:length(binmean),:); % changed the first bin DSD to the initialized distribution
        %             plot_DSDprof(2,:,:,:) = tmp_mtx(1,:,1:length(binmean),:); % !!!fix this part
        %         end

                total_length=length(time);
                time_step=5;

                DSDprof_timeprog(600, time_step, DSDprof, z,...
                    binmean,'Blues','log','mass')
            end
        end
    end
    
    
end