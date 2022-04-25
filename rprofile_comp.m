clear
clear global

global nfile outdir runs mpdat mp_list imp dz z deltaz deltax nikki
close all

cabin = load('VOCALS_CABIN/081019.mat');
addpath('ramsfuncs/')

nikki = '2022-04-22'
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
   var_int_idx = [3 6]; % 3: LWP (for checking the threshold for cloudiness), 6: LWC
   idx = 1;
   for ivar = var_int_idx
      var_interest(idx) = ramsvar(var_name_set{ivar}, var_ename_set{ivar},...
                                  var_req_set{ivar}, var_unit_set{ivar}, 0);
      idx = idx + 1;
   end 
   rvar2phys(var_interest, 0)

   dz = deltaz;
   z_trim = z(2:end-1);

   sim_lwc_prof = zeros(size(z_trim));
   cab_lwc_prof = zeros(size(z_trim));

   vidx_rams_3d = mpdat(imp).(mp_list{imp}).LWP > thhd.cwp_th(1); % (x, y, t) 50 50 72

   for iz = 1:length(z_trim)
      zi = z_trim(iz);
      vidx_vocals = cabin.s_ap >= zi-dz/2 & cabin.s_ap < zi+dz/2;
      iz_rams = z==z(iz+1); % since I got rid of the first and the last indices in z
      vidx_4d_slice = false(size(mpdat(imp).(mp_list{imp}).LWC));
      vidx_4d_slice(:,:,iz_rams,:) = vidx_rams_3d;
      sim_lwc_prof(iz) = nanmean(mpdat(imp).(mp_list{imp}).LWC(vidx_4d_slice),'all');
      cab_lwc_prof(iz) = nanmean(cabin.s_lwc_pdi(vidx_vocals));
   end

   nexttile
   plot(cab_lwc_prof, z_trim, 'displayname', 'obs'); hold on
   plot(sim_lwc_prof, z_trim, 'displayname', 'sim')
   grid
   legend('show')
   xlabel('LWC [g/kg]')
   ylabel('z [m]')
   title(mps, 'Interpreter', 'none')
end

% pretending there's I'm only plotting LWC for now...
print(['plots/rams/' nikki '/LWC_prof_' mconfig '.png'],'-dpng','-r300')

end
