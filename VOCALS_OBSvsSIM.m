clearvars -except cmaps
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iwrap l_da var1_str
close all

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;
mp_plot = [1 2 3];

nikki = 'VOCALS_RF12';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);


var_int_idx = [1:6 51];

mconfig = mconfig_ls{1};
rcase_dep_var
disp(mconfig)

mp_runs = struct;

% load RAMS output
for ivar1 = 1%:length(var1_str_list)
var1_str = var1_str_list{ivar1};
for its = 2:length(bintype)
   for iwrap = mp_plot%:length(wrappers)
      disp([wrappers{iwrap} '-' bintype{its}])
      l_da(1:length(var_int_idx)) = 1;
      l_da(contains({var_name_set{var_int_idx}},'prof')) = 4;
      % get var_interest as an object
      var_interest = get_varint(var_int_idx);
      mps = [wrappers{iwrap} '_' bintype{its}]; % mps = microphysics scheme
      mp_runs.(mps) = loadrams(wrappers{iwrap});
      % make sure that z is never negative
      dz = z(2)-z(1);
      z = z+dz;
   end
end
end

% load VOCALS in situ obs
obs = load('VOCALS_CABIN/081102_Ps.mat');
load('dp_pdi.mat')
for iz = 1:length(z)
   zi=z(iz);
   vidx=obs.s_ap>=zi-dz/2 & obs.s_ap<zi+dz/2;
   lwprof(iz) = nanmean(obs.s_lwc_pdi(vidx));
end

for it=1:size(mp_runs.bin_sbm.liqprof,2)
   disp(it)
   plot(mp_runs.bin_sbm.liqprof(:,it),z,'displayname','sim (bin)','color',color_order{1},'LineStyle','-','LineWidth',.5)
   hold on
   plot(mp_runs.samp_sbm.liqprof(:,it),z,'displayname','sim (samp)','color',color_order{1},'LineStyle',':','LineWidth',1.5)
   try
   plot(mp_runs.uamp_sbm.liqprof(:,it),z,'displayname','sim (uamp)','color',color_order{1},'LineStyle','--','LineWidth',1)
   end
   plot(lwprof,z,'displayname','obs','color',color_order{2})
   hold off
   legend('show')
   xlim([0 1.2])
   cdata{it} = print('-RGBImage','-r300');
   F(it) = im2frame(cdata{it});
end

saveVid(F,'rams/test lwc obs vs sim',5)
% saveas(gcf,'plots/rams/VOCALS_RF12/test vs obs.png')
