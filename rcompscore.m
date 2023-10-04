clear
clear global
close all

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iab l_da var1_str var2_str ivar1 ivar2

nikki = '2023-08-30';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);
mconfig = mconfig_ls{1};

rcase_dep_var
nvar1 = length(var1_str);
nvar2 = length(var2_str);
var_int_idx = [1:3 36];
iab = 1;

var_interest = get_varint(var_int_idx);
varname_interest = {var_interest.var_name};
varename_interest = {var_interest.da_ename};
varunit_interest = {var_interest.units};
nvar = length(varname_interest);

load('rpfm_summary2m.mat')

its = 2;

for iconf = 1:nconf
for ivar = 1:nvar
   mconfig=mconfig_ls{iconf};
   varn = varname_interest{ivar};
   momcombo_cell = extractAfter(var1_str,lettersPattern);
   icombo_folded = 0;
   for icombo = 1:length(var1_str)
      momcombo = momcombo_cell{icombo};
      if str2num(momcombo(1)) > str2num(momcombo(3))
         continue
      end
      icombo_folded = icombo_folded + 1;
      ireverse = find(ismember(momcombo_cell,reverse(momcombo)));
      for ivar2 = 1:nvar2
         score1 = pfm(iconf).(varn).(bintype{its}).rsq(icombo, ivar2);
         score2 = pfm(iconf).(varn).(bintype{its}).rsq(ireverse, ivar2);
         score_best = max([score1, score2]);
         % try
         %    score.(bintype{its}).(varn)(icombo_folded, ivar2) = score.(bintype{its}).(varn)(icombo_folded, ivar2) + score_best;
         % catch
         score.(bintype{its}).(varn)(icombo_folded, ivar2) = score_best;
         % end
      end
   end
end

nvar1 = length(var1_str)/2;
for ivar = 1:nvar
   varn = varname_interest{ivar};
   score_matrix = score.(bintype{its}).(varn);
   figure(1)
   set(gcf,'position',[0 0 600 600])
   nanimagesc(score_matrix)
   colormap(gca,cmaps.magma_r)
   colorbar

   sorted_score = sort(score_matrix(:), 'descend', 'MissingPlacement','last');
   [~, ranking] = ismember(score_matrix, sorted_score);
   ranking = reshape(ranking, size(score_matrix));

   ranking_str = sprintfc('%d', ranking);
   % note the ranking 1-10 on the grid
   for ivar1 = 1:nvar1
      for ivar2 = 1:nvar2
         if ranking(ivar1, ivar2)>10 || ranking(ivar1, ivar2)==0
            continue
         end
         text(ivar2+.03,ivar1-.03,ranking_str{ivar1,ivar2},...
            'HorizontalAlignment','center','color',[0 0 0])
         text(ivar2,ivar1,ranking_str{ivar1,ivar2},...
            'HorizontalAlignment','center','color',[1 1 1])
      end
   end

   xticks(1:nvar2)
   xticklabels(sp_combo_str)
   yticks(1:nvar1)
   yticklabels(momcombo_trimmed)

   caxis([0 1])
   exportgraphics(gcf,['plots/p2/rams2m_score ', mconfig, ' ', varn, '.pdf'])

end
end
