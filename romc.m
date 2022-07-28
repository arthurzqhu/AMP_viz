clear
clear global

global nikki

close all

addpath('ramsfuncs/')

nikki = 'yesUV';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconfs = length(mconfig_ls);

mconfig = mconfig_ls{1};
time = readmatrix(sprintf('rams_ml_dataset/%s_time.txt',mconfig(1:end-4)));
lon = readmatrix(sprintf('rams_ml_dataset/%s_lon.txt',mconfig(1:end-4)));
lat = readmatrix(sprintf('rams_ml_dataset/%s_lat.txt',mconfig(1:end-4)));

vars_table = {'pressure', 'temperature', 'mixing ratio', ...
   'cloud water content', 'rain water content', ...
   'cloud number conc.', 'rain number conc.'};

complexity_punish = [1 1.01 1.02 1.02 1.03 1.03 1.04 1.04 1.05 1.06]';

% for its = 1:2

its = 2;
bin_output_flattened = readmatrix(sprintf('rams_ml_dataset/%s_bin_%s.txt', mconfig(1:end-4), bintype{its}));
npts = size(bin_output_flattened, 1);
nvars = size(bin_output_flattened, 2);
amp_output_flattened = zeros([npts nvars nconfs]);

% amp_output_flattened in (npts, nvars, nconfs), iconf represents the moment combination
% this order makes min() automatically prefer lower order (simpler) moment combinations
for iconf = [1:3 5 4 6:10] 
   mconfig = mconfig_ls{iconf}
   amp_output_flattened(:, :, iconf) = readmatrix(sprintf('rams_ml_dataset/%s_amp_%s.txt', mconfig, bintype{its}), 'ExpectedNumVariables', nvars);
end

% find the best momcombo in every point in xyzt
diff_flattened = abs(amp_output_flattened - bin_output_flattened);

% make sure all ratios <= 1 to avoid infinity, larger value = more similar AMP vs bin
ratio_flattened = 1./abslog(amp_output_flattened./bin_output_flattened);

bestmom_each_var = zeros([npts nvars]);
bestmom_all_vars = zeros([npts 1]);

parfor ipt = 1:npts
   [~, bestmom_all_vars(ipt)] = max(squeeze(nanmean(ratio_flattened(ipt,:,:),2))./complexity_punish);
end

for ivar = 1:nvars
   figure('position',[0 0 800 400])
   plot(bin_output_flattened(:, ivar), bestmom_all_vars, 'o')
   print(sprintf('plots/rams/%s/bestmom_all_vars_%s_%s.png', nikki, vars_table{ivar}, ...
      bintype{its}), '-dpng', '-r300')
end
