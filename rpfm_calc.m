clear
clear global
close all

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iab l_da var1_str var2_str ivar1 ivar2

nikki = '2023-08-30';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);

% pfm = struct;

% try
%    load('rpfm_summary2.mat')
% end

for iconf = 1:nconf
mconfig = mconfig_ls{iconf};

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

for ivar = 1:nvar
   for its = 2:2
      varn = varname_interest{ivar};
      pfm(iconf).(varn).(bintype{its}).mr = zeros(nvar1,nvar2);
      pfm(iconf).(varn).(bintype{its}).rsq = zeros(nvar1,nvar2);
      pfm(iconf).(varn).(bintype{its}).mpath_bin = zeros(nvar1,nvar2);
      pfm(iconf).(varn).(bintype{its}).mpath_amp = zeros(nvar1,nvar2);
   end
end

for ivar1 = 1:nvar1
   for ivar2 = 1:nvar2
      disp([iconf ivar1 ivar2])
      for ivar = 1:nvar
         varn = varname_interest{ivar};
         for its = 2:2
            for iab = 1:2
               mps = [ampORbin{iab} '_' bintype{its}]; % mps = microphysics scheme
               mp_runs.(mps) = loadrams(ampORbin{iab});
            end % iab

            mps_bin = ['bin_' bintype{its}];
            mps_amp = ['amp_' bintype{its}];

            t_max = size(mp_runs.(mps_amp).(varn),3);

            vidx = ~isnan(mp_runs.(mps_bin).(varn)(:,:,1:t_max) + mp_runs.(mps_amp).(varn)(:,:,1:t_max)) & ...
               ~isinf(mp_runs.(mps_bin).(varn)(:,:,1:t_max) + mp_runs.(mps_amp).(varn)(:,:,1:t_max));
            wgt = mp_runs.(mps_bin).(varn)/sum(mp_runs.(mps_bin).(varn)(:));
            [mr, rsq, mval_amp, mval_bin] = wrsq(mp_runs.(mps_amp).(varn)(vidx), ...
               mp_runs.(mps_bin).(varn)(vidx), wgt);
            pfm(iconf).(varn).(bintype{its}).mr(ivar1,ivar2) = mr;
            pfm(iconf).(varn).(bintype{its}).rsq(ivar1,ivar2) = rsq;
            pfm(iconf).(varn).(bintype{its}).mpath_bin(ivar1,ivar2) = mval_bin;
            pfm(iconf).(varn).(bintype{its}).mpath_amp(ivar1,ivar2) = mval_amp;
         end % its
      end % ivar
   end % ivar2
end % ivar1
save('rpfm_summary2m.mat','pfm')
end % iconf

