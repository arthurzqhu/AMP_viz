clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ... 
    bintype aero_N_str w_spd_str l_amp l_sbm fn %#ok<*NUSED>



l_amp=0;
l_sbm=0;

mconfig='noinit';
vnum='0001';
nikki='2021-03-19';
icase=2;

run global_var.m

output_dir='/Volumes/ESSD/AMP output/';

%%


for ia = 2%;length(aero_N)
    %% read files    
    iw=4;
    for ici = icase%case_interest
        
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
    for ici = icase%case_interest
        if l_sbm
            binmean = load('sbm_binmean.txt')*2*.01;
        else
            binmean = load('tau_binmean.txt')*2;
        end
        
        if l_amp % set when ==1 or 2
            time = amp_struct(ici).time;
            z = amp_struct(ici).z;
            amp_DSDprof = amp_struct(ici).mass_dist_init;
            DSDprof = amp_DSDprof;
        end
        
        if l_amp~=1 % set when ==0 or 2
            time = bin_struct(ici).time;
            z = bin_struct(ici).z;
            bin_DSDprof = bin_struct(ici).mass_dist;
            DSDprof = bin_DSDprof;
            if l_sbm
                DSDprof=DSDprof(:,1:length(binmean),:);
            end
        end
        %%
            
        fn = [ampORbin{ab_arr},'-',bintype{its},' ',mconfig,'-',vnum,' '];

        if l_amp==2
            fn = ['amp vs bin - ',bintype{its},' ',mconfig,' '];
            plot_DSDprof(1,:,:,:) = amp_DSDprof(:,1:length(binmean),:);
            plot_DSDprof(1,2:end,:,:) = plot_DSDprof(1,1:end-1,:,:); % because bin saves DSD after mphys while amp saves before
            tmp_mtx(1,:,:,:)=bin_DSDprof;
            plot_DSDprof(1,1,:,:) = amp_DSDprof(1,1:length(binmean),:); % changed the first bin DSD to the initialized distribution
            plot_DSDprof(2,:,:,:) = tmp_mtx(1,:,1:length(binmean),:); % !!!fix this part

        end
        
        total_length=length(time);
        time_step=5;
        
        DSDprof_timeprog(total_length, time_step, DSDprof, z,...
            binmean,'Blues','log','mass')
        
    end
    
    
end