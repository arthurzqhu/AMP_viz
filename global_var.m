global cloud_n_th rain_n_th cloud_mr_th rain_mr_th meanD_th ...
   l_amp l_sbm indvar_name_set indvar_ename_set indvar_units_set ...
   cwp_th rwp_th sppt_th indvar2D_name_set indvar2D_ename_set indvar2D_units_set ...
   color_order indvar_name_all indvar_ename_all indvar_units_all ...
   mconfigivar_dict split_bins col binmean

indvar_name_set = {};
indvar_ename_set = {};
indvar_units_set = {};

%% bin cloud-rain threshold
split_bins = [15 14];

%% constants
col = log(2)/3;
binmean(1,:) = load('diamg_tau.txt');
binmean(2,1:33) = load('diamg_sbm.txt');

%% model configs
ampORbin = {'amp' 'bin'};
bintype = {'tau' 'sbm'};


%% dir of the model output
if strcmp(computer('arch'),'maci64')
   output_dir='/Volumes/ESSD/AMP output/';
elseif strcmp(computer('arch'),'glnxa64')
   output_dir='../github/KiD_repo/KiD_1mode_gam/output/';
end
% output_dir='/Volumes/PESSD/AMP output/';
% output_dir='../output/';


%% KiD cases
case_list_num = [101 102 103 105 106 107 601 602];
case_list_str = arrayfun(@(x) num2str(case_list_num(x)), 1:length(case_list_num),...
   'UniformOutput', false);


%% thresholds to be considered as clouds 
cloud_mr_th = [1e-7 1e-2]; % kg/kg, threshold for mixing ratio (kg/kg)
rain_mr_th = [1e-7 1e-2];
cloud_n_th = [1e-1 inf]; % #/cc, threshold for droplet number concentration
rain_n_th = [1e2 inf]; % #/m2
cwp_th = [1e-5 inf]; % kg/m2 cloud water path threshold
rwp_th = [1e-6 inf]; % kg/m2 rain water path threshold
meanD_th = [0 inf];
sppt_th = [0.01 inf]; % mm/hr surface precipitation


%% set the current date as nikki if unset
if ~exist('nikki')
   nikki=datestr(date,'YYYY-mm-dd');
end

%% load these python colormap
Blues = getPyPlot_cMap('Blues',10);
cool5 = getPyPlot_cMap('cool',5);
rainbow = getPyPlot_cMap('rainbow',20);
coolwarm_s = getPyPlot_cMap('coolwarm');
coolwarm = getPyPlot_cMap('coolwarm',10);
coolwarm5 = getPyPlot_cMap('coolwarm',5);
coolwarm_r = getPyPlot_cMap('coolwarm_r',10);
coolwarm_r11 = getPyPlot_cMap('coolwarm_r',11);
ngrad=21;
BrBG5 = getPyPlot_cMap('BrBG',5);
BrBG3 = getPyPlot_cMap('BrBG',3);
BrBG20 = getPyPlot_cMap('BrBG',21);
BrBG = getPyPlot_cMap('BrBG',ngrad)*.9;
BrBG = repelem(BrBG,floor(256/ngrad),1); 

%% initial variables key-values
initvarSet = {'a','w','dm','rh','sp','mc'};
fullnameSet = {'Aerosol concentration', 'Maximum vertical velocity',...
   'Mean mass diameter', 'Relative humidity', 'Shape parameter (\nu)', 'Initial mass content'};
unitSet = {' [1/cc]', ' [m/s]', ' [\mum]', ' [%]', '', ' [g/kg]'};
initVarName_dict = containers.Map(initvarSet, fullnameSet);
initVarUnit_dict = containers.Map(initvarSet, unitSet);

%% mconfig indvar key-values
mconfigSet = {'condnuc', 'condonly', 'collonly', 'sedonly', 'evaponly', ...
              'condcoll', 'collsed', 'evapsed', 'condcollsed', ...
              'collsedevap', 'fullmic'};
indvaridx = {[1 3 6], [1 3 6], [3:7], [2 4 5 7 10], [1 3 6], ...
             [3:7], [3:7 10], [3:7 10], [3:7 10], ...
             [3:7 10], [3:7 10]};
% indvaridx = {[3 6], [3:7 16], [4 5 7 10], [3 6], ...
%              [3:7], [3:7 10], [3:7 10], [3:7 10], ...
%              [3:7 10], [3:8 10]};
mconfigivar_dict = containers.Map(mconfigSet, indvaridx);

%% compare these vars
indvar_name_all = {'diagM3_cloud','diagM3_rain',...
   'cloud_M1_path','rain_M1_path','liq_M1_path',...
   'diagM0_cloud','diagM0_rain',...
   'albedo','opt_dep','mean_surface_ppt','RH',...
   'gs_deltac','gs_sknsc',...
   'gs_deltar','gs_sknsr',...
   'half_life_c',...
   'Dm_c','Dm_r','Dm_w'...
   'dm_cloud_coll','dm_rain_coll','dm_sed',...
   'dm_cloud_ce','dm_rain_ce', ...
   'dqv_adv','cloud_M1_adv','rain_M1_adv',...
   'dtheta_mphys','dqv_mphys','cloud_M1_mphys','rain_M1_mphys',...
   'cloud_M1_mphys','rain_M1_mphys',...
   'reldisp','std_DSD',...
   'oflagc','oflagr',...
   };

indvar_ename_all = {'cloud mass','rain mass',... 2
   'cloud water path','rain water path','liquid water path',... 5
   'cloud number','rain number',... 7
   'albedo','optical depth','mean surface pcpt.','RH'... 11
   'GS delta (c)','GS skewness (c)',... 13 
   'GS delta (r)','GS skewness (r)',... 15
   'cloud half-life',... 16
   'Dm_c','Dm_r','Dm_w'... 19
   'dm cloud by coll','dm rain by coll','dm by sed',... 22
   'dm cloud by CE','dm rain by CE',... 24
   'dqv adv','cloud mass adv','rain mass adv',... 27
   'dtheta mphys','dqv mphys','cloud mass mphys','rain mass mphys',... 31
   'cloud M1 mphys','rain M1 mphys',... 33
   'relative dispersion','standard deviation'... 35
   'flag (cloud)','flag (rain)', ... 37
   };

indvar_units_all = {' [kg/kg]',' [kg/kg]',...
   ' [kg/m^2]',' [kg/m^2]',' [kg/m^2]',...
   ' [1/cc]',' [1/kg]',...
   '','',' [mm/hr]',' %'...
   '','',...
   '','',...
   ' [s]',...
   ' [\mum]',' [\mum]',' [\mum]',...
   ' [kg/kg/s]',' [kg/kg/s]',' [kg/kg/s]',...
   ' [kg/kg/s]',' [kg/kg/s]',...
   ' [kg/kg/s]',' [kg/kg/s]',' [kg/kg/s]',...
   ' [kg/kg/s]',' [kg/kg/s]',' [kg/kg/s]',' [kg/kg/s]',...
   ' [kg/kg/s]',' [kg/kg/s]',...
   '',' [m]'...
   '','',...
   };

var2D_comp=1:5;
indvar2D_name_all = {%'diagM3_cloud','diagM3_rain',...
   'mean_cloud_M1_path','mean_rain_M1_path','mean_liq_M1_path',...
   'mean_albedo','mean_surface_ppt',...
   %    'w',...
   };
indvar2D_ename_all = {%'cloud water','rain water',...
   'mean CWP','mean RWP','mean LWP',...
   'mean albedo','mean surface pcpt.',...
   %    'w',...
   };
indvar2D_units_all = {%' [kg/kg]',' [kg/kg]',...
   ' [kg/m^2]',' [kg/m^2]',' [kg/m^2]',...
   '',' [mm/hr]'
   %    ' [m/s]',...
   };

indvar2D_name_set=indvar2D_name_all(var2D_comp);
indvar2D_ename_set=indvar2D_ename_all(var2D_comp);
indvar2D_units_set=indvar2D_units_all(var2D_comp);

%% additional variables generating animation in AMP_vs_bin_dist
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
