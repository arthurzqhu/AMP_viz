function idx=find_cutoff(dsd)

% Use Otsu's method to find the cloud-rain threshold by maximizing inter-class variance

dsd_norm=dsd/sum(dsd);
nbins=length(dsd_norm);

q=cumsum(dsd_norm);
m=cumsum((1:nbins).*dsd_norm);

m_g=m(end);

sigma_B=(m_g*q-m).^2./(q.*(1-q));
[~,idx] = max(sigma_B);

end
