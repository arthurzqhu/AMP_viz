function [MR, RSQ, ER, MAXR, MD, SED] = wrsq(ya,yb,wgt)
% calculate MRSQ modified rsq (mass weighted, bin as standard)
% MR ratio of mean amp vs mean bin (accuracy of magnitude estimation)
% RSQ regular rsq except mass weighted (accuracy of trend capturing)
% ER ratio of final amp vs bin
% MAXR ratio of maximum of amp vs bin
% MD difference between maximum of amp vs bin
% SED difference between (ya(end) - ya(1)) and (yb(end) - yb(1))
% ya = amp values
% yb = bin values
% wgt = weight, usually bin mass.

ya = double(ya);
yb = double(yb);
wgt = double(wgt);

% ---------------------------------------------------
vidxn = find(~isnan(ya + yb) & (ya ~= -999) & (yb ~= -999));

if all(ya == 0) || all(yb == 0) || isempty(vidxn)
   [MRSQ, MR, RSQ, ER, MAXR, MD, SED] = deal(nan);
   return
end

% ---------------------------------------------------
MR = mean(ya(vidxn)) / mean(yb(vidxn));
MD = mean(ya(vidxn)) - mean(yb(vidxn));
ER = ya(vidxn(end)) / yb(vidxn(end));
MAXR = max(ya(vidxn)) / max(yb(vidxn));
SED = (ya(vidxn(end)) - ya(vidxn(1))) - (yb(vidxn(end)) - yb(vidxn(1)));

% ---------------------------------------------------
if length(ya) > 1
   mdl = fitlm(ya, yb);
   RSQ = mdl.Rsquared.Ordinary;
else
   RSQ = nan;
end

% ---------------------------------------------------

end
