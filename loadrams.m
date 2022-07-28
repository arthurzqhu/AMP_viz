function mp_runs = loadrams(structure_type)
global mconfig bintype its nikki output_dir runs var_int_idx var_name_set ...
   var_ename_set var_req_set var_unit_set var_range var_linORlog l_da ...
   filedir nfile mp_str var_interest dist_num

mp_str = [structure_type '_' bintype{its}];
filedir=[output_dir nikki '/' mconfig '/' mp_str '/' ];

nfile=length(dir([filedir 'a-A*g1.h5']));
fn={dir([filedir 'a-A*g1.h5']).name}; % get a file name and load the data info
dat_info=h5info([filedir fn{1}]).Datasets;

mp_runs = rvar2phys(var_interest, l_da);

clear runs
rams_hdf5c({'GLAT','GLON'},0,filedir)

end
