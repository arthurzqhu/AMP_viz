% clear
% clear global
% close all

% global mconfig ivar2 ivar1 its nikki output_dir vnum ...
%    bintype var1_str var2_str indvar_name indvar_name_set ...
%    indvar_ename indvar_ename_set ispath isproc isprof iscloud ...
%    israin indvar_units_set indvar_units%#ok<*NUSED>

% vnum='0001' % last four characters of the model output file.
% nikki='2022-08-03';

% global_var

% % get the list of configs. cant put it into globar_var
% mconfig_ls = get_mconfig_list(output_dir, nikki);

% for iconf = 1:3
%    mconfig = mconfig_ls{iconf}
%    case_dep_var
%    get_var_comp([3:7 10])
%    for its = 1%:length(bintype)
%       for ivar1 = 1:length(var1_str)
%          for ivar2 = 1:length(var2_str)
%             [its ivar1 ivar2]    
%             bin_struct = loadnc('bin');
%             amp_struct = loadnc('amp');
%             vars=1;
%             vare=length(indvar_name);

%             time = amp_struct.time;
%             z = amp_struct.z;
%             dz = z(2)-z(1);

%             for ivar = vars:vare

%                var_comp_raw_amp = amp_struct.(indvar_name{ivar});
%                var_amp_flt = var2phys(var_comp_raw_amp,ivar,0,1,1);
%                var_comp_raw_bin = bin_struct.(indvar_name{ivar});
%                var_bin_flt = var2phys(var_comp_raw_bin,ivar,0,1,1);

%                vidx = ~isnan(var_amp_flt+var_bin_flt);
%                nzidx = var_amp_flt.*var_bin_flt>0;

%                weight = var_bin_flt(vidx)/sum(var_bin_flt(vidx));
%                weight_log = log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));

%                rat_flt{ivar1, ivar2, ivar}(iconf,:) = abs(log(var_amp_flt(vidx)./var_bin_flt(vidx)));
%                % smaller value = more similar to bin

%                [mr, rsq] = wrsq(var_amp_flt, var_bin_flt, weight);
%                mean_rat{ivar1, ivar2, ivar}(iconf) = abs(log(mr));
%                rsq_suite{ivar1, ivar2, ivar}(iconf) = rsq;

%             end

%          end
%       end
%    end
% end

% for ivar = vars:vare
%    rank_2m_dt50_elem{ivar} = zeros(3,1);
%    rank_2m_dt80_elem{ivar} = zeros(3,1);
%    rank_4m_dt80_elem{ivar} = zeros(3,1);
%    rank_2m_dt50_mr{ivar} = zeros(3,1);
%    rank_2m_dt80_mr{ivar} = zeros(3,1);
%    rank_4m_dt80_mr{ivar} = zeros(3,1);
%    rank_2m_dt50_rsq{ivar} = zeros(3,1);
%    rank_2m_dt80_rsq{ivar} = zeros(3,1);
%    rank_4m_dt80_rsq{ivar} = zeros(3,1);

   
%    for ivar1 = 1:length(var1_str)
%       for ivar2 = 1:length(var2_str)
%          [~, idx_elem] = sort(rat_flt{ivar1, ivar2, ivar});
%          idx_elem_nonan = idx_elem .* ~isnan(rat_flt{ivar1, ivar2, ivar});
%          [~, idx_mr] = sort(mean_rat{ivar1, ivar2, ivar});
%          idx_mr_nonan = idx_mr .* ~isnan(mean_rat{ivar1, ivar2, ivar});
%          [~, idx_rsq] = sort(rsq_suite{ivar1, ivar2, ivar});
%          idx_rsq_nonan = idx_rsq .* ~isnan(rsq_suite{ivar1, ivar2, ivar});

%          for irank = 1:3
%             rank_2m_dt50_elem{ivar}(irank) = rank_2m_dt50_elem{ivar}(irank) + ...
%                sum(idx_elem_nonan(1,:)==irank);
%             rank_2m_dt80_elem{ivar}(irank) = rank_2m_dt80_elem{ivar}(irank) + ...
%                sum(idx_elem_nonan(2,:)==irank);
%             rank_4m_dt80_elem{ivar}(irank) = rank_4m_dt80_elem{ivar}(irank) + ...
%                sum(idx_elem_nonan(3,:)==irank);

%             rank_2m_dt50_mr{ivar}(irank) = rank_2m_dt50_mr{ivar}(irank) + ...
%                sum(idx_mr_nonan(1)==irank);
%             rank_2m_dt80_mr{ivar}(irank) = rank_2m_dt80_mr{ivar}(irank) + ...
%                sum(idx_mr_nonan(2)==irank);
%             rank_4m_dt80_mr{ivar}(irank) = rank_4m_dt80_mr{ivar}(irank) + ...
%                sum(idx_mr_nonan(3)==irank);

%             rank_2m_dt50_rsq{ivar}(irank) = rank_2m_dt50_rsq{ivar}(irank) + ...
%                sum(idx_rsq_nonan(1)==irank);
%             rank_2m_dt80_rsq{ivar}(irank) = rank_2m_dt80_rsq{ivar}(irank) + ...
%                sum(idx_rsq_nonan(2)==irank);
%             rank_4m_dt80_rsq{ivar}(irank) = rank_4m_dt80_rsq{ivar}(irank) + ...
%                sum(idx_rsq_nonan(3)==irank);
%          end
%       end
%    end
% end

figure('position',[0 0 1400 600])
tl = tiledlayout('flow');

for ivar = vars:vare
   X = categorical({'2M 2-cat Dt50', '2M 2-cat Dt80', '4M 1-cat Dt80'});
   X = reordercats(X, {'2M 2-cat Dt50', '2M 2-cat Dt80', '4M 1-cat Dt80'});

   nexttile
   bars_mat = [rank_2m_dt50_mr{ivar} rank_2m_dt80_mr{ivar} rank_4m_dt80_mr{ivar}]';
   bar(X, bars_mat)
   title(indvar_ename{ivar})
   ylim([0 25])

   xlabel(tl, 'Microphysics Scheme')
   ylabel(tl, '# of test cases')
   title(tl, 'mean AMP/bin ratio')
end

legend('# 1st place', '# 2nd place', '# 3rd place', 'location', 'best')
saveas(gcf,'mean_ratio_comp.png')
saveas(gcf,'mean_ratio_comp.fig')
