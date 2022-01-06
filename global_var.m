global cloud_n_th rain_n_th cloud_mr_th rain_mr_th meanD_th ...
    l_amp l_sbm indvar_name_set indvar_ename_set cwp_th rwp_th sppt_th ...
    indvar_units_set indvar2D_name_set indvar2D_ename_set indvar2D_units_set ...
    color_order


% model configs
ampORbin = {'amp' 'bin'};
bintype = {'tau' 'sbm'};


% dir of the model output
if strcmp(computer('arch'),'maci64')
   output_dir='/Volumes/ESSD/AMP output/';
elseif strcmp(computer('arch'),'glnxa64')
   output_dir='../KiD_repo/KiD_2.3.2654/output/';
end
% output_dir='/Volumes/PESSD/AMP output/';
% output_dir='../output/';


% KiD cases
case_list_num = [101 102 103 105 106 107 601 602];
case_list_str = arrayfun(@(x) num2str(case_list_num(x)), 1:length(case_list_num),...
    'UniformOutput', false);


% thresholds to be considered as clouds 
cloud_mr_th = [1e-10 1e-2]; % kg/kg, threshold for mixing ratio (kg/kg)
rain_mr_th = [0 1e-2];
cloud_n_th = [1e-1 inf]; % #/cc, threshold for droplet number concentration
rain_n_th = [1e-4 inf];
cwp_th = [1e-5 inf]; % kg/m2 cloud water path threshold
rwp_th = [1e-6 inf]; % kg/m2 rain water path threshold
meanD_th = [0 inf];
sppt_th = [0 inf]; % mm/hr surface precipitation


% set the current date as nikki if unset
if ~exist('nikki')
    nikki=datestr(date,'YYYY-mm-dd');
end

% load these python colormap
Blues = getPyPlot_cMap('Blues',10);
rainbow = getPyPlot_cMap('rainbow',20);
coolwarm_s = getPyPlot_cMap('coolwarm');
coolwarm = getPyPlot_cMap('coolwarm',10);
coolwarm_r = getPyPlot_cMap('coolwarm_r',10);
ngrad=21;
BrBG20 = getPyPlot_cMap('BrBG',21);
BrBG = getPyPlot_cMap('BrBG',ngrad)*.9;
BrBG = repelem(BrBG,floor(256/ngrad),1); 

% initial variables key-values
initvarSet={'a','w','dm','rh','sp'};
fullnameSet={'Aerosol concentration', 'Maximum vertical velocity',...
            'Mean mass diameter', 'Relative humidity', 'Shape parameter'};
unitSet={'1/cc', 'm/s', '\mum', '%', ''};
initVarName_dict = containers.Map(initvarSet, fullnameSet);
initVarUnit_dict = containers.Map(initvarSet, unitSet);

% compare these vars
var_comp = [3:10];

indvar_name_all = {'diagM3_cloud','diagM3_rain',...
    'cloud_M1_path','rain_M1_path','liq_M1_path',...
    'diagM0_cloud','diagM0_rain',...
    'albedo','opt_dep','mean_surface_ppt','RH',...
    'Dm_c','Dm_r','Dm_w'...
    'dm_cloud_coll','dm_rain_coll','dm_sed',...
    'dm_cloud_ce','dm_rain_ce', ...
    'dqv_adv','cloud_M1_adv','rain_M1_adv',...
    'dtheta_mphys','dqv_mphys','cloud_M1_mphys','rain_M1_mphys',...
    'cloud_M1_mphys','rain_M1_mphys',...
};

indvar_ename_all = {'cloud mass','rain mass',...
    'cloud water path','rain water path','liquid water path',...
    'cloud number','rain number',...
    'albedo','optical depth','mean surface pcpt.','RH'...
    'Dm_c','Dm_r','Dm_w'...
    'dm cloud by coll','dm rain by coll','dm by sed',...
    'dm cloud by CE','dm rain by CE',...
    'dqv adv','cloud mass adv','rain mass adv',...
    'dtheta mphys','dqv mphys','cloud mass mphys','rain mass mphys',...
    'cloud M1 mphys','rain M1 mphys',...
};
indvar_units_all = {' [kg/kg]',' [kg/kg]',...
   ' [kg/m^2]',' [kg/m^2]',' [kg/m^2]',...
   ' [1/cc]',' [1/kg]',...
   '','',' [mm/hr]',' %'...
   ' [\mum]',' [\mum]',' [\mum]',...
   'kg/kg/s','kg/kg/s','kg/kg/s',...
   'kg/kg/s','kg/kg/s',...
   'kg/kg/s','kg/kg/s','kg/kg/s','kg/kg/s',...
   'kg/kg/s','kg/kg/s',...
   };

indvar_name_set=indvar_name_all(var_comp);
indvar_ename_set=indvar_ename_all(var_comp);
indvar_units_set=indvar_units_all(var_comp);

indvar2D_name_set = {%'diagM3_cloud','diagM3_rain',...
   'mean_cloud_M1_path','mean_rain_M1_path',...
   'mean_surface_ppt',...
%    'w',...
   };
indvar2D_ename_set = {%'cloud water','rain water',...
   'mean CWP','mean RWP',...
   'mean surface pcpt.',...
%    'w',...
   };
indvar2D_units_set = {%' [kg/kg]',' [kg/kg]',...
   ' [kg/m^2]',' [kg/m^2]',...
   ' [mm/hr]'
%    ' [m/s]',...
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
