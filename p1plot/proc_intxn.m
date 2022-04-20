clear
clear global
close all
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all

% condonly_dev=devfun(load('pfm_summary/2022-04-17_condonly_mod_pfm.mat').pfm);
% collonly_dev=devfun(load('pfm_summary/2022-04-17_collonly_pfm.mat').pfm);
% condcoll_dev=devfun(load('pfm_summary/2022-04-17_condcoll_mod_pfm.mat').pfm);

condonly_dev=devfun(load('pfm_summary/2022-04-18_evaponly_mod_pfm.mat').pfm);
collonly_dev=devfun(load('pfm_summary/2022-04-18_collsed_pfm.mat').pfm);
condcoll_dev=devfun(load('pfm_summary/2022-04-18_collsedevap_mod_pfm.mat').pfm);

global_var
get_var_comp([3 4 6 7 10])
% get_var_comp([3:7 16])

%% 
close all

% convert nan to 1 so that multiplication works

condonly_dev.ratio.mean_surface_ppt = [1 1];
condonly_dev.mean_val.mean_surface_ppt = [0 0];
% condonly_dev.ratio.rain_M1_path = [1 1];
% condonly_dev.ratio.diagM0_rain = [1 1];

% condonly_dev.ratio.half_life_c = [1 1];
% condonly_dev.ratio.rain_M1_path = [1 1];
% condonly_dev.ratio.diagM0_rain = [1 1];

% these should have the same fieldnames
varnames = fieldnames(collonly_dev.ratio);
varsplot = find(contains(varnames, indvar_name_set));
ivarset = contains(indvar_name_all, varnames(varsplot));

figure('position',[0 0 1200 800])
tl = tiledlayout('flow');
for ivar = 1:length(varsplot)

   Y_effprod = [condonly_dev.ratio.(varnames{ivar}) .* ...
      collonly_dev.ratio.(varnames{ivar})];
   Y_effcomb = [condcoll_dev.ratio.(varnames{ivar})];

   % Xcell = {'Cond. only * Coll. only', 'Cond. + Coll'};
   Xcell = {'(Coll. Sed.) * (Evap. only)', 'Coll. Sed. Evap.'};
   X=categorical(Xcell);
   X=reordercats(X,Xcell);

   %%
   nexttile
   hold on
   b = bar(X, [Y_effprod; Y_effcomb]);
   b(1).BaseValue=1;
   b(1).BaseLine.Color=[.8 .8 .8];

   % b(1).FaceColor=color_order{1};
   % b(2).FaceColor=color_order{2};
   % b(1).FaceAlpha=0.5;
   % b(2).FaceAlpha=0.5;
   % b(1).LineWidth=1;
   % b(2).LineWidth=1;

   title(indvar_ename_set{ivar})

   hold off

   set(gca,'YScale','log')

   ylim([.5 2])
   yticks([0.5 0.8 1 1.5 2])
   yticklabels({'-50','-20','0','50','100'})

   % ylim([.67 1.5])
   % yticks([0.67 0.8 1 1.2 1.5])
   % yticklabels({'-33','-20','0','20','50'})

   grid

   set(gca,'fontsize',12)

end

saveas(gcf,'plots/p1/proc_intxn.png')
