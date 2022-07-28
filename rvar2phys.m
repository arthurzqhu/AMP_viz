function mpdat = rvar2phys(var_interest, l_da_arr)

global nfile filedir runs mp_list deltaz density binmean bintype its mp_str

   threshold = -inf;
   
   ispath=0;
   isprof=0;
   isproc=0;
   israin=0;
   iscloud=0;
   
   % load all the required variables
   var_req_uniq = unique(horzcat(var_interest.prereq_vars));
   rams_hdf5c(var_req_uniq,1:nfile-1,filedir)
   
   if contains(bintype{its},'tau')
      binmean = load('tau_binmean.txt')*2;
   elseif contains(bintype{its},'sbm')
      binmean = load('sbm_binmean.txt')*2;
   end
   
   % 
   loaded_varname = {}; % record what variables are already loaded
   loaded_var = struct;
   density = rho(runs.THETA, runs.PI);
   
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
      if l_da
         mpdat.(var_interest(ivar).da_name) = ...
            calc_domainavg(loaded_var.(var_interest(ivar).var_name));
      else
         mpdat.(var_interest(ivar).var_name) = ...
            loaded_var.(var_interest(ivar).var_name);
      end
   end
end


function [loaded_var, loaded_varname] = loadvar(varin_obj,loaded_var,loaded_varname)
% update the loaded_var (struct) and loaded_varname (cell)
global runs deltaz density binmean
   
   switch varin_obj.var_name
      case "LWP"
         var_to_read = {'CWP','RWP'};
      case "LWC"
         var_to_read = {'CWC','RWC'};
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
         case 'CNC'
            loaded_var.(varname) = runs.CCP;
         case 'RNC'
            loaded_var.(varname) = runs.CRP;
         case 'CWP'
            loaded_var.(varname) = 1e3*deltaz*squeeze(sum(runs.RCP.*density,3));
         case 'RWP'
            loaded_var.(varname) = 1e3*deltaz*squeeze(sum(runs.RRP.*density,3));
         case 'CNP'
            loaded_var.(varname) = deltaz*squeeze(sum(runs.CCP.*density,3));
         case 'RNP'
            loaded_var.(varname) = deltaz*squeeze(sum(runs.CRP.*density,3));
         case 'Rv'
            % loaded_var.(varname) = deltaz*squeeze(sum(runs.RV.*density,3));
            loaded_var.(varname) = runs.RV;
         case 'RH'
            loaded_var.(varname) = rh(runs.RV,runs.THETA,runs.PI);
         case 'DSDm'
            loaded_var.(varname) = runs.FFCD;
         case 'DSDn'
            loaded_var.(varname) = runs.FFCDN;
         case 'reldisp'
            loaded_var.(varname) = runs.RELDISP;
         case 'flagc'
            loaded_var.(varname) = runs.GUESSC3;
         case 'flagr'
            loaded_var.(varname) = runs.GUESSR3;
         case 'pres'
            loaded_var.(varname) = press(runs.PI);
         case 'temp'
            loaded_var.(varname) = temp(runs.THETA, runs.PI);
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
   end
   
   % mark additional loaded var if it's a compound variable (calculated from multiple sources)
   if length(var_to_read) > 1
      loaded_varname{end+1} = varin_obj.var_name;
   end
end

function da_val = calc_domainavg(val)
   % assuming x, y are the first two dimensions
   % i.e., vars in the form of (x,y,z,t) or (x,y,t) etc.
   
   da_val = squeeze(mean(val,[1 2]));
end
