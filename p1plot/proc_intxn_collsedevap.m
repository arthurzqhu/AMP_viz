clear
clear global
close all
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all

evaponly_pfm = load('pfm_summary/proc_intxn_collsedevap_evaponly_mod_pfm.mat').pfm;
collsed_pfm = load('pfm_summary/proc_intxn_collsedevap_collsed_pfm.mat').pfm;
collsedevap_pfm = load('pfm_summary/proc_intxn_collsedevap_collsedevap_mod_pfm.mat').pfm;

evaponly_dev = devfun(load('pfm_summary/proc_intxn_collsedevap_evaponly_mod_pfm.mat').pfm);
collsed_dev = devfun(load('pfm_summary/proc_intxn_collsedevap_collsed_pfm.mat').pfm);
collsedevap_dev = devfun(load('pfm_summary/proc_intxn_collsedevap_collsedevap_mod_pfm.mat').pfm);

global_var
get_var_comp([3:5 10])

%% 
close all

% convert nan to 1 so that multiplication works
evaponly_dev.rain_M1_path = [1 1];
evaponly_dev.diagM0_rain = [1 1];
evaponly_dev.mean_surface_ppt = [1 1];

% these should have the same fieldnames
varnames = fieldnames(collsed_dev);
varsplot = find(contains(varnames, indvar_name_set));
ivarset = contains(indvar_name_all, varnames(varsplot));

figure('position',[0 0 1200 600])
tl = tiledlayout('flow');
for ivar = 1:length(varsplot)

   Y_effsum = [evaponly_dev.(varnames{ivar}) + ...
      collsed_dev.(varnames{ivar})]-1;
   Y_effprod = [evaponly_dev.(varnames{ivar}) .* ...
      collsed_dev.(varnames{ivar})];
   Y_proper_amp(1) = mean(evaponly_pfm.(varnames{ivar}).tau.sval_amp + ...
                     evaponly_pfm.(varnames{ivar}).tau.msd_amp + ...
                     collsed_pfm.(varnames{ivar}).tau.msd_amp + ...
                     collsedevap_pfm.(varnames{ivar}).tau.msd_amp,'all','omitnan');
   Y_proper_bin(1) = mean(evaponly_pfm.(varnames{ivar}).tau.sval_bin + ...
                     evaponly_pfm.(varnames{ivar}).tau.msd_bin + ...
                     collsed_pfm.(varnames{ivar}).tau.msd_bin + ...
                     collsedevap_pfm.(varnames{ivar}).tau.msd_bin,'all','omitnan');
   Y_proper_amp(2) = mean(evaponly_pfm.(varnames{ivar}).sbm.sval_amp + ...
                     evaponly_pfm.(varnames{ivar}).sbm.msd_amp + ...
                     collsed_pfm.(varnames{ivar}).sbm.msd_amp + ...
                     collsedevap_pfm.(varnames{ivar}).sbm.msd_amp,'all','omitnan');
   Y_proper_bin(2) = mean(evaponly_pfm.(varnames{ivar}).sbm.sval_bin + ...
                     evaponly_pfm.(varnames{ivar}).sbm.msd_bin + ...
                     collsed_pfm.(varnames{ivar}).sbm.msd_bin + ...
                     collsedevap_pfm.(varnames{ivar}).sbm.msd_bin,'all','omitnan');
   Y_proper_amp_nointxn(1) = mean(evaponly_pfm.(varnames{ivar}).tau.sval_amp + ...
                     evaponly_pfm.(varnames{ivar}).tau.msd_amp + ...
                     collsed_pfm.(varnames{ivar}).tau.msd_amp,'all','omitnan');
   Y_proper_bin_nointxn(1) = mean(evaponly_pfm.(varnames{ivar}).tau.sval_bin + ...
                     evaponly_pfm.(varnames{ivar}).tau.msd_bin + ...
                     collsed_pfm.(varnames{ivar}).tau.msd_bin,'all','omitnan');
   Y_proper_amp_nointxn(2) = mean(evaponly_pfm.(varnames{ivar}).sbm.sval_amp + ...
                     evaponly_pfm.(varnames{ivar}).sbm.msd_amp + ...
                     collsed_pfm.(varnames{ivar}).sbm.msd_amp,'all','omitnan');
   Y_proper_bin_nointxn(2) = mean(evaponly_pfm.(varnames{ivar}).sbm.sval_bin + ...
                     evaponly_pfm.(varnames{ivar}).sbm.msd_bin + ...
                     collsed_pfm.(varnames{ivar}).sbm.msd_bin,'all','omitnan');
   Y_proper = Y_proper_amp ./ Y_proper_bin;
   Y_proper_nointxn = Y_proper_amp_nointxn ./ Y_proper_bin_nointxn;
   Y_effcomb = [collsedevap_dev.(varnames{ivar})];

   Xcell = {'(e) + (j) - int','(e) + (j)', '(c)'};
   X=categorical(Xcell);
   X=reordercats(X,Xcell);

   %%
   nexttile
   hold on
   b = bar(X, [Y_proper_nointxn; Y_proper; Y_effcomb]);
   b(1).BaseValue=1;
   b(1).BaseLine.Color=[.8 .8 .8];
   b(1).FaceAlpha=0.75;
   b(2).FaceAlpha=0.75;
   title(indvar_ename_set{ivar})
   hold off
   set(gca,'YScale','log')
   ylim([.67 1.5])
   yticks([0.67 0.8 1 1.2 1.5])
   yticklabels({'-33','-20','0','20','50'})
   grid
   set(gca,'fontsize',16)

end
l = legend('TAU','SBM','location','northeast');
ylabel(tl, 'AMP/bin % difference','fontweight','bold','fontsize',18)
xlabel(tl, 'Cases','fontweight','bold','fontsize',18)
title(tl, 'Interaction of Collision, Sedimentation, and Evaporation', ...
   'fontweight', 'bold', 'fontsize', 20)

exportgraphics(gcf,'plots/p1/proc_intxn_collsedevap.jpg','Resolution',300)
