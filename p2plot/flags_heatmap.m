clearvars -except cmaps
clear global
close all

global mconfig

nikki = 'conftest_diffsp';
global_var

% as opposed to mean ratio. should be set between 0 and 1. 0.5 means rsq and mr are equally important

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);

mconfig = mconfig_ls{1};
load('flags_summary/flags_conftest.mat')
case_dep_var

flag_cat = fieldnames(flags_trim(1).sbm);
flag_var = fieldnames(flags_trim(1).sbm.(flag_cat{1}));

nvar1 = size(flags_trim(1).sbm.(flag_cat{1}).(flag_var{1}),1);
nvar2 = size(flags_trim(1).sbm.(flag_cat{1}).(flag_var{1}),2);

for its = 1:2
   for icat = 1:length(flag_cat)
      for ivar = 1:length(flag_var)
         flags_lump.(bintype{its}).(flag_cat{icat}).(flag_var{ivar}) = zeros(nvar1, nvar2);
      end
   end
end

for iconf = 1:length(flags_trim)
   for its = 1:2
      for icat = 1:length(flag_cat)
         for ivar = 1:length(flag_var)
            flag_mat = flags_trim(iconf).(bintype{its}).(flag_cat{icat}).(flag_var{ivar});
            flags_lump.(bintype{its}).(flag_cat{icat}).(flag_var{ivar}) = ...
               flags_lump.(bintype{its}).(flag_cat{icat}).(flag_var{ivar}) + flag_mat/nconf;
         end
      end
   end
end

% plot flags
for icat = 1%:length(flag_cat)
   for ivar = 1:length(flag_var)
      figure(1)
      set(gcf,'position',[0 0 1000 400])
      tl = tiledlayout(1,2);
      for its = 1:2
         nexttile
         flags_lump_tmp = flags_lump.(bintype{its}).(flag_cat{icat}).(flag_var{ivar});
         nanimagesc(flags_lump_tmp)
         cb = colorbar;
         cb.Label.String = 'Flags';
         colormap(gca,cmaps.magma_r)
         title(['(',Alphabet(its),') ',upper(bintype{its})],'FontWeight','normal')
         xticks(1:nvar2)
         xticklabels(sp_combo_str)
         yticks(1:nvar1)
         yticklabels(momcombo_trimmed)
         xlab_key = extractBefore(var2_str,digitsPattern);
         ylab_key = extractBefore(var1_str,digitsPattern);
         xlab = [initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
         ylab = [initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
         xlabel(tl,xlab,'fontsize',16)
         ylabel(tl,ylab,'fontsize',16)
         set(gca,'fontsize',16)
      end
      title(tl, ['Success rate of parameter finding for each configuration'], 'fontsize', 24,...
         'fontweight','bold')
      exportgraphics(gcf,['plots/p2/' flag_cat{icat} ' ' flag_var{ivar} '.pdf'])
   end
end
