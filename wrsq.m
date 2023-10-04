function [MR, RSQ, MVAL_AMP, MVAL_BIN, ER, MAXR, MD, SERR, MSD_AMP, MSD_BIN, ...
      SVAL_AMP, SVAL_BIN] = wrsq(ya,yb,wgt)
% calculate MRSQ modified rsq (mass weighted, bin as standard)
% MR ratio of mean amp vs mean bin (accuracy of magnitude estimation)
% RSQ regular rsq except mass weighted (accuracy of trend capturing)
% ER ratio of final amp vs bin
% MAXR ratio of maximum of amp vs bin
% MD difference between maximum of amp vs bin
% SERR difference between (ya(end) - ya(1)) and (yb(end) - yb(1))
% SED_AMP ya(end) - ya(1)
% SED_BIN yb(end) - yb(1)
% ya = amp values
% yb = bin values
% wgt = weight, usually bin mass.

ya = double(ya);
yb = double(yb);
wgt = double(wgt);

% ---------------------------------------------------
vidxn = find(~isnan(ya + yb) & (ya ~= -999) & (yb ~= -999) & ~isinf(ya+yb));

if all(ya == 0) || all(yb == 0) || isempty(vidxn)
   [MRSQ, MR, RSQ, ER, MAXR, MD, SERR, MSD_AMP, MSD_BIN, ...
      MVAL_AMP, MVAL_BIN, SVAL_AMP, SVAL_BIN] = deal(nan);
   return
end

% ---------------------------------------------------
MVAL_AMP = nanmean(ya);
MVAL_BIN = nanmean(yb);
MR = MVAL_AMP / MVAL_BIN;
MD = MVAL_AMP - MVAL_BIN;
ER = ya(vidxn(end)) / yb(vidxn(end));
MAXR = max(ya(vidxn)) / max(yb(vidxn));
SERR = (ya(vidxn(end)) / ya(vidxn(1))) / (yb(vidxn(end)) / yb(vidxn(1)));
MSD_AMP = mean(ya(vidxn)) - ya(vidxn(1));
MSD_BIN = mean(yb(vidxn)) - yb(vidxn(1));
SVAL_AMP = ya(vidxn(1));
SVAL_BIN = yb(vidxn(1));

% ---------------------------------------------------

% if length(ya) > 1
%    mdl = fitlm(ya, yb, 'intercept', false);
%    RSQ = mdl.Rsquared.Ordinary;
% else
%    RSQ = nan;
% end

RSQ = 1-nansum((ya-yb).^2)/nansum((yb-nanmean(yb)).^2);

% ---------------------------------------------------

end
