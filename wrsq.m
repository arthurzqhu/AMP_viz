function [MR, RSQ, ER] = wrsq(ya,yb,wgt)
% calculate MRSQ modified rsq (mass weighted, bin as standard)
% MD ratio of mean amp vs mean bin (accuracy of magnitude estimation)
% RSQ regular rsq except mass weighted (accuracy of trend capturing)
% ya = amp values
% yb = bin values
% wgt = weight, usually bin mass.

ya=double(ya);
yb=double(yb);
wgt=double(wgt);

if all(ya==0) || all(yb==0)
   [MRSQ, MR, RSQ, ER]=deal(nan);
   return
end

vidxn=find(~isnan(ya+yb));

%rss_m=sum((ya(vidxn)-yb(vidxn)).^2.*wgt);
%tss_m=sum((yb(vidxn)-wmean(yb(vidxn),wgt)).^2.*wgt);

%MRSQ=1-rss_m/tss_m;

% --------------

MR=mean(ya)/mean(yb);

% --------------

mdl = fitlm(ya,yb);
RSQ=mdl.Rsquared.Ordinary;

% --------------
ER = ya(vidxn(end))/yb(vidxn(end));

end
