clear
clear global

global nfile outdir runs mpdat mp_list imp dz z deltaz deltax
close all

cabin = load('VOCALS_CABIN/081019.mat');
addpath('ramsfuncs/')

nikki = '2022-03-22'
run rglobal_var
mp_list = {'bin_sbm' 'amp_sbm' 'bin_tau' 'amp_tau'};

mconfig_ls = get_mconfig_list(output_dir,nikki);

for iconf = 1:length(mconfig_ls)
mconfig = mconfig_ls{iconf}

tl = tiledlayout(1,4);
figure('position', [0 0 1200 300])
for imp = 1:length(mp_list) % loop through microphysics engines
   mps = mp_list{imp};

   outdir = [output_dir nikki '/' mconfig '/' mps '/' ];
   %%
   nfile = length(dir([outdir 'a-L*g1.h5']));
   fn = {dir([outdir 'a-L*g1.h5']).name}; % get a file name and load the data info
   dat_info = h5info([outdir fn{1}]).Datasets;

   rams_hdf5c({'GLAT','GLON'},0,outdir)
   var_int_idx = 6; % CWP RWP LWP
   idx = 1;
   for ivar = var_int_idx
      var_interest(idx) = ramsvar(var_name_set{ivar}, var_ename_set{ivar},...
                                  var_req_set{ivar}, var_unit_set{ivar}, 0);
      idx = idx + 1;
   end 
   rvar2phys(var_interest, 0)

   dz = deltaz;
   z = z(2:end-1);

   sim_lwc_prof = zeros(size(z));
   cab_lwc_prof = zeros(size(z));

   for iz = 1:length(z)
      zi = z(iz);
      vidx_vocals = cabin.s_ap >= zi-dz/2 & cabin.s_ap < zi+dz/2;
      vidx_rams = iz + 1; % since I got rid of the first and the last indices in z

      sim_lwc_prof(iz) = 1e3*nanmean(mpdat(imp).(mp_list{imp}).LWC(:,:,vidx_rams,:),'all');
      cab_lwc_prof(iz) = nanmean(cabin.s_lwc_pdi(vidx_vocals));
   end
   nexttile
   plot(cab_lwc_prof, z, 'displayname', 'obs'); hold on
   plot(sim_lwc_prof, z, 'displayname', 'sim')
   grid
   legend('show')
   xlabel('LWC [g/kg]')
   ylabel('z [m]')
   title(mps, 'Interpreter', 'none')
end

% assuming there's I'm only plotting LWC for now...
print(['plots/rams/' var_name_set{var_int_idx} '_prof_' mconfig '.png'],'-dpng','-r300')

end
