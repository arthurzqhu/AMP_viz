global mconfig

% configs of the model

% this is assuming every case has the same set of initial conditions

aer_dir = dir([output_dir,nikki,'/',mconfig,'/*/']);
% really stupid way to only look into the first directory
circuit_breaker=0;
for iitem = 1:size(aer_dir,1)
   if strcmp(aer_dir(iitem).name,'.')
      if circuit_breaker==1
         aer_dir(iitem:end)=[];
         break
      end
      circuit_breaker=1;
   end
end
aer_dir_flags = [aer_dir.isdir];
aer_dir_flags(1:2) = 0; % ignore the current and parent dir
aero_N_str_raw = {aer_dir(aer_dir_flags).name};

w_dir = dir([aer_dir(find(aer_dir_flags,1,'first')).folder,'/',aero_N_str_raw{1},'/']);
w_dir_flags = [w_dir.isdir];
w_dir_flags(1:2) = 0; % ignore the current and parent dir
w_spd_str_raw = {w_dir(w_dir_flags).name};


% sort aerosol and wind speed from low to high
aero_N_val_unsorted = cellfun(@str2num,extractAfter(aero_N_str_raw,'a'));
[aero_N_val,aero_idx] = sort(aero_N_val_unsorted);
aero_N_str=aero_N_str_raw(aero_idx);

w_spd_val_unsorted = cellfun(@str2num,extractAfter(w_spd_str_raw,'w'));
[w_spd_val,w_spd_idx] = sort(w_spd_val_unsorted);
w_spd_str=w_spd_str_raw(w_spd_idx);

% output dir for the figures
plot_dir=['plots/' nikki '/' mconfig ' '];
if ~exist(['plots/' nikki '/'],'dir')
    mkdir(['plots/' nikki '/'])
end

clear aero_N_str_raw w_spd_str_raw