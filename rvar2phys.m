function mpdat = rvar2phys(var_interest, l_da_arr, snap)

global nfile filedir runs mp_list deltaz density binmean bintype its mp_str

   threshold = -inf;
   
   % ispath=0;
   % isprof=0;
   % isproc=0;
   % israin=0;
   % iscloud=0;

   istart=1; % analysis starts from ...
   
   % load all the required variables
   var_req_uniq = unique(horzcat(var_interest.prereq_vars));
   if isempty(snap)
      % rams_hdf5c(var_req_uniq,istart-1:10:nfile-1,filedir)
      rams_hdf5c(var_req_uniq,istart-1:nfile-1,filedir)
   else
      rams_hdf5c(var_req_uniq,snap,filedir)
   end
   
   if contains(bintype{its},'tau')
      binmean = load('tau_binmean.txt')*2;
   elseif contains(bintype{its},'sbm')
      binmean = load('sbm_binmean.txt')*2;
   end
   
   % 
   loaded_varname = {}; % record what variables are already loaded
   loaded_var = struct;
   % density = rho(runs.THETA, runs.PI);
   density = 1.1;
   
   mpdat.time=runs.time;
   for ivar = 1:length(var_interest)
      if length(l_da_arr) > 1
         l_da = l_da_arr(ivar);
      else
         l_da = l_da_arr;
      end
   
      [loaded_var, loaded_varname] = loadvar(var_interest(ivar), loaded_var, loaded_varname);
      % load variables needed, including those for domain averaged vals
      % loadvar can check whether the dependent variables are already
      % loaded, and load them only if necesssary
      if l_da == 1
         mpdat.(var_interest(ivar).da_name) = ...
            calc_domainavg(loaded_var.(var_interest(ivar).var_name));
      elseif l_da == 2
         % only pick the center of domain for vars like DSD
         var_dim = size(loaded_var.(var_interest(ivar).var_name));
         y_pick = 50;
         x_pick = 50;
         % x_pick = ceil(var_dim(1)/2);
         % y_pick = ceil(var_dim(2)/2);
         mpdat.(var_interest(ivar).da_name) = ...
            squeeze(loaded_var.(var_interest(ivar).var_name)(x_pick, y_pick, :, :, :));
      elseif l_da == 3
         x_pick = 50;
         mpdat.(var_interest(ivar).da_name) = ...
            squeeze(loaded_var.(var_interest(ivar).var_name)(x_pick, :, :, :));
            % squeeze(mean(loaded_var.(var_interest(ivar).var_name),1));
      % elseif l_da == 4
      %    mpdat.(var_interest(ivar).da_name) = ...
      %       squeeze(nanmean(loaded_var.(var_interest(ivar).var_name)(:,:,:,2),[1,2,4]));
      else
         mpdat.(var_interest(ivar).var_name) = ...
            loaded_var.(var_interest(ivar).var_name);
      end
   end
end


function [loaded_var, loaded_varname] = loadvar(varin_obj,loaded_var,loaded_varname)
% update the loaded_var (struct) and loaded_varname (cell)
global runs deltaz density binmean thhd

   switch varin_obj.var_name
      case "LWP"
         var_to_read = {'CWP','RWP'};
      case "LWC"
         var_to_read = {'CWC','RWC'};
      case "liqprof"
         var_to_read = {'cloudprof','rainprof'};
      otherwise
         var_to_read = {varin_obj.var_name};
   end
   
   for ivar = 1:length(var_to_read)
      varname = var_to_read{ivar};
      if ismember(varname,loaded_varname)
         % skip if already loaded
         continue
      end

      switch varname
         case 'CWC'
            loaded_var.(varname) = 1e3*runs.RCP;
         case 'RWC'
            loaded_var.(varname) = 1e3*runs.RRP;
         case 'CWP'
            loaded_var.(varname) = 1e3*deltaz*squeeze(sum(runs.RCP.*density,3));
         case 'RWP'
            loaded_var.(varname) = 1e3*deltaz*squeeze(sum(runs.RRP.*density,3));
         case 'CNP'
            loaded_var.(varname) = deltaz*squeeze(sum(runs.CCP.*density,3));
         case 'RNP'
            loaded_var.(varname) = deltaz*squeeze(sum(runs.CRP.*density,3));
         case 'RH'
            loaded_var.(varname) = rh(runs.RV,runs.THETA,runs.PI);
         case 'SS'
            loaded_var.(varname) = rh(runs.RV,runs.THETA,runs.PI)-100;
         case 'pres'
            loaded_var.(varname) = press(runs.PI);
         case 'temp'
            loaded_var.(varname) = temp(runs.THETA, runs.PI);
         case 'SW_net'
            loaded_var.(varname) = runs.SWDN-runs.SWUP;
         case 'LW_net'
            loaded_var.(varname) = runs.LWDN-runs.LWUP;
         case 'Nccn'
            loaded_var.(varname) = sum(runs.FNCN,5);
         case 'BBT'
            BBT = (runs.LWDN/5.67e-8).^(1/4);
            BBT=real(BBT);
            BBT(BBT<=200)=nan;
            loaded_var.(varname) = BBT;
         case 'emissivity'
            BBT = (runs.LWDN/5.67e-8).^(1/4);
            BBT=real(BBT);
            BBT(BBT<=200)=nan;
            loaded_var.(varname) = BBT./temp(runs.THETA, runs.PI);
         case 'fthrd'
            loaded_var.(varname) = runs.FTHRD*3600;
         case 'Dn_c'
            Dn_c = runs.GUESSC2;
            Dn_c(round(double(Dn_c),6)==1e-6) = nan;
            runs.GUESSC2 = Dn_c;
            loaded_var.(varname) = Dn_c;
         case 'Dn_r'
            Dn_r = runs.GUESSR2;
            Dn_r(round(double(Dn_r),4)==1e-4) = nan;
            runs.GUESSR2 = Dn_r;
            loaded_var.(varname) = Dn_r;
         case 'meandc'
            runs.RCP(runs.RCP<thhd.cloud_mr_th(1)/1e3) = 0;
            meand = (runs.RCP./runs.CCP/1000/(pi/6)).^(1/3)*1e6;
            meand(isinf(meand)) = nan;
            loaded_var.(varname) = meand;
         case 'meandr'
            runs.RRP(runs.RRP<thhd.rain_mr_th(1)/1e3) = 0;
            meand = (runs.RRP./runs.CRP/1000/(pi/6)).^(1/3)*1e6;
            meand(isinf(meand)) = nan;
            loaded_var.(varname) = meand;
         case 'meand'
            lwc = runs.RCP+runs.RRP;
            lwn = runs.CCP+runs.CRP;
            lwc(lwc<thhd.cloud_mr_th(1)/1e3)=0;
            meand = (lwc./lwn/1000/(pi/6)).^(1/3)*1e6;
            meand(isinf(meand)) = nan;
            loaded_var.(varname) = meand;
         case 'flagc'
            flagc = runs.GUESSC3;
            flagc(flagc<0) = nan;
            loaded_var.(varname) = flagc;
         case 'flagr'
            flagr = runs.GUESSR3;
            flagr(flagr<0) = nan;
            loaded_var.(varname) = flagr;
         case 'SPR'
            loaded_var.(varname) = squeeze(runs.PCPRR*3600*24);
         case 'cloudprof'
            loaded_var.(varname) = squeeze(nanmean(runs.RCP,[1,2]))*1e3;
         case 'rainprof'
            loaded_var.(varname) = squeeze(nanmean(runs.RRP,[1,2]))*1e3;
         case 'flux_s'
            loaded_var.(varname) = runs.SFLUX_T*1004;
         case 'flux_r'
            loaded_var.(varname) = runs.SFLUX_R*2.5e6;
         % case 'coal_rate'
         %    loaded_var.(varname) = -runs.NCOALT;
         otherwise
            loaded_var.(varname) = runs.(varin_obj.prereq_vars{end});
      end
      loaded_varname{end+1} = varname;
   end

   switch varin_obj.var_name 
      case "LWC"
         loaded_var.(varin_obj.var_name) = loaded_var.CWC + loaded_var.RWC;
      case "LWP"
         loaded_var.(varin_obj.var_name) = loaded_var.CWP + loaded_var.RWP;
      case "LNC"
         loaded_var.(varin_obj.var_name) = loaded_var.CNC + loaded_var.RNC;
      case "LNP"
         loaded_var.(varin_obj.var_name) = loaded_var.CNP + loaded_var.RNP;
      case "liqprof"
         loaded_var.(varin_obj.var_name) = loaded_var.cloudprof + loaded_var.rainprof;
   end
   
   % mark additional loaded var if it's a compound variable (calculated from multiple sources)
   if length(var_to_read) > 1
      loaded_varname{end+1} = varin_obj.var_name;
   end
end

function da_val = calc_domainavg(val)
   % assuming x, y are the first two dimensions
   % i.e., vars in the form of (x,y,z,t) or (x,y,t) etc.
   
   da_val = squeeze(nanmean(val,[1 2]));
end
