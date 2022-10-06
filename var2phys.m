function [physquant,note,range] = var2phys(var_raw, ivar, ...
   setOOBasNaN, th_mask, l_flatten)
% converts raw variables into physical quantities
% formula: [physquant,addnote] = var2phys(var_raw,var_name,note)
% INPUT:
% var_raw: raw variable directly out of the nc file
% ivar: the index of the raw variable (list specified in global_var.m)
% l_flatten: (optional) whether to flatten the output for non-plotting
% purposes. (e.g., analyzing the performance of simulation)
% OUTPUT:
% physquant: the physical quantities after conversion. not all are
% converted.
%       units: M0 -> cc^-1;
%              M3 -> kg/kg;
% note: a variable-specific note, such as being plotted in 'log' or 'lin'.

global indvar_name cloud_n_th rain_n_th cloud_mr_th rain_mr_th meanD_th ...
   cwp_th rwp_th ispath isprof isproc israin iscloud sppt_th ...
   indvar2D_name casenum

threshold = -inf;

if casenum<200
   var_name=indvar_name{ivar};
else
   var_name=indvar2D_name{ivar};
end

ispath=0;
isprof=0;
isproc=0;
israin=0;
iscloud=0;

var_raw(var_raw==-999)=nan;

if contains(var_name,{'adv','mphys','dm_','dn_','diag', ...
      'Dm','RH','gs_','reldisp','flag','ss_w','temperature',...
      'ss_wpremphys', 'Dn_c', 'Dn_r','nu_','coll','sed'})
   isprof=1;
elseif contains(var_name,{'path','albedo','mean_surface_ppt','opt_dep'})
   ispath=1;
% elseif contains(var_name,{'coll','sed'})
%    isproc=1;
end

if contains(var_name,'rain')
   israin=1;
elseif contains(var_name,'cloud')
   iscloud=1;
end

switch var_name
   case {'oflagc','oflagr'}
      physquant = var_raw;
      note = 'lin';
      unit_conv = 'self';
      range = [-1 1];
   case {'gs_deltac','gs_sknsc'}
      physquant = var_raw;
      threshold = cloud_mr_th(1);
      note = 'log';
      unit_conv = 'self';
      range = [.67 1.5];
   case {'gs_deltar','gs_sknsr'}
      physquant = var_raw;
      threshold = rain_mr_th(1);
      note = 'log';
      unit_conv = 'self';
      range = [0.8 1.25];
   case {'Dm_c', 'Dm_r', 'Dm_w'}
      physquant = var_raw*1e6; % meter -> micron
      threshold = 1;
      note = 'log';
      unit_conv = 'self';
      range = [1 3e3];
   case {'diagM0_cloud'}
      physquant = var_raw/1e6;
      threshold = cloud_n_th(1);
      note = 'log';
      unit_conv = 'self';
      range = [1e-1 1e3];
   case {'diagM0_rain'}
      physquant = var_raw;
      threshold = rain_n_th(1);
      note = 'log';
      unit_conv = 'self';
      range = [1e2 1e6];
   case {'diagM3_cloud'}
      physquant = var_raw*pi/6*1000;
      threshold = cloud_mr_th(1);
      range = [1e-8 1e-2];
      note = 'log';
      unit_conv = 'self';
   case {'diagM3_rain'}
      physquant = var_raw*pi/6*1000;
      threshold = rain_mr_th(1);
      range = [1e-8 1e-2];
      note = 'log';
      unit_conv = 'self';
   case {'diagmeanD_cloud','diagmeanD_rain'}
      physquant = var_raw;
      threshold = meanD_th(1);
      note = 'log';
      unit_conv = 'self';
   case {'cloud_M1_adv','cloud_M1_mphys','cloud_M2_adv','cloud_M2_mphys',...
         'cloud_M3_adv','cloud_M3_mphys','cloud_M4_adv','cloud_M4_mphys',...
         'cloud_M1_force','cloud_M2_force','cloud_M3_force','cloud_M4_force'}
      physquant = var_raw;
      bound=10^(ceil(log10(max(abs(physquant(2:end,:)),[],'all'))*2)/2);
      range = [-bound bound];
      %         threshold = cloud_mr_th(1); % the cloud and rain has the same threshold for now
      note = 'lin';
      unit_conv = 'self'; % use cloud mass as threshold
   case {'rain_M1_adv','rain_M1_mphys','rain_M2_adv','rain_M2_mphys',...
         'rain_M3_adv','rain_M3_mphys','rain_M4_adv','rain_M4_mphys',...
         'rain_M1_force','rain_M2_force','rain_M3_force','rain_M4_force'}
      physquant = var_raw;
      %         threshold = rain_mr_th(1);
      bound=10^(ceil(log10(max(abs(physquant(2:end,:)),[],'all'))*2)/2);
      range = [-bound bound];
      note = 'lin';
      unit_conv = 'self';
   case {'cloud_M1_path','mean_cloud_M1_path'}
      physquant = var_raw*pi/6*1000;
      threshold = cwp_th(1);
      bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
      range = [-bound bound];
      note = 'log';
      unit_conv = 'self';
   case {'rain_M1_path','mean_rain_M1_path'}
      physquant = var_raw*pi/6*1000;
      threshold = rwp_th(1);
      bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
      range = [-bound bound];
      note = 'log';
      unit_conv = 'self';
   case 'mean_surface_ppt'
      physquant = var_raw*3600;
      threshold = sppt_th(1);
      bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
      range = [-bound bound];
      note = 'log';
      unit_conv = 'self';
   case 'Dm'
      physquant = var_raw;
      unit_conv = 'M3tomass';
      note = 'lin';
      range = [1e-4 1e-2];
   case 'dqv_adv'
      physquant = var_raw;
      range = [1e-10 3e-5];
      unit_conv = 'self';
      note = 'lin';
   case 'dtheta_mphys'
      physquant = var_raw;
      range = [-0.05 .05];
      unit_conv = 'self';
      note = 'lin';
   case 'dqv_mphys'
      physquant = var_raw;
      range = [-3e-5 3e-5];
      unit_conv = 'self';
      note = 'lin';
   case 'vapour'
      physquant = var_raw;
      range = [.002 .02];
      unit_conv = 'self';
      note = 'lin';
   case {'RH', 'RH_premphys'}
      physquant = var_raw;
      range = [30 100];
      unit_conv = 'self';
      note = 'lin';
   case {'Dn_c', 'Dn_r'}
      physquant = var_raw*1e6;
      range = [min(physquant(physquant>0)) 1e5];
      note = 'log';
      unit_conv = 'self';
   case {'flagoobc', 'flagoobr'}
      physquant = var_raw;
      range = [1e-3 1e3];
      unit_conv = 'self';
      note = 'log';
   case {'dm_cloud_ce', 'dm_rain_ce', 'dm_cloud_coll', 'dm_rain_coll',...
         'dm_sed'}
      physquant = var_raw;
      bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
      range = [-bound bound];
      note = 'lin';
      unit_conv = 'self';
      threshold = -998;
      %     case 'cloud_M1_path'
      %         physquant = var_raw;
      %         range = [0 2e-3];
      %         unit_conv = 'self';
      %         note = 'lin';
      %     case 'rain_M1_path'
      %         physquant = var_raw;
      %         range = [0 1e-5];
      %         unit_conv = 'self';
      %         note = 'lin';
   case 'reldisp'
      physquant = var_raw;
      range = [0 1];
      unit_conv = 'self';
      note = 'lin';
   case {'ss_w', 'ss_wpremphys'}
      physquant = var_raw;
      range = [min(physquant(:)) max(physquant(:))];
      unit_conv = 'self';
      note = 'lin';
   case {'nu_c','nu_r'}
      physquant = var_raw;
      range = [-10 40];
      unit_conv = 'self';
      note = 'lin';
   otherwise
      physquant = var_raw;
      note = 'log';
      unit_conv = 'self';
      range = [min(physquant(:)) max(physquant(:))];
end

if setOOBasNaN
   if strcmp(unit_conv,'self')
      physquant(physquant<threshold)=nan;
   elseif strcmp(unit_conv,'M3tomass')
      physquant(physquant*pi/6*1000<threshold)=nan;
   elseif strcmp(unit_conv,'M1tonum')
      physquant(physquant/1e6<threshold)=nan;
   end
else
   if strcmp(unit_conv,'self')
      physquant(physquant<threshold)=0;
   elseif strcmp(unit_conv,'M3tomass')
      physquant(physquant*pi/6*1000<threshold)=0;
   elseif strcmp(unit_conv,'M1tonum')
      physquant(physquant/1e6<threshold)=0;
   end
end

if exist('th_mask','var') && all(size(th_mask) == size(var_raw))
   physquant(~th_mask) = nan;
end

if ~exist('l_flatten','var') || isempty(l_flatten)
   l_flatten=0; %#ok<*NASGU>
end

if l_flatten
   physquant=physquant(:);
end

end
