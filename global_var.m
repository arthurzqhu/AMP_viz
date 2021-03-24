global mconfig cloud_n_th rain_n_th cloud_mr_th rain_mr_th meanD_th ...
    l_amp l_sbm

ampORbin = {'amp','bin'};
bintype = {'tau','sbm'};


output_dir='/Volumes/ESSD/AMP output/';

case_list_num = [101 102 103 105 106 107];
case_interest = 1:length(case_list_num);
case_list_str = arrayfun(@(x) num2str(case_list_num(x)), 1:length(case_list_num),...
    'UniformOutput', false);
cloud_mr_th = [1e-10 1e-2]; % kg/kg, threshold for mixing ratio (kg/kg)
rain_mr_th = [1e-10 1e-2];
cloud_n_th = [1e-1 inf]; % #/cc, threshold for droplet number concentration
rain_n_th = [1e-4 inf];
meanD_th = [0 inf];
aero_N = 50*2.^(0:5);
aero_N_str = cell(length(aero_N),1);

w_spd = .25*2.^(0:3);
w_spd_str = cell(length(w_spd),1);

for i=1:length(aero_N)
    aero_N_str{i} = ['a' num2str(aero_N(i))];
end

for i=1:length(w_spd)
    w_spd_str{i} = ['w' num2str(w_spd(i))];
end

vars=1;
vare=4;


if ~exist('nikki')
    nikki=datestr(date,'YYYY-mm-dd');
end

plot_dir=['plots/' nikki '/' mconfig '/'];
if ~exist(['plots/' nikki '/' mconfig],'dir')
    mkdir(['plots/' nikki '/' mconfig])
end

Blues = getPyPlot_cMap('Blues');
coolwarm = getPyPlot_cMap('coolwarm');

% compare these vars
indvar_name = {'diagM3_cloud','diagM3_rain',...
    'cloud_M1_path','rain_M1_path',...
    %'dqv_adv','cloud_M1_adv','rain_M1_adv',...
    %'dtheta_mphys','dqv_mphys','cloud_M1_mphys','rain_M1_mphys',...
%     'cloud_M1_mphys','rain_M1_mphys',...
};
indvar_ename = {'cloud mass','rain mass',...
    'cloud M3 path','rain M3 path',...%'dqv adv','cloud mass adv','rain mass adv',...
    %'dtheta mphys','dqv mphys','cloud mass mphys','rain mass mphys',...
%     'cloud M1 mphys','rain M1 mphys',...
};

if l_amp==0
    ab_arr=2;
elseif l_amp==1
    ab_arr=1;
elseif l_amp==2
    ab_arr=[1 2];
else
    if isempty(l_amp)
    else
        error('l_amp can only be 0 (bin) 1 (amp) or 2 (both)')
    end
end

if l_sbm==0
    its=1;
elseif l_sbm==1
    its=2;
else
    if isempty(l_sbm)
    else
        error('l_sbm can only be 0 (tau) 1 (sbm)')
    end
end

