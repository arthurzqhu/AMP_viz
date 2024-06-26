global cloud_n_th rain_n_th cloud_mr_th rain_mr_th meanD_th ...
   l_amp l_sbm indvar_name_set indvar_ename_set indvar_units_set ...
   cwp_th rwp_th sppt_th indvar2D_name_set indvar2D_ename_set indvar2D_units_set ...
   color_order indvar_name_all indvar_ename_all indvar_units_all ...
   split_bins col amp_only_var mconfigSet indvaridx cmaps script_name islink ...
   summ_dir

indvar_name_set = {};
indvar_ename_set = {};
indvar_units_set = {};

%% bin cloud-rain threshold
split_bins = [15 14];

%% constants
col = log(2)/3;
% binmean(1,:) = load('diamg_tau.txt');
% binmean(2,1:33) = load('diamg_sbm.txt');

%% model configs
ampORbin = {'amp' 'bin'};
bintype = {'tau' 'sbm'};

%% determine if the file is linked
islink = ~unix(['test -L ',script_name,'.m']);

%% dir of the model output
if strcmp(computer('arch'),'maci64')
   output_dir='/Users/arthurhu/research outputs/';
elseif strcmp(computer('arch'),'glnxa64')
   if islink % if the script running is a symlink, then it's probably in a shared folder
      output_dir='../UvsS_KiD/';
      summ_dir='../summary_mat/';
      score_dir='../summary_mat/';
   else
      output_dir='/home/arthurhu/KiD/';
      summ_dir='pfm_summary/';
      score_dir='score_summary/';
   end
   sp_combo=readmatrix('~/github/KiD_repo/KiD_1mode_gam/sp_combo.csv');

   % Convert the matrix to a cell of sp_combo_str
   sp_combo_str = cellstr(num2str(sp_combo, '%g '));
   % Remove leading spaces and replace spaces with a dash
   for i = 1:length(sp_combo_str)
      % Remove leading and trailing spaces
      sp_combo_str{i} = strtrim(sp_combo_str{i});
      % Replace one or more spaces with a dash
      sp_combo_str{i} = regexprep(sp_combo_str{i}, '\s+', '-');
   end

end


%% KiD cases
case_list_num = [101 102 103 105 106 107 601 602];
case_list_str = arrayfun(@(x) num2str(case_list_num(x)), 1:length(case_list_num),...
   'UniformOutput', false);


%% thresholds to be considered as clouds 
cloud_mr_th = [1e-7 1e-2]; % kg/kg, threshold for mixing ratio (kg/kg)
rain_mr_th = [1e-7 1e-2];
lwc_mr_th = [1e-7 1e-2];
cloud_n_th = [1e-1 inf]; % #/cc, threshold for droplet number concentration
rain_n_th = [1e2 inf]; % #/m2
cwp_th = [1e-5 inf]; % kg/m2 cloud water path threshold
rwp_th = [1e-4 inf]; % kg/m2 rain water path threshold
meanD_th = [0 inf];
sppt_th = [0.1 inf]; % mm/hr surface precipitation
mean_rwp_th = [0.1 inf];
mean_rn_th = [50 inf];


%% set the current date as nikki if unset
if ~exist('nikki')
   nikki=datestr(date,'YYYY-mm-dd');
end

%% load these python colormap
ngrad=21;
if ~exist('cmaps','var') || isempty(cmaps)
   load('cmaps.mat')
   % cmaps.Blues = getPyPlot_cMap('Blues',10);
   % cmaps.Blues_s = getPyPlot_cMap('Blues');
   % cmaps.cool5 = getPyPlot_cMap('cool',5);
   % cmaps.rainbow = getPyPlot_cMap('rainbow',20);
   % cmaps.coolwarm_s = getPyPlot_cMap('coolwarm');
   % cmaps.coolwarm = getPyPlot_cMap('coolwarm',10);
   % cmaps.coolwarm5 = getPyPlot_cMap('coolwarm',5);
   % cmaps.coolwarm3 = getPyPlot_cMap('coolwarm',3);
   % cmaps.coolwarm_r = getPyPlot_cMap('coolwarm_r',10);
   % cmaps.coolwarm_r11 = getPyPlot_cMap('coolwarm_r',11);
   % cmaps.coolwarm_rs = getPyPlot_cMap('coolwarm_r');
   % cmaps.flag3(1,:) = [1, 1, 1];
   % cmaps.flag3 = cmaps.coolwarm_r11([6 9 2],:);
   % cmaps.flag5 = getPyPlot_cMap('coolwarm',5);
   % cmaps.BrBG_s = getPyPlot_cMap('BrBG');
   % cmaps.BrBG5 = getPyPlot_cMap('BrBG',5);
   % cmaps.BrBG3 = getPyPlot_cMap('BrBG',3);
   % cmaps.BrBG20 = getPyPlot_cMap('BrBG',21);
   % cmaps.BrBG = getPyPlot_cMap('BrBG',ngrad)*.9;
   % cmaps.BrBG = repelem(cmaps.BrBG,floor(256/ngrad),1); 
   % cmaps.magma = getPyPlot_cMap('magma');
   % cmaps.magma10 = getPyPlot_cMap('magma',10);
   % cmaps.magma_r = getPyPlot_cMap('magma_r');
   % cmaps.magma_r10 = getPyPlot_cMap('magma_r',10);
   % cmaps.viridis = getPyPlot_cMap('viridis');
   % cmaps.copper_r = getPyPlot_cMap('copper_r');
end

%% initial variables key-values
initvarSet = {'a','w','dm','rh','sp','mc','cm','dmr','pmomx','pmomy','spc','spr',...
   'pmomxy','dz','Na','spcr','sprc'};
fullnameSet = {'Aerosol concentration', 'Maximum vertical velocity',...
   'Mean mass diameter', 'Relative humidity', 'Shape parameter (\nu)', ...
   'Initial mass content','Cloud mass','Mean mass diameter (rain)',...
   'Predicted Moment X', 'Predicted Moment Y','Shape parameter (L1)', ...
   'Shape parameter (L2)','Predicted Moments M_x-M_y','Cloud thickness','Aerosol Concentration',...
   'Assumed Shape Parameter \nu_1-\nu_2','Shape parameter \nu_2-\nu_1'};
symbolSet = {'N_a', 'w_{max}', 'D_m', 'RH', '\nu', 'm_i', 'm_c', 'D_mr','M^p_x',...
   'M^p_y','\nu_c','\nu_r','M^p_{xy}','\Deltaz cloud','N_a','nu_1-nu_2','nu_2-nu_1'};
unitSet = {' [/mg]', ' [m/s]', ' [\mum]', ' [%]', '', ' [g/kg]', ' [g/kg]', ...
   ' [\mum]', '', '','','','',' [m]',' [/mg]','',''};
initVarName_dict = containers.Map(initvarSet, fullnameSet);
initVarSymb_dict = containers.Map(initvarSet, symbolSet);
initVarUnit_dict = containers.Map(initvarSet, unitSet);

%% mconfig indvar key-values
mconfigSet = {'condnuc', 'condonly', 'collonly', 'sedonly', 'evaponly', ...
              'condcoll', 'collsed', 'evapsed', 'condcollsed', ...
              'collsedevap', 'fullmic',...
              };
indvaridx = {[3 6], [3 6], [4 21 40 41], [4 5 7 10], [3 4], ...
             [3 4], [3 4 10], [3:7 10], [3 4 10], ...
             [3 4 5 10], [3 4 5 10 18],...
             };

% ok perhaps better combines these three variables into an object but too much work for now...
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
   'dm_cloud_ce','dm_rain_ce', 'dm_ce' ...
   'dn_cloud_ce','dn_rain_ce', 'dn_ce' ...
   'dqv_adv','cloud_M1_adv','rain_M1_adv',...
   'dtheta_mphys','dqv_mphys','cloud_M1_mphys','rain_M1_mphys',...
   'cloud_M1_mphys','rain_M1_mphys',...
   'reldisp','std_DSD',...
   'oflagc','oflagr',...
   'ss_w','ss_wpremphys','RH_premphys',...
   'dm_nuc',...
   'Dn_c', 'Dn_r', ...
   'cloud_M1', 'cloud_M2', 'cloud_M3', 'cloud_M4', ...
   'cloud_M1_mphys', 'cloud_M2_mphys', 'cloud_M3_mphys', 'cloud_M4_mphys', ...
   'cloud_M1_adv', 'cloud_M2_adv', 'cloud_M3_adv', 'cloud_M4_adv', ...
   'cloud_M1_force', 'cloud_M2_force', 'cloud_M3_force', 'cloud_M4_force', ...
   'rain_M1', 'rain_M2', 'rain_M3', 'rain_M4', ...
   'rain_M1_mphys', 'rain_M2_mphys', 'rain_M3_mphys', 'rain_M4_mphys', ...
   'rain_M1_adv', 'rain_M2_adv', 'rain_M3_adv', 'rain_M4_adv', ...
   'rain_M1_force', 'rain_M2_force', 'rain_M3_force', 'rain_M4_force', ...
   'nu_c', 'nu_r', ...
   'diagM0_liq', 'diagM3_liq',...
   };

indvar_ename_all = {'CWC','RWC',... 2
   'CWP','RWP','LWP',... 5
   'cloud number','rain number',... 7
   'albedo','optical depth','surface pcpt. rate','RH'... 11
   'GS delta (c)','GS skewness (c)',... 13 
   'GS delta (r)','GS skewness (r)',... 15
   'cloud half-life',... 16
   'mean cloud droplet size','mean raindrop size','D_{m,w}'... 19
   'dm cloud by coll','dm_{r,coll}','dm by sed',... 22
   'dm cloud by CE','dm rain by CE', 'dm liq by CE'... 25
   'dn cloud by CE','dn rain by CE', 'dn liq by CE'... 28
   'dqv adv','cloud mass adv','rain mass adv',... 31
   'dtheta mphys','dqv mphys','cloud mass mphys','rain mass mphys',... 35
   'cloud M1 mphys','rain M1 mphys',... 37
   'relative dispersion','standard deviation'... 39
   'flag (cloud)','flag (rain)', ... 41
   'supersaturation', 'SS pre-mphys', 'RH pre-mphys',... 44
   'dm by nuc', ... 45
   'Dn_c', 'Dn_r', ... 47
   'cloud mass', 'cloud number', 'cloud M3', 'cloud M4', ... 51
   'cloud mass mphys', 'cloud number mphys', 'cloud M3 mphys', 'cloud M4 mphys', ... 55
   'cloud mass adv', 'cloud number adv', 'cloud M3 adv', 'cloud M4 adv', ... 59
   'cloud mass force', 'cloud number force', 'cloud M3 force', 'cloud M4 force', ... 63
   'rain mass', 'rain number', 'rain M3', 'rain M4', ... 67
   'rain mass mphys', 'rain number mphys', 'rain M3 mphys', 'rain M4 mphys', ... 71
   'rain mass adv', 'rain number adv', 'rain M3 adv', 'rain M4 adv', ... 75
   'rain mass force', 'rain number force', 'rain M3 force', 'rain M4 force', ... 79
   'nu_c', 'nu_r', ... 81
   'liquid number', 'LWC'... 83
   };

indvar_units_all = {' [kg/kg]',' [kg/kg]',...
   ' [kg/m^2]',' [kg/m^2]',' [kg/m^2]',...
   ' [1/cc]',' [1/kg]',...
   '','',' [mm/hr]',' [%]'...
   '','',...
   '','',...
   ' [s]',...
   ' [\mum]',' [\mum]',' [\mum]',...
   ' [kg/kg/s]',' [kg/kg/s]',' [kg/kg/s]',...
   ' [kg/kg/s]',' [kg/kg/s]',' [kg/kg/s]',...
   ' [1/kg/s]',' [1/kg/s]',' [1/kg/s]',...
   ' [kg/kg/s]',' [kg/kg/s]',' [kg/kg/s]',...
   ' [kg/kg/s]',' [kg/kg/s]',' [kg/kg/s]',' [kg/kg/s]',...
   ' [kg/kg/s]',' [kg/kg/s]',...
   '',' [m]'...
   '','',...
   ' [%]',' [%]',' [%]',...
   ' [kg/kg/s]',...
   ' [\mum]', ' [\mum]', ...
   '', '', '', '', ...
   '', '', '', '', ...
   '', '', '', '', ...
   '', '', '', '', ...
   '', '', '', '', ...
   '', '', '', '', ...
   '', '', '', '', ...
   '', '', '', '', ...
   '','',...
   ' [1/cc]', ' [kg/kg]'...
   };


amp_only_var = {'flag','Dn_', '_M2', '_M3', '_M4','nu_'};

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

momcombo_trimmed = {};
momx = [1 2 4 5 6 7 8 9];
momy = [1 2 4 5 6 7 8 9];
imc = 0;

for imomx = 1:length(momx)
   for imomy = imomx+1:length(momy)
      imc = imc + 1;
      momcombo_trimmed{imc} = [num2str(momx(imomx)), '-', num2str(momy(imomy))];
   end
end

Alphabet = 'abcdefghijklmnopqrstuvwxyz';

clear colororder momx momy imc
