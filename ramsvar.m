classdef ramsvar

   properties
      var_name
      var_ename 
      prereq_vars = {};
      % prereq_vars = {'THETA','PI'};
      units
      range
      linORlog
      l_da
      da_name
      da_ename
   end

   methods
      function obj = ramsvar(var_name, var_ename, prereq_vars, units, range, linORlog, l_da)
         obj.var_name = var_name;
         obj.var_ename = var_ename;
         obj.prereq_vars = horzcat(obj.prereq_vars, prereq_vars);
         obj.units = units;
         obj.range = range;
         obj.linORlog = linORlog;
         obj.l_da = l_da;
         if l_da
            obj.da_name = [var_name '_da'];
            obj.da_ename = ['D.A. ' var_name];
         end
      end
    end

end
