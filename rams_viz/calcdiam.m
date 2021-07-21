function diam=calcdiam(bins,mass)
%Calculate mean diameter from bin microphysics output


size_bins = size(bins);
nkr = size_bins(end);
npts = numel(bins)/nkr;

bins = reshape(bins, npts, nkr);
%bins(bins<1e-12) = 0.0;

col = log(2)/3;
diam_bin = (6 * mass / pi) .^(1/3) / 100; %convert cm to m

for i = 1:npts
    diam(i) = sum(diam_bin.*bins(i,:))./sum(bins(i,:));
end

diam = reshape(diam,size_bins(1:end-1));



