global cloud_n_th rain_n_th cloud_mr_th rain_mr_th meanD_th ...
    l_amp l_sbm indvar_name_set indvar_ename_set cwp_th rwp_th


% model configs
ampORbin = {'amp','bin'};
bintype = {'tau','sbm'};


% dir of the model output
output_dir='/Volumes/ESSD/AMP output/';


% KiD cases
case_list_num = [101 102 103 105 106 107 601 602];
case_list_str = arrayfun(@(x) num2str(case_list_num(x)), 1:length(case_list_num),...
    'UniformOutput', false);


% thresholds to be considered as clouds 
cloud_mr_th = [1e-10 1e-2]; % kg/kg, threshold for mixing ratio (kg/kg)
rain_mr_th = [1e-10 1e-2];
cloud_n_th = [1e-1 inf]; % #/cc, threshold for droplet number concentration
rain_n_th = [1e-4 inf];
cwp_th = [1e-3 inf]; % kg/m2 cloud water path threshold
rwp_th = [1e-3 inf]; % kg/m2 rain water path threshold
meanD_th = [0 inf];


% set the current date as nikki if unset
if ~exist('nikki')
    nikki=datestr(date,'YYYY-mm-dd');
end

% load these python colormap
Blues = getPyPlot_cMap('Blues',10);
coolwarm = getPyPlot_cMap('coolwarm',10);
coolwarm_r = getPyPlot_cMap('coolwarm_r',10);
BrBG = [84,48,5;
140,81,10;
191,129,45;
223,194,125;
246,232,195;
225,225,225;
199,234,229;
128,205,193;
53,151,143;
1,102,94;
0,60,48]/255;

% compare these vars
indvar_name_set = {%'diagM3_cloud','diagM3_rain',...
    'cloud_M1_path','rain_M1_path',...
%     'dm_cloud_ce','dm_rain_ce', ...
%     'dm_cloud_coll','dm_rain_coll','dm_sed',...
    %'dqv_adv','cloud_M1_adv','rain_M1_adv',...
    %'dtheta_mphys','dqv_mphys','cloud_M1_mphys','rain_M1_mphys',...
%     'cloud_M1_mphys','rain_M1_mphys',...
};
indvar_ename_set = {%'cloud mass','rain mass',...
    'cloud mass path','rain mass path',...
%     'dm cloud by CE','dm rain by CE',...
%     'dm cloud by coll','dm rain by coll','dm by sed',...
    %'dqv adv','cloud mass adv','rain mass adv',...
    %'dtheta mphys','dqv mphys','cloud mass mphys','rain mass mphys',...
%     'cloud M1 mphys','rain M1 mphys',...
};


% additional variables generating animation in AMP_vs_bin_dist
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

colororder=colororder;
color_order={};
for i=1:size(colororder,1)
    color_order{i}=colororder(i,:);
end

clear colororder
