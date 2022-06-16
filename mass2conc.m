function DSDConcProf = mass2conc(DSDprof, binmean)
% DSDConcProf = mass2conc(DSDprof, binmean)
% DSDprof in 1/kg/log(r)

DSDConcProf = (DSDprof*log(2)/3/1000./(binmean.^3*pi/6));

end