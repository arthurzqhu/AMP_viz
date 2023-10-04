function runs_mps = loadrams(structure_type,snap)
global mconfig bintype its nikki output_dir runs var_int_idx var_name_set ...
   var_ename_set var_req_set var_unit_set var_range var_linORlog l_da ...
   filedir nfile mp_str var_interest dist_num fn var1_str var2_str ivar1 ivar2

mp_str = [structure_type '_' bintype{its}];
filedir=[output_dir nikki '/' mconfig '/' var1_str '/' mp_str '/' ];
% filedir=[output_dir nikki '/' mconfig '/' var1_str{ivar1} '/' var2_str{ivar2} '/' ...
%    mp_str '/' ];

nfile=length(dir([filedir 'a-L*g1.h5']));
fn={dir([filedir 'a-L*g1.h5']).name}; % get a file name and load the data info
dat_info=h5info([filedir fn{1}]).Datasets;


if ~exist('snap')
   snap = [];
end

runs_mps = rvar2phys(var_interest, l_da, snap);
runs_mps.time_str = cellfun(@(x) x(end-11:end-6),fn,'UniformOutput',false);

clear runs
rams_hdf5c({'GLAT','GLON'},0,filedir)

end
