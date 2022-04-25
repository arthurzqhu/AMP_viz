function get_var_comp(var_comp)
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all mconfig mconfigivar_dict

if exist('var_comp', 'var') && length(var_comp) > 0
   indvar_name_set=indvar_name_all(var_comp);
   indvar_ename_set=indvar_ename_all(var_comp);
   indvar_units_set=indvar_units_all(var_comp);
elseif ~isempty(mconfig)
   indvar_name_set=indvar_name_all(mconfigivar_dict(mconfig));
   indvar_ename_set=indvar_ename_all(mconfigivar_dict(mconfig));
   indvar_units_set=indvar_units_all(mconfigivar_dict(mconfig));
else
   indvar_name_set=indvar_name_all;
   indvar_ename_set=indvar_ename_all;
   indvar_units_set=indvar_units_all;
end

end
