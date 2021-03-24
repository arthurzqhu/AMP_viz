function [physquant,note,range] = var2phys(var_raw,ivar,stct,setOOBasNaN)
% converts raw variables into physical quantities
% formula: [physquant,addnote] = var2phys(var_raw,var_name,note)
% INPUT:
% var_raw: raw variable directly out of the nc file
% var_name: the name of the raw variable directly out of the nc file
% OUTPUT:
% physquant: the physical quantities after conversion. might not be
% converted. 
%       units: M0 -> cc^-1;
%              M3 -> kg/kg;
% note: a variable-specific note, such as being plotted in 'log' or 'lin'.

global indvar_name cloud_n_th rain_n_th cloud_mr_th rain_mr_th meanD_th

threshold = -inf;
var_name=indvar_name{ivar};

diagM0_cloud=stct.diagM0_cloud;
diagM3_cloud=stct.diagM3_cloud;
diagM0_rain=stct.diagM0_rain;
diagM3_rain=stct.diagM3_rain;

switch var_name
    case {'diagM0_cloud'}
        physquant = var_raw/1e6;
        threshold = cloud_n_th(1);
        note = 'log';
        mask = 'self';
        range = [1e-1 1e3];
    case {'diagM0_rain'}
        physquant = var_raw/1e6;
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
        mask = 'cloudmass'; 
        note = 'lin';
        range = 0;
    case 'cloud_M1_path'
        physquant = var_raw*pi/6*1000;
        bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
        range = [-bound bound];
        note = 'log';
        mask = 'cloudmass'; % use cloud mass as threshold
    case 'rain_M1_path'
        physquant = var_raw*pi/6*1000;
        bound=10^(ceil(log10(max(abs(physquant(:))))*2)/2);
        range = [-bound bound];
        note = 'log';
        mask = 'rainmass';
    case 'Dm'
        physquant = var_raw;
        mask = 'cloudmass';
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
        range = [80 110];
        mask = 'self'; 
        note = 'lin';
    case {'flagoobc', 'flagoobr'}
        physquant = var_raw;
        range = [1e-3 1e3];
        mask = 'self';
        note = 'log';
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
    elseif strcmp(mask,'cloudmass')
        physquant(diagM3_cloud*pi/6*1000<threshold)=nan;
    elseif strcmp(mask,'rainmass')
        physquant(diagM3_rain*pi/6*1000<threshold)=nan;
    elseif strcmp(mask,'cloudnum')
        physquant(diagM0_cloud/1e6<threshold)=nan;
    elseif strcmp(mask,'rainnum')
        physquant(diagM0_rain/1e6<threshold)=nan;
    end
end

end