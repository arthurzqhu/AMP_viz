function dim = getdims(var)

sz = size(var);

dim = numel(sz(sz~=1));

end