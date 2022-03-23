global thhd cmap pio6rw


% model configs
addpath('ramsfuncs/')
ampORbin={'amp' 'bin'};
bintype={'tau' 'sbm'};

pio6rw=3.1415926535/6*1000;

% thresholds to be considered as clouds 
thhd.cloud_mr_th=[1e-10 1e-2]; % kg/kg, threshold for mixing ratio (kg/kg)
thhd.rain_mr_th=[1e-10 1e-2];
thhd.cloud_n_th=[1e-1 inf]; % #/cc, threshold for droplet number concentration
thhd.rain_n_th=[1e-4 inf];
thhd.cwp_th=[1e-5 inf]; % kg/m2 cloud water path threshold
thhd.rwp_th=[1e-6 inf]; % kg/m2 rain water path threshold
thhd.meanD_th=[0 inf];
thhd.sppt_th=[0 inf]; % mm/hr surface precipitation


% set the current date as nikki if unset
if ~exist('nikki')
    nikki=datestr(date,'YYYY-mm-dd');
end

% dir of the model output
% output_dir='/Volumes/ESSD/AMP output/';
output_dir='../rams/output/';

% load these python colormap
cmap.Blues=getPyPlot_cMap('Blues',10);
cmap.rainbow=getPyPlot_cMap('rainbow',20);
cmap.coolwarm=getPyPlot_cMap('coolwarm',10);
cmap.coolwarm_r=getPyPlot_cMap('coolwarm_r',10);
ngrad=21;
cmap.BrBG20=getPyPlot_cMap('BrBG',20);
cmap.BrBG=getPyPlot_cMap('BrBG',ngrad)*.9;
cmap.BrBG=repelem(cmap.BrBG,floor(256/ngrad),1); 

colororder=colororder;
color_order={};
for i=1:size(colororder,1)
    color_order{i}=colororder(i,:);
end

clear colororder

var_name_set={'CWP','RWP','LWP','Rv','RH','LWC'};
var_ename_set={'cloud water path','rain water path','liquid water path',...
               'mixing ratio','relative humidity','liquid water content'};
var_req_set={{'RCP'},{'RRP'},{'RCP','RRP'},{'RV'},{'RV'},{'RCP','RRP'}};
var_unit_set={' [kg/m^2]', ' [kg/m^2]',' [kg/m^2]', ' [kg/kg]',' %',' [kg/kg]'};
