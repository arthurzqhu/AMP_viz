clearvars -except cmaps
clear global
close all

global mconfig

nikki = 'conftest_nodown';
global_var

% as opposed to mean ratio. should be set between 0 and 1. 0.5 means rsq and mr are equally important
rsq_importance = 0.5; 

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);
conflist = 1:nconf;

for iconf = 1:nconf
icase = conflist(iconf);
disp(icase)

mconfig = mconfig_ls{icase};
load(['pfm_summary/',nikki,'_', mconfig, '_pfm.mat'])
case_dep_var

indvar_name = fieldnames(pfm);
name_idx = contains(indvar_name_all,indvar_name);
indvar_ename = indvar_ename_all(name_idx);
indvar_units = indvar_units_all(name_idx);

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
      rsq = pfm.(indvar_name{ivar}).(bintype{its}).rsq; % larger = better
      [rsq_sorted,rsq_sortIdx] = sort(rsq(:),'ascend','MissingPlacement','first');
      mval.(indvar_name{ivar}).(bintype{its})(iconf) = pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(1);

      abslogmr = abs(log(pfm.(indvar_name{ivar}).(bintype{its}).mr)); 
      adj_abslogmr = 1-abslogmr; % larger = better
      [abslogmr_sorted,abslogmr_sortIdx] = sort(adj_abslogmr(:),'ascend','MissingPlacement','first');

      if contains(indvar_name{ivar},'half_life')
         overall_score = adj_abslogmr;
      else
         overall_score = rsq*rsq_importance + adj_abslogmr*(1-rsq_importance);
      end
      [ovs_sorted, ovs_sortIdx] = sort(overall_score(:), 'descend', 'MissingPlacement','last');

      if contains(mconfig,'momcombo')
         % fold the grid and find the better moment combination between XY and YX
         % +1/-1 proabbly not necessary but added for better readability
         for imomx = 1:nvar1
            for imomy = imomx+1:nvar2+1
               score_xy = overall_score(imomx,imomy-1);
               score_yx = overall_score(imomy-1,imomx);
               score_better = max([score_xy, score_yx]);
               mom_matrix(imomx, imomy-1) = score_better;
               mom_matrix(imomy-1, imomx) = nan;
            end
         end
         % for every moment combination I want a rank of how good it is at predicting each variable
         for imomx = 1:nvar1
            for imomy = imomx+1:nvar2+1
               if isnan(mom_matrix(imomx,imomy-1))
                  ranking.(bintype{its}).(indvar_name{ivar})(imomx,imomy-1) = nan;
               else
                  % in the rare case of same overall score ...
                  temp_rank = find(ovs_sorted==mom_matrix(imomx,imomy-1));
                  if length(temp_rank) > 1
                     temp_rank = min(temp_rank);
                  end
                  ranking.(bintype{its}).(indvar_name{ivar})(imomx,imomy-1) = temp_rank;
                  ranking.(bintype{its}).(indvar_name{ivar})(imomy-1,imomx) = nan;
               end
            end
         end

      else
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
      end
      score(iconf).(bintype{its}).(indvar_name{ivar}) = mom_matrix;

      momcombo_cell = extractAfter(var1_str,lettersPattern);
      icombo_folded = 0;
      for icombo = 1:length(var1_str)
         momcombo = momcombo_cell{icombo};
         if str2num(momcombo(1)) > str2num(momcombo(2))
            continue
         end
         icombo_folded = icombo_folded + 1;
         ireverse = find(ismember(momcombo_cell,reverse(momcombo)));
         for ivar2 = 1:nvar2
            score1 = score(iconf).(bintype{its}).(indvar_name{ivar})(icombo, ivar2);
            score2 = score(iconf).(bintype{its}).(indvar_name{ivar})(ireverse, ivar2);
            score_best = max([score1, score2]);
            score_trim(iconf).(bintype{its}).(indvar_name{ivar})(icombo_folded, ivar2) = score_best;
            mr_trim(iconf).(bintype{its}).(indvar_name{ivar})(icombo_folded, ivar2) = score_best;
         end
      end

   end % ivar

end

% plot
% for ivar = vars:vare
%    figure(1)
%    set(gcf,'position',[0 0 1250 600])
%    tl = tiledlayout(2,1);

%    for its = 1:2

%       nexttile
%       % score_by_momcombo = score(iconf).(bintype{its}).(indvar_name{ivar});
%       score_best_by_momcombo = score_trim(iconf).(bintype{its}).(indvar_name{ivar});
%       % nanimagesc(score_by_momcombo')
%       nanimagesc(score_best_by_momcombo')
%       cb = colorbar;
%       cb.Label.String = 'Score';
%       caxis([.5 1])
%       colormap(gca,cmaps.magma_r)
%       title(upper(bintype{its}),'FontWeight','normal')
%       if contains(mconfig,'momcombo')
%          xticks(2:nvar2)
%          yticks(1:nvar1-1)
%          xlim([1.5 nvar2+.5])
%          ylim([0.5 nvar1-.5])
%          xticklabels(extractAfter(var1_str(2:end),lettersPattern))
%       else
%          % xticks(1:nvar1)
%          xticks(1:nvar1_trim)
%          xticklabels(momcombo_trimmed)
%          % yticks(1:nvar1)
%          % xticklabels(extractAfter(var1_str,lettersPattern))
%       end
%       yticklabels(extractAfter(var2_str,lettersPattern))
%       xlab_key = extractBefore(var1_str,digitsPattern);
%       ylab_key = extractBefore(var2_str,digitsPattern);
%       xlab = [initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
%       ylab = [initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
%       xlabel(tl,xlab,'fontsize',16)
%       ylabel(tl,ylab,'fontsize',16)

%       % rank_by_momcombo = ranking.(bintype{its}).(indvar_name{ivar});
%       % rank_str = sprintfc('%d', rank_by_momcombo);

%       % % note the ranking 1-10 on the grid
%       % if contains(mconfig,'momcombo')
%       %    for imomx = 1:nvar1
%       %       for imomy = imomx:nvar2
%       %          if rank_by_momcombo(imomx, imomy)>10 || isnan(rank_by_momcombo(imomx, imomy))
%       %             continue
%       %          end
%       %          text(imomy+.015,imomx-.015,rank_str{imomx,imomy},...
%       %             'HorizontalAlignment','center','color',[.5 .5 .5])
%       %          text(imomy,imomx,rank_str{imomx,imomy},...
%       %             'HorizontalAlignment','center','color',[1 1 1])
%       %       end
%       %    end
%       % else
%       %    for ivar1 = 1:nvar1
%       %       for ivar2 = 1:nvar2
%       %          if rank_by_momcombo(ivar1, ivar2)>10 || isnan(rank_by_momcombo(ivar1, ivar2))
%       %             continue
%       %          end
%       %          text(ivar2+.015,ivar1-.015,rank_str{ivar1,ivar2},...
%       %             'HorizontalAlignment','center','color',[.5 .5 .5])
%       %          text(ivar2,ivar1,rank_str{ivar1,ivar2},...
%       %             'HorizontalAlignment','center','color',[1 1 1])
%       %       end
%       %    end
%       % end

%    end

%    title(tl,[indvar_ename{ivar} indvar_units{ivar} ...
%       ],'fontsize',20,'fontweight','bold')
%    % saveas(gcf,['plots/', nikki, '/', mconfig, ' ', indvar_name{ivar}, ' rank folded.png'])
% end % ivar
clear ranking
end % iconf

save('score_summary/mval_conftest.mat','mval')
save('score_summary/scores_conftest.mat', 'score_trim')
% save('score_summary/scores2m_conftest.mat', 'score')
