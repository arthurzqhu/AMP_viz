clear
close all

%generating sound_in file for rams input
load('/Users/arthurhu/MEGAsync/grad/research/aerosol_reldisp/datasets/vocals/081019_Ps.mat')

%%
% plot(s_mr+s_lwc_pdi,s_ap,'.')

z=25:25:2200;
dz=z(2)-z(1);
PS=z';
for iz=1:length(z)
   
   zi=z(iz);
   vidx=s_ap>=zi-dz/2 & s_ap<zi+dz/2;
   
   if iz==1
      PS(1)=nanmean(s_ps(vidx));
   end
   
   TS(iz,1)=nanmean(s_ta(vidx))+273.15;
   RTS(iz,1)=nanmean(s_mr(vidx))+nanmean(s_lwc_pdi(vidx));
   US(iz,1)=nanmean(s_wx(vidx));
   VS(iz,1)=nanmean(s_wy(vidx));
   QL(iz,1)=nanmean(s_lwc_pdi(vidx));
end

output_tab=[PS, TS, RTS, US, VS];
% writematrix(output_tab,'SOUND_IN')