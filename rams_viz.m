clear
clear global
close all

addpath('rams_viz/')
doanim=0;
doplot=1;

nikki='2021-07-21';
run globvar_rams
mconfig='amp-sbm';

outdir=[output_dir,nikki,'/',mconfig,'/'];
%%
nfile=length(dir([outdir '*g1.h5']));
fn={dir([outdir '*g1.h5']).name}; % get a file name and load the data info
dat_info=h5info([outdir fn{1}]).Datasets;

rams_hdf5c({'RCP','RRP'},0:nfile-1,outdir)
rams_hdf5c({'GLAT','GLON'},0,outdir)

amp_sbm=runs;

deltaz=100;
%liqpath=deltaz*squeeze((sum(runs.DMOMC3,3)+sum(runs.DMOMR3,3))*pio6rw);
liqpath=deltaz*squeeze((sum(runs.RCP,3)+sum(runs.RRP,3)));
liqpath_da=squeeze(mean(liqpath,[1 2]));
%%

if doplot

plot(liqpath_da,'LineWidth',2)
ylabel('domain averaged LWP [kg/m^2]')
set(gca,'fontsize',16)

print('-RGBImage','-r144');
saveas(gcf,['plots/' mconfig ' da_lwp.png'])
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