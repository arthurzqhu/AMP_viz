clearvars -except cmaps
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iab l_da var1_str
close all

addpath('ramsfuncs/')
doanim=0;
doplot=1;

nikki='UvsS_dgdt60';
rglobal_var
mconfig_ls=get_mconfig_list(output_dir,nikki);

var_int_idx=[6 3 36];
l_da=[3 0 0];

mp_runs=struct;

mconfig=mconfig_ls{1};
rcase_dep_var

t_snaps=[1200 1500 1800];
dt=60;
it_snaps=floor(t_snaps/dt);

figure('position',[0 0 1200 800])
tl=tiledlayout(2,6,'TileSpacing','compact','padding','compact');

ivar1=1;
var1_str=var1_str_list{ivar1};

iconf=1;
mconfig=mconfig_ls{iconf};
disp(mconfig)

its=2;
binmean=load('diamg_sbm.txt')*1e6;

% the single column at x=50, y=50 will be selected instead of domain averaging
l_da(contains({var_name_set{var_int_idx}},{'DSD','SPR','WP'}))=2;

% cloud/rain/liquid water content is viewed as a cross section of the cloud at x=50
l_da(contains({var_name_set{var_int_idx}},{'CWC','RWC','LWC'}))=3;

iab=2;
var_interest=get_varint(var_int_idx);
mp=['bin_' bintype{its}];

mp_runs.(mp)=loadrams('bin');
z=z(2:end-1);

var_names = {var_interest.var_name};
var_enames = {var_interest.var_ename};
var_da_names = {var_interest.da_name};
var_da_enames = {var_interest.da_ename};
var_units = {var_interest.units};


maxcaxis = 0;
for it=1:length(t_snaps)
   it_snap=it_snaps(it);
   t_snap=t_snaps(it);
   disp(t_snap)

   ivar=1;
   var_name = var_names{ivar};
   var_da_name = var_da_names{ivar};
   pRange = var_interest(ivar).range;
   linORlog = var_interest(ivar).linORlog;

   maxcaxis = max([max(mp_runs.(mp).(var_da_name)(:,:,it_snap),[],'all'), maxcaxis]);

   nexttile(2*it-1,[1 2])
   nanimagesc(runs.GLAT(1,:),z,mp_runs.(mp).(var_da_name)(:,:,it_snap)')
   xlim([28.563 28.595])
   ylim([0 5000])
   xlabel('Latitude [\circ]')
   ylabel('Altitude [m]')
   colormap(cmaps.Blues_s)
   cb = colorbar;
   cb.Label.String = [var_name var_units{ivar}];
   set(gca,'ColorScale','log')
   caxis([1e-3 maxcaxis])
   title(['(',Alphabet(it),') ', var_name,' @ t = ' num2str(t_snap) ' s'])
   set(gca,'fontsize',16)
end

for ivar=2:3
   var_name = var_names{ivar};
   var_da_name = var_da_names{ivar};
   pRange = var_interest(ivar).range;
   linORlog = var_interest(ivar).linORlog;

   nexttile(3*ivar+1,[1 3])
   plot(mp_runs.bin_sbm.time,mp_runs.bin_sbm.(var_da_name),'LineWidth',1,'Color',color_order{ivar-1})
   xlabel('Time [s]')
   ylabel([var_name var_units{ivar}])
   datetick('keeplimits')
   title(['(',Alphabet(ivar+2),') ',var_enames{ivar}, var_units{ivar}])
   set(gca,'fontsize',16)
end

title(tl, 'Model Setup of the RAMS Simulations','fontweight','bold','fontsize',24)


exportgraphics(gcf,'plots/p2/rams_setup.pdf')
