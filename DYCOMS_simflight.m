clearvars -except cmaps
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iab l_da var1_str
close all

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;
mp_plot = 3;
its = 2;

nikki = 'DYCOMS_RF02';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);

var_int_idx = [6 41 42];

obs_fn = 'DYCOMS_II_RF02.nc';
start_dn = datenum([2001,7,11,6,50,0]);

obs_nc = struct;
var_name = {'time_offset','GALT','GLAT','GLON','IRBC','IRTC','DBAR3_RPC',...
   'DBAR6_RWO','DBARF_LPI','DBARP_RPO','DISP6_RWO','DISPF_LPI',...
   'DISPP_RPO','MR','PLWCC'};
for ivar = 1:length(var_name)
   obs_nc.(var_name{ivar}) = ncread(obs_fn, var_name{ivar});
end

mconfig = mconfig_ls{1};
disp(mconfig)

mp_runs = struct;
for iwrap = mp_plot
   disp([wrappers{iwrap} '-' bintype{its}])
   l_da = 0;
   var_interest = get_varint(var_int_idx);
   mps = [wrappers{iwrap} '_' bintype{its}]; % mps = microphysics scheme
   mp_runs.(mps) = loadrams(wrappers{iwrap});
   % make sure that z is never negative
   dz = z(2:end)-z(1:end-1);
   dz(length(z))=dz(end)*1.1;
   z = z+dz;

   t_model_sec = (mp_runs.(mps).time-start_dn)*86400;

   iobs_t = unique(arrayfun(@(x) findInSorted(obs_nc.time_offset,t_model_sec(x)),1:length(t_model_sec)));
   obs_t = obs_nc.time_offset(iobs_t);
   obs_lon = obs_nc.GLON(iobs_t);
   obs_lat = obs_nc.GLAT(iobs_t);
   obs_z = obs_nc.GALT(iobs_t);

   isim_lon = arrayfun(@(x) findInSorted(mp_runs.GLON, obs_lon), 1:length(obs_lon));

end
