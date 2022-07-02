global thhd cmap pio6rw nikki output_dir var_name_set var_ename_set ...
   var_req_set var_unit_set var_range var_linORlog l_da ampORbin bintype ...
   conf2grid

% model configs
addpath('ramsfuncs/')
ampORbin={'amp' 'bin'};
bintype={'tau' 'sbm'};

pio6rw=3.1415926535/6*1000;

% thresholds to be considered as clouds 
thhd.cloud_mr_th=[1e-7 1e-2]; % g/kg, threshold for mixing ratio
thhd.rain_mr_th=[1e-8 1e-2];
thhd.cloud_n_th=[1e-1 inf]; % #/cc, threshold for droplet number concentration
thhd.rain_n_th=[1e-4 inf];
thhd.cwp_th=[1 inf]; % g/m2 cloud water path threshold
thhd.rwp_th=[1e-1 inf]; % g/m2 rain water path threshold
thhd.meanD_th=[0 inf];
thhd.sppt_th=[0 inf]; % mm/hr surface precipitation

% set the current date as nikki if unset
if ~exist('nikki')
    nikki=datestr(date,'YYYY-mm-dd');
end

% convert iconf to grid location
conf2grid = {[1,1], [1,2], [1,3], [1,4], ...
                    [2,2], [2,3], [2,4], ...
                           [3,3], [3,4], ...
                                  [4,4]};

% dir of the model output
% output_dir='/Volumes/ESSD/AMP output/';
output_dir='../github/rams/output/';

% load these python colormap
cmap.Blues=getPyPlot_cMap('Blues',10);
cmap.rainbow=getPyPlot_cMap('rainbow',20);
cmap.coolwarm=getPyPlot_cMap('coolwarm',10);
cmap.coolwarm_r=getPyPlot_cMap('coolwarm_r',10);
cmap.coolwarm_r11=getPyPlot_cMap('coolwarm_r',11);
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

var_name_set = {'CWP','RWP','LWP',...
                'Rv','RH','LWC',...
                'CWC','RWC',...
                'DSDm', 'DSDn','reldisp'};
var_ename_set = {'cloud water path','rain water path','liquid water path',... 3
                 'mixing ratio','relative humidity','liquid water content',... 6
                 'cloud water content','rain water content',... 8
                 'DSD mass', 'DSD number', 'relative dispersion'... 11
                 };
var_req_set = {{'RCP'},{'RRP'},{'RCP','RRP'},...
               {'RV'},{'RV'},{'RCP','RRP'}, ...
               {'RCP'},{'RRP'},...
               {'FFCD'},{'FFCDN'},{'RELDISP'}};
var_unit_set = {' [g/m^2]', ' [g/m^2]',' [g/m^2]', ...
                ' [kg/kg]',' %',' [g/kg]', ...
                ' [g/kg]', ' [g/kg]', ...
                ' [kg/kg]', ' [1/kg]', ''};
var_range = {[],[],[], ...
             [],[],[1e-3 3e-1], ...
             [1e-3 3e-1], [1e-5 1e-3], ...
             [],[],[0 1]};
var_linORlog = {'log', 'log', 'log', ...
                'lin', 'lin', 'log', ...
                'log', 'log', ...
                'log', 'log', 'lin'};


% output dir for the figures
plot_dir=['plots/rams/' nikki '/'];
if ~exist(['plots/rams/' nikki '/'],'dir')
   mkdir(['plots/rams/' nikki '/'])
end
