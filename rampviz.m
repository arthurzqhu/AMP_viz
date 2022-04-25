clear
clear global

global nfile outdir runs mpdat mp_list imp deltaz deltax z nikki
close all

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;
l_da = 1; % whether we want the domain averaged quantity, can be set to an array but it as an argument to ramsvar() needs to be changed to l_da(ivar)

nikki = '2022-04-22';
run rglobal_var
mp_list = {'bin_sbm' 'amp_sbm' 'bin_tau' 'amp_tau'};
%mp_list = {'amp_tau'};

mconfig_ls = get_mconfig_list(output_dir,nikki);

for iconf = 1:length(mconfig_ls)
mconfig = mconfig_ls{iconf}

for imp = 1:length(mp_list) % loop through microphysics engines
   mps = mp_list{imp};

   outdir = [output_dir nikki '/' mconfig '/' mps '/' ];
   %%
   nfile = length(dir([outdir 'a-L*g1.h5']));
   fn = {dir([outdir 'a-L*g1.h5']).name}; % get a file name and load the data info
   dat_info = h5info([outdir fn{1}]).Datasets;
   
   rams_hdf5c({'GLAT','GLON'},0,outdir)

   % make sure that z is never negative
   z = z(2:end-1);

   if doplot
      var_int_idx = 1:3; % CWP RWP LWP
   elseif doanim
      var_int_idx = 3;
   end

   idx = 1;
   for ivar = var_int_idx
      var_interest(idx) = ramsvar(var_name_set{ivar}, var_ename_set{ivar},...
                                  var_req_set{ivar}, var_unit_set{ivar}, l_da);
      idx = idx + 1;
   end 

   rvar2phys(var_interest, l_da) 
end % imp

%%

if doplot
figure('position',[0 0 500 400])
varname_interest = {var_interest.da_name};
varename_interest = {var_interest.da_ename};
varunit_interest = {var_interest.units};

for ivar = 1:length(varname_interest)
   varn = varname_interest{ivar};
   for imp = 1:length(mp_list)
      plot(mpdat(imp).(mp_list{imp}).time,mpdat(imp).(mp_list{imp}).(varn),'LineWidth',2,'displayname',mp_list{imp})
      hold on
   end
   
   datetick('x','HHPM','keeplimits')
   xtickangle(45)
   
   ylabel([varename_interest{ivar} varunit_interest{ivar}])
   set(gca,'fontsize',16)
   legend('show','Interpreter','none','location','southwest')
   
   hold off
   print(['plots/rams/' nikki '/' varn '_' mps '_' mconfig '.png'],'-dpng','-r300')
end % ivar

end % doplot

%%

if doanim
varn = 'LWP';
set(0, 'DefaultFigurePosition', [0 0 800 600])
for imp = 3%1:length(mp_list)
   mps = mp_list{imp};
   for it = 1:size(mpdat(imp).(mp_list{imp}).time)
      it
      contourf(runs.GLON,runs.GLAT,squeeze(mpdat(imp).(mp_list{imp}).(varn)(:,:,it)),'LineColor','none')
      colorbar
      colormap(cmap.Blues)
      caxis([1e-6 1e0])
      set(gca,'ColorScale','log')
   
      xlabel('long')
      ylabel('lat')
      title(['time=' fn{it}(end-11:end-6)])
   
      cdata = print('-RGBImage','-r144');
      F(it) = im2frame(cdata);
      %F(it)=getframe(gcf);
   end
   saveVid(F,['rams/' varn ' ' mps],30)
end


end % if doanim
end % iconf
