function [physquant,note,range] = var2phys(var_raw,ivar,...
   setOOBasNaN,l_flatten)
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
   indvar2D_name

threshold = -inf;

%if ici<=6
var_name=indvar_name{ivar};
%elseif ici>=7
%   var_name=indvar2D_name{ivar};
%end

ispath=0;
isprof=0;
isproc=0;
israin=0;
iscloud=0;

var_raw(var_raw==-999)=nan;

if contains(var_name,{'diag', 'Dm','RH'})
   isprof=1;
elseif contains(var_name,{'path','albedo','mean_surface_ppt','opt_dep'})
   ispath=1;
elseif contains(var_name,{'_ce','adv','coll','sed','mphys'})
   isproc=1;
end

if contains(var_name,'rain')
   israin=1;
elseif contains(var_name,'cloud')
   iscloud=1;
end

switch var_name
   case {'Dm_c', 'Dm_r', 'Dm_w'}
      physquant = var_raw*1e6; % meter -> micron
      threshold = 1;
      note = 'log';
      mask = 'self';
      range = [1 3e3];
   case {'diagM0_cloud'}
      physquant = var_raw/1e6;
      threshold = cloud_n_th(1);
      note = 'log';
      mask = 'self';
      range = [1e-1 1e3];
   case {'diagM0_rain'}
      physquant = var_raw;
      threshold = rain_n_th(1);
      note = 'log';
      mask = 'self';
      range = [1e-3 1e1];
   case {'diagM3_cloud'}
      physquant = var_raw*pi/6*1000;
      threshold = cloud_mr_th(1);
      range = [1e-8 1e-2];
      note = 'log';
      mask = 'self';
   case {'diagM3_rain'}
      physquant = var_raw*pi/6*1000;
      threshold = rain_mr_th(1);
      range = [1e-8 1e-2];
      note = 'log';
      mask = 'self';
   case {'diagmeanD_cloud','diagmeanD_rain'}
      physquant = var_raw;
      threshold = meanD_th(1);
      note = 'log';
      mask = 'self';
   case {'cloud_M1_adv','cloud_M1_mphys'}
      physquant = var_raw;
      bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
      range = [-bound bound];
      %         threshold = cloud_mr_th(1); % the cloud and rain has the same threshold for now
      note = 'lin';
      mask = 'self'; % use cloud mass as threshold
   case {'rain_M1_adv','rain_M1_mphys'}
      physquant = var_raw;
      %         threshold = rain_mr_th(1);
      bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
      range = [-bound bound];
      note = 'lin';
      mask = 'self';
   case {'RH_ice','w','temperature','theta','pressure'}
      physquant = var_raw;
      mask = 'M3tomass';
      note = 'lin';
      range = 0;
   case {'cloud_M1_path','mean_cloud_M1_path'}
      physquant = var_raw*pi/6*1000;
      threshold = cwp_th(1);
      bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
      range = [-bound bound];
      note = 'log';
      mask = 'self';
   case {'rain_M1_path','mean_rain_M1_path'}
      physquant = var_raw*pi/6*1000;
      threshold = rwp_th(1);
      bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
      range = [-bound bound];
      note = 'log';
      mask = 'self';
   case 'mean_surface_ppt'
      physquant = var_raw*3600;
      threshold = sppt_th(1);
      bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
      range = [-bound bound];
      note = 'log';
      mask = 'self';
   case 'Dm'
      physquant = var_raw;
      mask = 'M3tomass';
      note = 'lin';
      range = [1e-4 1e-2];
   case 'dqv_adv'
      physquant = var_raw;
      range = [1e-10 3e-5];
      mask = 'self';
      note = 'lin';
   case 'dtheta_mphys'
      physquant = var_raw;
      range = [-0.05 .05];
      mask = 'self';
      note = 'lin';
   case 'dqv_mphys'
      physquant = var_raw;
      range = [-3e-5 3e-5];
      mask = 'self';
      note = 'lin';
   case 'vapour'
      physquant = var_raw;
      range = [.002 .02];
      mask = 'self';
      note = 'lin';
   case 'RH'
      physquant = var_raw;
      range = [30 100];
      mask = 'self';
      note = 'lin';
   case {'flagoobc', 'flagoobr'}
      physquant = var_raw;
      range = [1e-3 1e3];
      mask = 'self';
      note = 'log';
   case {'dm_cloud_ce', 'dm_rain_ce', 'dm_cloud_coll', 'dm_rain_coll',...
         'dm_sed'}
      physquant = var_raw;
      bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
      range = [-bound bound];
      note = 'lin';
      mask = 'self';
      threshold = -998;
      %     case 'cloud_M1_path'
      %         physquant = var_raw;
      %         range = [0 2e-3];
      %         mask = 'self';
      %         note = 'lin';
      %     case 'rain_M1_path'
      %         physquant = var_raw;
      %         range = [0 1e-5];
      %         mask = 'self';
      %         note = 'lin';
   otherwise
      physquant = var_raw;
      note = 'log';
      mask = 'self';
      range = [];
end

if setOOBasNaN
   if strcmp(mask,'self')
      physquant(physquant<threshold)=nan;
   elseif strcmp(mask,'M3tomass')
      physquant(physquant*pi/6*1000<threshold)=nan;
   elseif strcmp(mask,'M1tonum')
      physquant(physquant/1e6<threshold)=nan;
   end
end

if ~setOOBasNaN
   if strcmp(mask,'self')
      physquant(physquant<threshold)=0;
   elseif strcmp(mask,'M3tomass')
      physquant(physquant*pi/6*1000<0)=0;
   elseif strcmp(mask,'M1tonum')
      physquant(physquant/1e6<0)=0;
   end
end

if ~exist('l_flatten','var') || isempty(l_flatten)
   l_flatten=0; %#ok<*NASGU>
end

if l_flatten
   physquant=physquant(:);
end

end
