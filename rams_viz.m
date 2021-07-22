clear
clear global
close all

addpath('rams_viz/')
doanim=0;
doplot=1;

nikki='2021-07-21';
run globvar_rams
mp_list={'bin_tau','bin_sbm','amp_sbm'};
deltaz=100;

for imp=1:length(mp_list) % loop through microphysics engines
   mconfig=mp_list{imp};

   outdir=[output_dir,nikki,'/',mconfig,'/'];
   %%
   nfile=length(dir([outdir '*g1.h5']));
   fn={dir([outdir '*g1.h5']).name}; % get a file name and load the data info
   dat_info=h5info([outdir fn{1}]).Datasets;
   
   rams_hdf5c({'RCP','RRP'},0:nfile-1,outdir)
   rams_hdf5c({'GLAT','GLON'},0,outdir)
   
   mpdat(imp,1).(mp_list{imp})=runs;
   
   %liqpath=deltaz*squeeze((sum(runs.DMOMC3,3)+sum(runs.DMOMR3,3))*pio6rw);
   mpdat(imp).(mp_list{imp}).liqpath=...
      deltaz*squeeze((sum(runs.RCP,3)+sum(runs.RRP,3)));
   mpdat(imp).(mp_list{imp}).liqpath_da=...
      squeeze(mean(mpdat(imp).(mp_list{imp}).liqpath,[1 2]));
end

%%

if doplot
figure('position',[0 0 500 400])

for imp=1:length(mp_list)
   hold on
   plot(mpdat(imp).(mp_list{imp}).liqpath_da,'LineWidth',2,'displayname',mp_list{imp})
end

ylabel('domain avg. LWP [kg/m^2]')
set(gca,'fontsize',16)
legend('show','Interpreter','none')

hold off
%exportgraphics(gcf,'plots/da_lwp.png','resolution',300)
print('plots/da_lwp','-dpng','-r300')
end


if doanim

set(0, 'DefaultFigurePosition', [233 247 400 400])
for it=1:size(liqpath,3)
   contourf(runs.GLON,runs.GLAT,squeeze(liqpath(:,:,it)),'LineColor','none')
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

saveVid(F,['liqpath ' mconfig],2)

end
