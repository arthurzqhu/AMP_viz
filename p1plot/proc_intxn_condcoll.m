clear
clear global
close all
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all

condonly_pfm = load('pfm_summary/proc_intxn_condcoll_condonly_mod_pfm.mat').pfm;
collonly_pfm = load('pfm_summary/proc_intxn_condcoll_collonly_pfm.mat').pfm;
condcoll_pfm = load('pfm_summary/proc_intxn_condcoll_condcoll_mod_pfm.mat').pfm;

condonly_dev = devfun(load('pfm_summary/proc_intxn_condcoll_condonly_mod_pfm.mat').pfm);
collonly_dev = devfun(load('pfm_summary/proc_intxn_condcoll_collonly_pfm.mat').pfm);
condcoll_dev = devfun(load('pfm_summary/proc_intxn_condcoll_condcoll_mod_pfm.mat').pfm);

global_var
% get_var_comp([3 4 6 7 10])
get_var_comp([3:5 16])

%% 
close all

% convert nan to 1 so that multiplication works
condonly_dev.half_life_c = [1 1];
condonly_dev.rain_M1_path = [1 1];
condonly_dev.diagM0_rain = [1 1];

% these should have the same fieldnames
varnames = fieldnames(collonly_dev);
varsplot = find(contains(varnames, indvar_name_set));
ivarset = contains(indvar_name_all, varnames(varsplot));

figure('position',[0 0 1200 600])
tl = tiledlayout('flow');
% tl = tiledlayout(1,4);
for ivar = 1:length(varsplot)

   Y_effsum = [condonly_dev.(varnames{ivar}) + ...
      collonly_dev.(varnames{ivar})]-1;
   Y_effprod = [condonly_dev.(varnames{ivar}) .* ...
      collonly_dev.(varnames{ivar})];
   Y_proper_amp(1) = mean(condonly_pfm.(varnames{ivar}).tau.sval_amp + ...
                     condonly_pfm.(varnames{ivar}).tau.msd_amp + ...
                     collonly_pfm.(varnames{ivar}).tau.msd_amp + ...
                     condcoll_pfm.(varnames{ivar}).tau.msd_amp,'all','omitnan');
   Y_proper_bin(1) = mean(condonly_pfm.(varnames{ivar}).tau.sval_bin + ...
                     condonly_pfm.(varnames{ivar}).tau.msd_bin + ...
                     collonly_pfm.(varnames{ivar}).tau.msd_bin + ...
                     condcoll_pfm.(varnames{ivar}).tau.msd_bin,'all','omitnan');
   Y_proper_amp(2) = mean(condonly_pfm.(varnames{ivar}).sbm.sval_amp + ...
                     condonly_pfm.(varnames{ivar}).sbm.msd_amp + ...
                     collonly_pfm.(varnames{ivar}).sbm.msd_amp + ...
                     condcoll_pfm.(varnames{ivar}).sbm.msd_amp,'all','omitnan');
   Y_proper_bin(2) = mean(condonly_pfm.(varnames{ivar}).sbm.sval_bin + ...
                     condonly_pfm.(varnames{ivar}).sbm.msd_bin + ...
                     collonly_pfm.(varnames{ivar}).sbm.msd_bin + ...
                     condcoll_pfm.(varnames{ivar}).sbm.msd_bin,'all','omitnan');
   Y_proper_amp_nointxn(1) = mean(condonly_pfm.(varnames{ivar}).tau.sval_amp + ...
                     condonly_pfm.(varnames{ivar}).tau.msd_amp + ...
                     collonly_pfm.(varnames{ivar}).tau.msd_amp,'all','omitnan');
   Y_proper_bin_nointxn(1) = mean(condonly_pfm.(varnames{ivar}).tau.sval_bin + ...
                     condonly_pfm.(varnames{ivar}).tau.msd_bin + ...
                     collonly_pfm.(varnames{ivar}).tau.msd_bin,'all','omitnan');
   Y_proper_amp_nointxn(2) = mean(condonly_pfm.(varnames{ivar}).sbm.sval_amp + ...
                     condonly_pfm.(varnames{ivar}).sbm.msd_amp + ...
                     collonly_pfm.(varnames{ivar}).sbm.msd_amp,'all','omitnan');
   Y_proper_bin_nointxn(2) = mean(condonly_pfm.(varnames{ivar}).sbm.sval_bin + ...
                     condonly_pfm.(varnames{ivar}).sbm.msd_bin + ...
                     collonly_pfm.(varnames{ivar}).sbm.msd_bin,'all','omitnan');
   Y_proper = Y_proper_amp ./ Y_proper_bin;
   Y_proper_nointxn = Y_proper_amp_nointxn ./ Y_proper_bin_nointxn;
   Y_effcomb = [condcoll_dev.(varnames{ivar})];

   Xcell = {'(g) + (h) - int', '(g) + (h)', '(d)'};
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
l = legend('TAU','SBM','location','southeast');
ylabel(tl, 'AMP/bin % difference','fontweight','bold','fontsize',18)
xlabel(tl, 'Cases','fontweight','bold','fontsize',18)
title(tl, 'Interaction of Condensation and Collision-coalescence', ...
   'fontweight', 'bold', 'fontsize', 20)

exportgraphics(gcf,'plots/p1/proc_intxn_condcoll.jpg','Resolution',300)
