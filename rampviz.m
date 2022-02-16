clear
clear global

global nfile outdir runs mpdat mp_list imp deltaz
close all

addpath('ramsfuncs/')
doanim=0;
doplot=1;

nikki='2022-02-15';
run rglobal_var
mp_list={'bin_sbm' 'amp_sbm' 'bin_tau' 'amp_tau'};

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
   nfile=length(dir([outdir '*g1.h5']));
   fn={dir([outdir '*g1.h5']).name}; % get a file name and load the data info
   dat_info=h5info([outdir fn{1}]).Datasets;
   
   rams_hdf5c({'GLAT','GLON'},0,outdir)
   rams_hdf5c(var_req_uniq,0:nfile-1,outdir)
   deltaz=z(2)-z(1);

   % make sure that z is never negative
   z=z+deltaz/2;

   var_int_idx=1:3;
   var_interest=var_da(var_int_idx);
   rvar2phys(var_interest)
end % imp

%%

if doplot
figure('position',[0 0 500 400])

for ivar=var_int_idx
   varn=var_da{ivar};
   for imp=1:length(mp_list)
      plot(runs.time,mpdat(imp).(mp_list{imp}).(varn),'LineWidth',2,'displayname',mp_list{imp})
      hold on
   end
   
   datetick('x','HHPM','keeplimits')
   xtickangle(45)
   
   ylabel([var_da_name{ivar} var_da_unit{ivar}])
   set(gca,'fontsize',16)
   legend('show','Interpreter','none')
   
   hold off
   print(['plots/rams/' varn '_' mps '_' mconfig],'-dpng','-r300')
end % ivar

end % doplot

%%

if doanim

set(0, 'DefaultFigurePosition', [0 0 800 600])
for imp=1:length(mp_list)
   mps=mp_list{imp};
   for it=1:size(mpdat(imp).(mp_list{imp}).lwp,3)
      it
      contourf(runs.GLON,runs.GLAT,squeeze(mpdat(imp).(mp_list{imp}).rv(:,:,it)),'LineColor','none')
      colorbar
      colormap(cmap.Blues)
      %caxis([1e-6 1e0])
      set(gca,'ColorScale','log')
   
      xlabel('long')
      ylabel('lat')
      title(['time=' fn{it}(end-11:end-6)])
   
      cdata = print('-RGBImage','-r144');
      F(it) = im2frame(cdata);
      %F(it)=getframe(gcf);
   end
   saveVid(F,['rams/rv ' mps],30)
end


end % if doanim
end % iconf
