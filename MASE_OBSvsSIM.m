clearvars -except cmaps
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iwrap l_da var1_str
close all

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;
mp_plot = [1:3];

nikki = 'MASE14_8hr';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);


var_int_idx = [49 50 51];


for iconf = 1%:length(var1_str_list)
mconfig = mconfig_ls{iconf};
rcase_dep_var
disp(mconfig)

mp_runs = struct;

% load RAMS output
var1_str = var1_str_list{iconf};
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

% load MASE in situ obs
obs = load('MASE/050714_Ps.mat');
load('dp_pdi.mat')
dlogD = log10(dp_pdi(2)/dp_pdi(1));
rwc = sum(obs.s_conc_pdi(:,103:end)*1e6.*((dp_pdi(103:end)'/1e6).^3/6*pi)*1e3*dlogD,2)*1e3;
cwc = sum(obs.s_conc_pdi(:,1:102)*1e6.*((dp_pdi(1:102)'/1e6).^3/6*pi)*1e3*dlogD,2)*1e3;
for iz = 1:length(z)
   zi=z(iz);
   vidx=obs.s_ap>=zi-dz/2 & obs.s_ap<zi+dz/2;
   obs.liqprof(iz) = nanmean(obs.s_lwc_pdi(vidx));
   obs.rainprof(iz) = nanmean(rwc(vidx));
   obs.cloudprof(iz) = nanmean(cwc(vidx));
end

%% fig

figure
meanrainp_b= mean(mp_runs.bin_sbm.rainprof(:,1:end),2);
meanrainp_u= mean(mp_runs.uamp_sbm.rainprof(:,1:end),2);
meanrainp_s= mean(mp_runs.samp_sbm.rainprof(:,1:end),2);
plot(obs.rainprof,z,'displayname','obs')
hold on
plot(meanrainp_b,z,'displayname','sim (bin)')
plot(meanrainp_u,z,'displayname','sim (uamp)')
plot(meanrainp_s,z,'displayname','sim (samp)')
hold off
legend('show')
saveas(gcf,['plots/rams/',nikki,'/test vs obs rain ',mconfig,'.png'])

figure
meancloudp_b= mean(mp_runs.bin_sbm.cloudprof,2);
meancloudp_u= mean(mp_runs.uamp_sbm.cloudprof,2);
meancloudp_s= mean(mp_runs.samp_sbm.cloudprof,2);
plot(obs.cloudprof,z,'displayname','obs')
hold on
plot(meancloudp_b,z,'displayname','sim (bin)')
plot(meancloudp_u,z,'displayname','sim (uamp)')
plot(meancloudp_s,z,'displayname','sim (samp)')
hold off
legend('show')
saveas(gcf,['plots/rams/',nikki,'/test vs obs cloud ',mconfig,'.png'])

%% movie

% for it=1:size(mp_runs.bin_sbm.rainprof,2)
%    disp(it)
%    plot(mp_runs.bin_sbm.rainprof(:,it),z,'displayname','sim (bin)','color',color_order{1},'LineStyle','-','LineWidth',.5)
%    hold on
%    try
%    plot(mp_runs.samp_sbm.rainprof(:,it),z,'displayname','sim (samp)','color',color_order{1},'LineStyle',':','LineWidth',1.5)
%    end
%    try
%    plot(mp_runs.uamp_sbm.rainprof(:,it),z,'displayname','sim (uamp)','color',color_order{1},'LineStyle','--','LineWidth',1)
%    end
%    plot(obs.rainprof,z,'displayname','obs','color',color_order{2})
%    hold off
%    legend('show')
%    title(mp_runs.bin_sbm.time_str{it})
%    % xlim([0 1.2])
%    cdata{it} = print('-RGBImage','-r300');
%    F(it) = im2frame(cdata{it});
% end
% saveVid(F,['rams/mase rain obs vs sim ' mconfig],5)

end
