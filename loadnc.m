function [filemeta,filename,fileinfo,var_name,stct]=loadnc(mp_in)

global iw ia its ici nikki mconfig output_dir case_list_str vnum ... 
    bintype aero_N_str w_spd_str 

filemeta = dir([output_dir,mconfig,'/',nikki,'/',upper(mp_in),'_',...
    upper(bintype{its}),'/',aero_N_str{ia},...
    '/', w_spd_str{iw},'/KiD_m-amp_b-',lower(mp_in),'+',...
    bintype{its},'_u-Adele_c-0',case_list_str{ici},...
    '_v-',vnum,'.nc']);
filename = [filemeta.folder, '/', filemeta.name];
fileinfo = ncinfo(filename);

for ivar = 1:length(fileinfo.Variables)
    var_name{ivar,1} = fileinfo.Variables(ivar).Name;
    stct(ici).(var_name{ivar}) = ncread(filename, var_name{ivar});
end

end