clear
close all

config = 'skip_some';
proc = '_coll';
outdir = ['~/github/AMP_singcat/test' proc '/nu2_N4_M1/'];
outmom_dat = readmatrix([outdir 'cM4545type0.txt']);
outdis_dat = readmatrix([outdir 'cpdfM4545type0.txt']);
outparam_dat = readmatrix([outdir 'cparamsM4545type0.txt']);
binmean = load('diamg_sbm.txt')*1e6;

moms_plot = [3];

%% plot moments
figure
for mom_plot = moms_plot
   cloudmass = outmom_dat(:,mom_plot+4);
   rainmass = outmom_dat(:,mom_plot+20);
   plot(cloudmass,'linewidth',1); hold on
   plot(rainmass,'linewidth',1); hold off
   % xlim([0 150])
   legend('cloud','rain','location','best')
   print(gcf,['plots/samp/mom' num2str(mom_plot) '_M4545_' config proc '.jpg'],'-djpeg','-r300')
end

%% plot distribution

% % nanimagesc(1:size(outdis_dat,1),binmean,outdis_dat')
% % set(gca,'yscale','log')
% % xlabel('time [s]')
% % ylabel('diameter [\mum]')
% % colorbar
figure
% tplot = [1:size(outdis_dat)];
tplot = [1:300:size(outdis_dat)];
% tplot = [1445:1450];
hold on
outdis_dat(outdis_dat<1e-8)=0;
for it = tplot
   plot(binmean,outdis_dat(it,:),'linewidth',1,'displayname',['t=' num2str(it)] )
end
hold off
set(gca,'xscale','log')
set(gca,'yscale','log')
% legend('show')
grid
print(gcf,['plots/samp/dist_M4545_' config proc '.jpg'],'-djpeg','-r300')

%% plot other parameters

% figure
% Mz_real = outparam_dat(:,end-1);
% Mz_est = outparam_dat(:,end);
% Mz_est(Mz_est<0)=0;
% plot(Mz_real, 'linewidth', 1); hold on
% plot(Mz_est, 'linewidth', 1)
% set(gca,'yscale','log')
% grid
% legend('calculated Mz','estimated Mz','location', 'best')
% print(gcf,['plots/samp/Mz_calc_est_M4545_' config proc '.jpg'],'-djpeg','-r300')

figure
dnc = outparam_dat(:,4);
dnr = outparam_dat(:,6);
plot(dnc,'linewidth',1); hold on
plot(dnr,'linewidth',1); hold off
set(gca,'yscale','log')
grid
legend('dnc','dnr','location','best')
print(gcf,['plots/samp/dn_comp_M4545_' config proc '.jpg'],'-djpeg','-r300')

% figure
% cloudfrac = outparam_dat(:,3);
% plot(cloudfrac,'linewidth',1)
% print(gcf,['plots/samp/cloudfrac_M4545' config proc '.jpg'],'-djpeg','-r300')
