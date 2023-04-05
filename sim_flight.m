clear
clear global
close all

global nfile outdir runs mpdat mp_list imp deltaz z

cabin=load('VOCALS_CABIN/081019.mat');

nikki='2022-04-22'
rglobal_var

mconfig_ls_dir=dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags=[mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2)=0; % ignore the current and parent dir
mconfig_ls={mconfig_ls_dir(mconfig_ls_dir_flags).name};

for iconf=1:length(mconfig_ls)
mconfig=mconfig_ls{iconf};

for imp=1:length(mp_list) % loop through microphysics engines
   mps=mp_list{imp};

   outdir=[output_dir nikki '/' mconfig '/' mps '/' ];
   %%
   nfile=length(dir([outdir 'a-L*g1.h5']));
   fn={dir([outdir 'a-L*g1.h5']).name}; % get a file name and load the data info
   dat_info=h5info([outdir fn{1}]).Datasets;

   rams_hdf5c({'GLAT','GLON'},0,outdir)
   var_int_idx = [3 6]; % 3: LWP (for checking the threshold for cloudiness), 6: LWC
   idx = 1;
   for ivar = var_int_idx
      var_interest(idx) = ramsvar(var_name_set{ivar}, var_ename_set{ivar},...
                                  var_req_set{ivar}, var_unit_set{ivar}, 0);
      idx = idx + 1;
   end 
   rvar2phys(var_interest, 0)
   
   deltaz=z(2)-z(1);

   % unstagger z
   z=(z(1:end-1)+z(2:end))/2;
   t_sec_UTC=(runs.time-floor(runs.time(1)))*86400;

   sim_ti=arrayfun(@(x) findInSorted(t_sec_UTC,cabin.s_t(x)),1:length(cabin.s_ap));
   sim_cabin.t=runs.time(sim_ti);

   sim_Xi_flat=arrayfun(@(x) findInSorted(runs.GLON(:),cabin.s_lon(x)),1:length(cabin.s_lon));
   sim_cabin.lon=runs.GLON(sim_Xi_flat);

   sim_Yi_flat=arrayfun(@(x) findInSorted(runs.GLAT(:),cabin.s_lat(x)),1:length(cabin.s_lat));
   sim_cabin.lat=runs.GLAT(sim_Yi_flat);

   sim_Zi=arrayfun(@(x) findInSorted(z,cabin.s_ap(x)),1:length(cabin.s_ap));
   sim_cabin.z=z(sim_Zi);

   [sim_Xi,~]=ind2sub(size(runs.GLON),sim_Xi_flat);
   [~,sim_Yi]=ind2sub(size(runs.GLON),sim_Yi_flat);

   for it=1:length(cabin.s_t)
      sim_cabin.lwc(it)=1e3*(runs.RCP(sim_Xi(it),sim_Yi(it),sim_Zi(it),sim_ti(it))+runs.RRP(sim_Xi(it),sim_Yi(it),sim_Zi(it),sim_ti(it)));
   end

   plot(cabin.s_lwc_pdi,sim_cabin.lwc,'.')
   xlabel('observed')
   ylabel('model')
   
   vidx = find(~isnan(cabin.s_lwc_pdi+sim_cabin.lwc));
   mdl=fitlm(cabin.s_lwc_pdi, sim_cabin.lwc);
   RSQ=mdl.Rsquared.Ordinary;
   annotation('textbox',[0.7 0.7 0.1 0.2],'String',['R^2=' num2str(RSQ)],'FitBoxToText','on')
   refline(1,0)

   print(['plots/rams/' nikki '/lwc_' mps '_' mconfig '.png'],'-dpng','-r300')
   delete(findall(gcf,'type','annotation'))

end % imp

end % iconf

