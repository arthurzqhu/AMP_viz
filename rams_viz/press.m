function p=press(pi)
%Calculate pressure from the exner function output by RAMS (PI)

p0=1000;
cp=1004;
R=287;

p=p0*(pi/cp).^(cp/R);
