function RR = wrsq(ya,yb,wgt)

vidx=~isnan(ya+yb);

rss=sum((ya(vidx)-yb(vidx)).^2.*wgt);
tss=sum((yb(vidx)-wmean(yb(vidx),wgt)).^2.*wgt);

RR=1-rss/tss;

end