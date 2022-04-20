function get_var_comp(var_comp)
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all

if ~exist('var_comp','var') || isempty(var_comp)
   indvar_name_set=indvar_name_all;
   indvar_ename_set=indvar_ename_all;
   indvar_units_set=indvar_units_all;
else
   indvar_name_set=indvar_name_all(var_comp);
   indvar_ename_set=indvar_ename_all(var_comp);
   indvar_units_set=indvar_units_all(var_comp);
end


end
