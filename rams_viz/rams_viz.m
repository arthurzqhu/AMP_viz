clear
clear global
close all

addpath('rams_viz/')

nikki='2021-07-14';
run globvar_rams
mconfig='bin-sbm';

outdir=[output_dir,nikki,'/',mconfig,'/'];
%%
nfile=length(dir([outdir '*g1.h5']));
fn={dir([outdir '*g1.h5']).name}; % get a file name and load the data info
dat_info=h5info([outdir fn{1}]).Datasets;

rams_hdf5c({'DMOMC3','DMOMR3'},0:nfile-1,outdir)
rams_hdf5c({'GLAT','GLON'},0,outdir)
liqpath=squeeze((sum(runs.DMOMC3,3)+sum(runs.DMOMR3,3))*pio6rw);

%%
for it=1:size(liqpath,3)
   contourf(runs.GLON,runs.GLAT,squeeze(liqpath(:,:,it)))
   colorbar
   colormap(cmap.Blues)
   caxis([1e-6 1e-1])
   set(gca,'ColorScale','log')
   
   xlabel('long')
   ylabel('lat')
   title(['time=' fn{it}(end-11:end-6)])
   
   F(it)=getframe(gcf);
end

saveVid(F,['liqpath ' mconfig],2)