clear
clear global

global nfile outdir runs mpdat mp_list imp
close all

addpath('ramsfuncs/')
doanim=0;
doplot=1;

nikki='2022-02-09';
run rglobal_var
mp_list={'bin_sbm' 'amp_sbm' 'bin_tau' 'amp_tau'};
deltaz=100;

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
   
   rams_hdf5c({'RCP','RRP','RV','THETA','PI'},0:nfile-1,outdir)
   rams_hdf5c({'GLAT','GLON'},0,outdir)
   runs.RH=rh(runs.RV,runs.THETA,runs.PI);
   
   mpdat(imp,1).(mp_list{imp})=runs;
   
   %lwp=deltaz*squeeze((sum(runs.DMOMC3,3)+sum(runs.DMOMR3,3))*pio6rw);
   mpdat(imp).(mp_list{imp}).lwp=...
      deltaz*squeeze((sum(runs.RCP,3)+sum(runs.RRP,3)));
   mpdat(imp).(mp_list{imp}).lwp_da=...
      squeeze(mean(mpdat(imp).(mp_list{imp}).lwp,[1 2]));
   mpdat(imp).(mp_list{imp}).cwp=...
      deltaz*squeeze(sum(runs.RCP,3));
   mpdat(imp).(mp_list{imp}).cwp_da=...
      squeeze(mean(mpdat(imp).(mp_list{imp}).cwp,[1 2]));
   mpdat(imp).(mp_list{imp}).rwp=...
      deltaz*squeeze(sum(runs.RRP,3));
   mpdat(imp).(mp_list{imp}).rwp_da=...
      squeeze(mean(mpdat(imp).(mp_list{imp}).rwp,[1 2]));

   mpdat(imp).(mp_list{imp}).rv=...
      deltaz*squeeze((sum(runs.RV,3)));
   mpdat(imp).(mp_list{imp}).rv_da=...
      squeeze(mean(mpdat(imp).(mp_list{imp}).rv,[1 2]));
   mpdat(imp).(mp_list{imp}).rh_da=...
      squeeze(mean(mpdat(imp).(mp_list{imp}).RH,[1 2 3]));
   mpdat(imp).(mp_list{imp}).theta_da=...
      squeeze(mean(mpdat(imp).(mp_list{imp}).THETA,[1 2 3]));
end % imp

%%

if doplot
figure('position',[0 0 500 400])

for imp=1:length(mp_list)
   hold on
   plot(mpdat(imp).(mp_list{imp}).lwp_da,'LineWidth',2,'displayname',mp_list{imp})
   %plot(mpdat(imp).(mp_list{imp}).rh_da,'LineWidth',2,'displayname',mp_list{imp})
   %plot(mpdat(imp).(mp_list{imp}).rv_da,'LineWidth',2,'displayname',mp_list{imp})
end

ylabel('domain avg. LWP [kg/m^2]')
%ylabel('domain avg. column RV [kg/m^2]')
%ylabel('domain avg. RH [%]')
%ylabel('domain avg. \theta [K]')
set(gca,'fontsize',16)
legend('show','Interpreter','none')

hold off
%exportgraphics(gcf,'plots/da_lwp.png','resolution',300)
%print('plots/rams/da_rv','-dpng','-r300')
print(['plots/rams/da_lwp_' mps '_' mconfig],'-dpng','-r300')

end % doplot


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
