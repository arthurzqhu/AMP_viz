function bc = get_bimocoeff(dsd_mass,binmean)
% bc = get_bimocoeff(dsd_mass,binmean)
% use 5/9 as a cutoff. bimodal (multimodal) if bc > 5/9, unimodal otherwise.
% 5/9 is the value for an exponential dist. 

dsd_norm = dsd_mass/sum(dsd_mass);

meanD = dsd_norm*binmean';

for i=2:4
   mom(i) = sum((binmean-meanD).^i.*dsd_norm);
end

g = mom(3)/mom(2)^1.5; % skewness
k = mom(4)/mom(2)^2; % kurtosis

bc = (g^2+1)/k;

end
