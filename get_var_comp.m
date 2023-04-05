function get_var_comp(var_comp)
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all mconfig mconfigSet indvaridx

if ~exist('var_comp', 'var') || length(var_comp) == 0
   config_keyword = extractBefore(mconfig,'_');
   if isempty(config_keyword)
      config_keyword = mconfig;
   end
   mconfig_idx = find(strcmp(mconfigSet, config_keyword));
   var_comp = indvaridx{mconfig_idx};
end

indvar_name_set=indvar_name_all(var_comp);
indvar_ename_set=indvar_ename_all(var_comp);
indvar_units_set=indvar_units_all(var_comp);

end
