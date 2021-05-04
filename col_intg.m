function Vpath=col_intg(Vpoint,dz,pressPa,tempK)

rho=pressPa./(tempK*287.058);
Vpath=nansum(Vpoint.*rho.*dz,2);

end