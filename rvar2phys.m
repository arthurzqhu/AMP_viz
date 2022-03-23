function rvar2phys(var_interest, l_da_arr)

global nfile outdir runs mpdat mp_list imp deltaz density

   threshold = -inf;
   
   ispath=0;
   isprof=0;
   isproc=0;
   israin=0;
   iscloud=0;
   
   % load all the required variables
   var_req_uniq = unique(horzcat(var_interest.prereq_vars));
   rams_hdf5c(var_req_uniq,1:nfile-1,outdir)
   
   
   % 
   loaded_varname = {}; % record what variables are already loaded
   loaded_var = struct;
   density = rho(runs.THETA, runs.PI);
   
   mpdat(imp).(mp_list{imp}).time=runs.time;
   for ivar = 1:length(var_interest)
      if length(l_da_arr) > 1
         l_da = l_da_arr(ivar);
      else
         l_da = l_da_arr;
      end
   
      [loaded_var, loaded_varname] = loadvar(var_interest(ivar), loaded_var, loaded_varname);
      % load variables needed, including those for domain averaged vals
      % loadvar should have the ability to check whether the dependent variables are already
      % loaded, and load them only if necesssary
      if l_da
         mpdat(imp).(mp_list{imp}).(var_interest(ivar).da_name) = ...
            calc_domainavg(loaded_var.(var_interest(ivar).var_name));
      else
         mpdat(imp).(mp_list{imp}).(var_interest(ivar).var_name) = ...
            loaded_var.(var_interest(ivar).var_name);
      end
   end
end


function [loaded_var, loaded_varname] = loadvar(varin_obj,loaded_var,loaded_varname)
% update the loaded_var (struct) and loaded_varname (cell)
global runs deltaz density
   
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
            loaded_var.(varname) = runs.RCP;
         case 'RWC'
            loaded_var.(varname) = runs.RRP;
         case 'CWP'
            loaded_var.(varname) = deltaz*squeeze(sum(runs.RCP.*density,3));
         case 'RWP'
            loaded_var.(varname) = deltaz*squeeze(sum(runs.RRP.*density,3));
         case 'Rv'
            loaded_var.(varname) = deltaz*squeeze(sum(runs.RV.*density,3));
         case 'RH'
            loaded_var.(varname) = rh(runs.RV,runs.THETA,runs.PI);
      end
      loaded_varname{end+1} = varname;
   end

   switch varin_obj.var_name 
      case "LWP"
         loaded_var.(varin_obj.var_name) = loaded_var.CWP + loaded_var.RWP;
      case "LWC"
         loaded_var.(varin_obj.var_name) = loaded_var.CWC + loaded_var.RWC;
   end
   
   % mark additional loaded var if it's a compound variable (calculated from multiple sources)
   if length(var_to_read) > 1
      loaded_varname{end+1} = varin_obj.var_name;
   end
end

function da_val = calc_domainavg(val)
   % assuming x, y are the first two dimensions
   % i.e., val in the form of (x,y,z,t) or (x,y,t) etc.
   
   da_val = squeeze(mean(val,[1 2]));
end
