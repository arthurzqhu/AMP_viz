global mconfig

% configs of the model

% this is assuming every case has the same set of initial conditions
aer_dir = dir([output_dir,nikki,'/',mconfig,'/',upper(ampORbin{1}),'_',...
    upper(bintype{1}),'/']);
aer_dir_flags = [aer_dir.isdir];
aer_dir_flags(1:2) = 0; % ignore the current and parent dir
aero_N_str = {aer_dir(aer_dir_flags).name};

w_dir = dir([output_dir,nikki,'/',mconfig,'/',upper(ampORbin{1}),'_',...
    upper(bintype{1}),'/',aero_N_str{1},'/']);
w_dir_flags = [w_dir.isdir];
w_dir_flags(1:2) = 0; % ignore the current and parent dir
w_spd_str = {w_dir(w_dir_flags).name};



% output dir for the figures
plot_dir=['plots/' nikki '/' mconfig ' '];
if ~exist(['plots/' nikki '/'],'dir')
    mkdir(['plots/' nikki '/'])
end
