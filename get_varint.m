function var_int = get_varint(int_idx)
global var_name_set var_ename_set var_req_set var_unit_set var_range ...
   var_linORlog l_da iab

idx = 1;
for ivar = int_idx
   if iab == 2 && contains(var_name_set{ivar}, 'flag')
      continue
   end

   var_int(idx) = ramsvar(var_name_set{ivar}, var_ename_set{ivar},...
                               var_req_set{ivar}, var_unit_set{ivar}, ...
                               var_range{ivar}, var_linORlog{ivar}, l_da);
   idx = idx + 1;
end 

end
