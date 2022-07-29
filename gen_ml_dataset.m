clear
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iab
close all

addpath('ramsfuncs/')

nikki = 'noUV';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);

var_int_idx = [4:5 10:11 13:14 18:21];

l_da = 0;



for iconf = 1:length(mconfig_ls)
   mconfig = mconfig_ls{iconf}
   % load RAMS output
   for its = 1:length(bintype)
      iab = 1;
      % get var_interest as an object
      var_interest = get_varint(var_int_idx);
      mps = [ampORbin{iab} '_' bintype{its}];
      mp_runs.(mps) = loadrams(ampORbin{iab});
      mat2write_amp(:,1) = mp_runs.(mps).pres(:);
      mat2write_amp(:,2) = mp_runs.(mps).temp(:);
      mat2write_amp(:,3) = mp_runs.(mps).Rv(:);
      mat2write_amp(:,4) = mp_runs.(mps).CWC(:);
      mat2write_amp(:,5) = mp_runs.(mps).RWC(:);
      mat2write_amp(:,6) = mp_runs.(mps).CNC(:);
      mat2write_amp(:,7) = mp_runs.(mps).RNC(:);
      mat2write_amp(:,8) = mp_runs.(mps).flagc(:);
      mat2write_amp(:,9) = mp_runs.(mps).flagr(:);
      writematrix(mat2write_amp, sprintf('rams_ml_dataset/%s_%s.txt', mconfig, mps))
   end
end

clear mat2write_amp

for its = 1:length(bintype)
   mconfig = mconfig_ls{1}
   iab = 2;

   % get var_interest as an object
   var_interest = get_varint(var_int_idx);
   mps = [ampORbin{iab} '_' bintype{its}];
   mp_runs.(mps) = loadrams(ampORbin{iab});

   mat2write_bin(:,1) = mp_runs.(mps).pres(:);
   mat2write_bin(:,2) = mp_runs.(mps).temp(:);
   mat2write_bin(:,3) = mp_runs.(mps).Rv(:);
   mat2write_bin(:,4) = mp_runs.(mps).CWC(:);
   mat2write_bin(:,5) = mp_runs.(mps).RWC(:);
   mat2write_bin(:,6) = mp_runs.(mps).CNC(:);
   mat2write_bin(:,7) = mp_runs.(mps).RNC(:);

   writematrix(mat2write_bin, sprintf('rams_ml_dataset/%s_%s.txt', mconfig(1:end-4), mps))
end

writematrix(runs.GLON, sprintf('rams_ml_dataset/%s_lon.txt',mconfig(1:end-4)))
writematrix(runs.GLAT, sprintf('rams_ml_dataset/%s_lat.txt',mconfig(1:end-4)))
writematrix(mp_runs.bin_tau.time, sprintf('rams_ml_dataset/%s_time.txt',mconfig(1:end-4)))
