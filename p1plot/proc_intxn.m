clearvars -except cmaps
close all
clear global
global indvar_name_set indvar_name_all indvar_ename_set indvar_ename_all ...
   indvar_units_set indvar_units_all 

condcoll_dev = devfun(load('pfm_summary/orig_thres_condcoll_pfm.mat').pfm);
condcollsed_dev = devfun(load('pfm_summary/orig_thres_condcollsed_pfm.mat').pfm);
fullmic_dev = devfun(load('pfm_summary/orig_thres_fullmic_pfm.mat').pfm);

global_var
get_var_comp([3:7 10])

figure('position', [0 0 800 300])
tl = tiledlayout('flow', 'TileSpacing', 'compact');

% ccs - cc
nexttile
devdiff2fig(condcoll_dev, condcollsed_dev)
title('(a) Case b-c (effect of Sed.)')

% fullmic - ccs
nexttile
devdiff2fig(condcollsed_dev, fullmic_dev)
title('(b) Case a-b (effect of Evap.)')
ylabel('Change in standard dev.')

title(tl, 'Interaction effect on AMP-bin difference', 'fontweight', 'bold', 'fontsize', 20)
ylabel(tl, 'Change in AMP-bin % diff. (pp)', 'fontweight', 'bold', 'fontsize', 16)

exportgraphics(gcf,['plots/p1/proc_intxn.png'],'Resolution',300)
