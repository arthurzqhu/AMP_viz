function density = rho(theta, pi)
% calculate air density from pressure and absolute temperature

R = 287;
pressure = press(pi);
tampk = temp(theta, pi);
density = 100*pressure./(R*tampk);
