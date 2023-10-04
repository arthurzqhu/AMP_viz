global mconfig islink

% configs of the model

% this is assuming every case has the same set of initial conditions

var1_dir = dir([output_dir,nikki,'/',mconfig,'/*/']);
% really stupid way to only look into the first directory
circuit_breaker=0;
for iitem = 1:size(var1_dir,1)
   if strcmp(var1_dir(iitem).name,'.')
      if circuit_breaker==1
         var1_dir(iitem:end)=[];
         break
      end
      circuit_breaker=1;
   end
end

if contains(mconfig,'2m')
   UorS = 'S-';
elseif contains(mconfig,'4m')
   UorS = 'U-';
else
   UorS = '';
end

var1_dir_flags = [var1_dir.isdir];
var1_dir_flags(1:2) = 0; % ignore the current and parent dir
var1_str_raw = {var1_dir(var1_dir_flags).name};

for ivar1 = 1:length(var1_str_raw)
   var2_dir{ivar1} = dir([var1_dir(find(var1_dir_flags,1,'first')).folder,'/',var1_str_raw{ivar1},'/']);
   var2_dir_flags{ivar1} = [var2_dir{ivar1}.isdir];
   var2_dir_flags{ivar1}(1:2) = 0; % ignore the current and parent dir
   var2_str_raw{ivar1} = {var2_dir{ivar1}(var2_dir_flags{ivar1}).name};
end

% sort var1 and var2 from low to high
var1_val_unsorted = extractAfter(var1_str_raw,lettersPattern);
[var1_val,var1_idx] = sort(var1_val_unsorted);
var1_str=var1_str_raw(var1_idx);

var2_str = {};
for ivar1 = 1:length(var1_str_raw)
   var2_val_unsorted{ivar1} = cellfun(@str2num,extractAfter(var2_str_raw{ivar1},lettersPattern));
   [~,var2_idx] = sort(var2_val_unsorted{ivar1});
   var2_str_asFuncOfVar1{ivar1}=var2_str_raw{ivar1}(var2_idx);
   if ivar1 > 1
      var2_str_union_unsorted = union(var2_str_raw{ivar1}(var2_idx),var2_str_raw{ivar1-1}(var2_idx));
      var2_val_union_unsorted = cellfun(@str2num,extractAfter(var2_str_union_unsorted,lettersPattern));
      [~, var2_union_idx] = sort(var2_val_union_unsorted);
      % var2_str = var2_str_union_unsorted(var2_union_idx);
      var2_str = var2_str_union_unsorted;
   end
end

if isempty(var2_str)
   var2_str = var2_str_raw{ivar1};
end

% output dir for the figures
plot_dir=['plots/' nikki '/' mconfig];
if ~exist(['plots/' nikki '/' mconfig],'dir') && ~islink
    mkdir(['plots/' nikki '/' mconfig])
end

% clear var1_str_raw var2_str_raw
