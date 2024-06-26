clearvars -except cmaps
clear global
close all

global mconfig

nikki = 'conftest_fullmic';
global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);
conflist = 1:nconf;

for iconf = 1:nconf
icase = conflist(iconf);
disp(icase)

mconfig = mconfig_ls{icase};
load(['pfm_summary/',nikki,'_', mconfig, '_pfm.mat'])
% load(['flags_summary/',nikki,'_perinit_flags.mat'])

% flag_cat = fieldnames(flags(1));
% flag_var = fieldnames(flags(1).(flag_cat{1}).sbm);

case_dep_var

indvar_name = fieldnames(pfm);
name_idx = contains(indvar_name_all,indvar_name);
indvar_ename = indvar_ename_all(name_idx);
indvar_units = indvar_units_all(name_idx);

% flag_cat = fieldnames(flags(1));
% flag_var = fieldnames(flags(1).(flag_cat{1}).sbm);

vars = 1;
% vare = vars;
vare = length(indvar_name)-1;
% mom_tested = [1 2 4:9];
nvar1 = size(pfm.(indvar_name{1}).(bintype{1}).mr,1);
nvar2 = size(pfm.(indvar_name{1}).(bintype{1}).mr,2);

mom_cell = cell(nvar1,nvar2);
mom_matrix = zeros(nvar1,nvar2);
nvar1_trim = nvar1/2;
momcombo_sum = [];

for its = 1:2
   for ivar = vars:vare
      simscore = pfm.(indvar_name{ivar}).(bintype{its}).simscore; % larger = better
      rsq = pfm.(indvar_name{ivar}).(bintype{its}).rsq; % larger = better
      % [ss_sorted,ss_sortIdx] = sort(simscore(:),'ascend','MissingPlacement','first');
      % [rsq_sorted,rsq_sortIdx] = sort(rsq(:),'ascend','MissingPlacement','first');
      mval.(indvar_name{ivar}).(bintype{its})(iconf) = pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(1);

      abslogmr = abs(log(pfm.(indvar_name{ivar}).(bintype{its}).mr)); 
      adj_abslogmr = 1-abslogmr; % larger = better
      % [abslogmr_sorted,abslogmr_sortIdx] = sort(adj_abslogmr(:),'ascend','MissingPlacement','first');

      if contains(indvar_name{ivar},'half_life')
         overall_score = adj_abslogmr;
      else
         overall_score = simscore;
      end
      [ovs_sorted, ovs_sortIdx] = sort(overall_score(:), 'descend', 'MissingPlacement','last');

      for ivar1 = 1:nvar1
         for ivar2 = 1:nvar2
            if isnan(overall_score(ivar1,ivar2))
               ranking.(bintype{its}).(indvar_name{ivar})(ivar1,ivar2) = nan;
            else
               % in the rare case of same overall score ...
               temp_rank = find(ovs_sorted==overall_score(ivar1,ivar2));
               if length(temp_rank) > 1
                  temp_rank = min(temp_rank);
               end
               ranking.(bintype{its}).(indvar_name{ivar})(ivar1,ivar2) = temp_rank;
            end
         end
      end
      mom_matrix = overall_score;
      score(iconf).(bintype{its}).(indvar_name{ivar}) = mom_matrix;

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
            score1 = score(iconf).(bintype{its}).(indvar_name{ivar})(icombo, ivar2);
            score2 = score(iconf).(bintype{its}).(indvar_name{ivar})(ireverse, ivar2);

            score_best = max([score1, score2]);
            score_trim(iconf).(bintype{its}).(indvar_name{ivar})(icombo_folded, ivar2) = score_best;

         end
      end

   end % ivar

   icombo_folded = 0;
   for icombo = 1:length(var1_str)
      momcombo = momcombo_cell{icombo};

      if str2num(momcombo(1)) > str2num(momcombo(3))
         continue
      end
      icombo_folded = icombo_folded + 1;
      ireverse = find(ismember(momcombo_cell,reverse(momcombo)));

      % for ivar2 = 1:nvar2
      %    for icat = 1:length(flag_cat)
      %       for ifvar = 1:length(flag_var)
      %          flag1 = flags(iconf).(flag_cat{icat}).(bintype{its}).(flag_var{ifvar})(icombo,ivar2);
      %          flag2 = flags(iconf).(flag_cat{icat}).(bintype{its}).(flag_var{ifvar})(ireverse,ivar2);
      %          if contains(flag_var{ifvar}, 'failure')
      %             flag_best = min([flag1 flag2]);
      %          elseif contains(flag_var{ifvar}, 'success')
      %             flag_best = max([flag1 flag2]);
      %          end
      %          flags_trim(iconf).(bintype{its}).(flag_cat{icat}).(flag_var{ifvar})(icombo_folded, ivar2) = flag_best;
      %       end
      %    end
      % end

   end
end

clear ranking
end % iconf

save('score_summary/fullmic_mval_conftest.mat','mval')
save('score_summary/fullmic_scores_conftest.mat', 'score_trim')
% save('score_summary/fullmic_rsq_conftest.mat', 'score_rsq_trim')
% save('flags_summary/fullmic_flags_conftest.mat','flags_trim')
% save('score_summary/scores2m_conftest.mat', 'score')
