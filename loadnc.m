function [filemeta,filename,fileinfo,var_name,stct]=loadnc(mp_in)

global ivar1 ivar2 its nikki mconfig output_dir vnum ...
   bintype var1_str var2_str indvar_name_set indvar_name ...
   indvar_units indvar_ename indvar_ename_set indvar_units_set ...
   indvar2D_name indvar2D_units indvar2D_ename indvar2D_name_set ...
   indvar2D_ename_set indvar2D_units_set

filedir=[output_dir,nikki,'/',mconfig,'/',upper(mp_in),'_',...
   upper(bintype{its}),'/',var1_str{ivar1},...
   '/', var2_str{ivar2},'/KiD_m-amp_b-',lower(mp_in),'+',...
   bintype{its},'_u-Adele_c-0*_v-',vnum,'.nc'];

filemeta = dir(filedir);
filename = [filemeta.folder, '/', filemeta.name];
fileinfo = ncinfo(filename);

for ivar = 1:length(fileinfo.Variables)
   var_name{ivar,1} = fileinfo.Variables(ivar).Name;
   stct.(var_name{ivar}) = ncread(filename, var_name{ivar});
end

% combine cloud and rain type
var_wcloud=var_name(contains(var_name,'cloud'));
var_wrain=replace(var_wcloud,'cloud','rain');
var_wliq=replace(var_wcloud,'cloud','liq');
var_name=[var_name;var_wliq];

liq_count=length(var_wliq);

ivar=1;
for ivaradd = length(fileinfo.Variables)+1:length(fileinfo.Variables)+liq_count
   stct.(var_name{ivaradd})=stct.(var_wcloud{ivar})+stct.(var_wrain{ivar});
   ivar=ivar+1;
end

var_name=[var_name;'half_life_c'];
time=stct.time;
stct.(var_name{ivaradd+1})=time(find(stct.cloud_M1_path<stct.rain_M1_path,1));
if isempty(stct.half_life_c)
   stct.half_life_c=nan;
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
