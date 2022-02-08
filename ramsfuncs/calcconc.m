function numconc=calcconc(bins,mass)
%Calculate number concentration from bin microphysics output


size_bins = size(bins);
nkr = size_bins(end);
npts = numel(bins)/nkr;

bins = reshape(bins, npts, nkr);
bins(bins<1e-9) = 0.0;

col = log(2)/3;
%diam_bin = (6 * mass / pi) .^(1/3) / 100; %convert cm to m

for i = 1:npts
    numconc(i) = sum(bins(i,:)./mass)*col;
end

numconc = reshape(numconc,size_bins(1:end-1));
