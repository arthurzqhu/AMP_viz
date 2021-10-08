function [filemeta,filename,fileinfo,var_name,stct]=loadnc(mp_in,case_interest)

global ivar1 ivar2 its ici nikki mconfig output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name_set indvar_name ...
   indvar_units indvar_ename indvar_ename_set indvar_units_set ...
   indvar2D_name indvar2D_units indvar2D_ename indvar2D_name_set ...
   indvar2D_ename_set indvar2D_units_set

for ici = case_interest
   
   
   filemeta = dir([output_dir,nikki,'/',mconfig,'/',upper(mp_in),'_',...
      upper(bintype{its}),'/',var1_str{ivar1},...
      '/', var2_str{ivar2},'/KiD_m-amp_b-',lower(mp_in),'+',...
      bintype{its},'_u-Adele_c-0',case_list_str{ici},...
      '_v-',vnum,'.nc']);
   filename = [filemeta.folder, '/', filemeta.name];
   fileinfo = ncinfo(filename);
   
   for ivar = 1:length(fileinfo.Variables)
      var_name{ivar,1} = fileinfo.Variables(ivar).Name;
      stct.(var_name{ivar}) = ncread(filename, var_name{ivar});
   end
end


% only select the available vars as indvars
indvar_name=intersect(indvar_name_set,var_name,'stable');
vidx=ismember(indvar_name_set,indvar_name);
indvar_ename=indvar_ename_set(vidx);
indvar_units=indvar_units_set(vidx);

indvar2D_name=intersect(indvar2D_name_set,var_name,'stable');
vidx=ismember(indvar2D_name_set,indvar2D_name);
indvar2D_ename=indvar2D_ename_set(vidx);
indvar2D_units=indvar2D_units_set(vidx);

end