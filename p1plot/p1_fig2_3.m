clear
clear global
close all

run global_var.m

%% fig 2 read files
oneDcase_meta=dir('./cases for plot/1D case');
oneDcasename = [oneDcase_meta.folder, '/', oneDcase_meta.name];
oneDcaseinfo = ncinfo(oneDcasename);

for ivar = 1:length(oneDcaseinfo.Variables)
   var_name{ivar,1} = oneDcaseinfo.Variables(ivar).Name;
   oneD_struct.(var_name{ivar}) = ncread(oneDcasename, var_name{ivar});
end

oneDcase_meta=dir('./cases for plot/1D case condonly');
oneDcasename = [oneDcase_meta.folder, '/', oneDcase_meta.name];
oneDcaseinfo = ncinfo(oneDcasename);

for ivar = 1:length(oneDcaseinfo.Variables)
   var_name{ivar,1} = oneDcaseinfo.Variables(ivar).Name;
   oneD_struct_condonly.(var_name{ivar}) = ncread(oneDcasename, var_name{ivar});
end

oneDcase_meta=dir('./cases for plot/1D case evaponly');
oneDcasename = [oneDcase_meta.folder, '/', oneDcase_meta.name];
oneDcaseinfo = ncinfo(oneDcasename);

for ivar = 1:length(oneDcaseinfo.Variables)
   var_name{ivar,1} = oneDcaseinfo.Variables(ivar).Name;
   oneD_struct_evaponly.(var_name{ivar}) = ncread(oneDcasename, var_name{ivar});
end

%% fig 2 plot
close all
figure('Position',[1797 477 801 284])
tl=tiledlayout(1,3);
nexttile(1,[1,2])
hold on
wmax=max(oneD_struct.w(:));
plot(oneD_struct.time,oneD_struct.w(:,1)/wmax,'LineWidth',2,...
   'DisplayName','Full MP')
wmax=max(oneD_struct_condonly.w(:));
plot(oneD_struct_condonly.time,oneD_struct_condonly.w(:,1)/wmax,...
   'LineWidth',2,'LineStyle',':','DisplayName','Cond.')
wmax=max(abs(oneD_struct_evaponly.w(:)));
plot(oneD_struct_evaponly.time,oneD_struct_evaponly.w(:,1)/wmax,...
   'LineWidth',2,'LineStyle','--','DisplayName','Evap.')
title('(a)')
hold off
legend('show')
set(gca,'FontSize',16)
xlim([0 1800])
xlabel('Time [s]')
ylabel('Vertical velocity [m/s]')
yticks([-1 0 1])
yticklabels({'-w_{max}','0','w_{max}'})

nexttile
yyaxis left
set(gca,'YColor','none')
yyaxis right
hold on
plot(oneD_struct.RH(1,:),oneD_struct.z,'LineWidth',2,...
   'DisplayName','max 100%')
plot(oneD_struct_evaponly.RH(1,:),oneD_struct_evaponly.z,...
   'DisplayName','max 40%','LineWidth',2)
title('(b)')
hold off
legend('show')
set(gca,'FontSize',16)
% xlabel('Specific humidity [g/kg]')
xlabel('RH [%]')
ylabel('Altitude [m]')

exportgraphics(gcf,'plots/p1/fig2.jpg','Resolution',300)
% print(gcf,'plots/p1/fig2','-dpng','-r300')


%% fig 3 read files
twoDcase_meta=dir('./cases for plot/2D case');
twoDcasename = [twoDcase_meta.folder, '/', twoDcase_meta.name];
twoDcaseinfo = ncinfo(twoDcasename);

for ivar = 1:length(twoDcaseinfo.Variables)
  var_name{ivar,1} = twoDcaseinfo.Variables(ivar).Name;
  twoD_struct.(var_name{ivar}) = ncread(twoDcasename, var_name{ivar});
end

%% figure 3 plot
close all
t=twoD_struct.time;
x=twoD_struct.x;
z=twoD_struct.z;
w=twoD_struct.w;
w(w==-999)=nan;

% % fix the discontinuity!!
% w(:,46,:)=0;
% w(:,135,:)=0;

qv=twoD_struct.vapor;
qv(qv==-999)=nan;

figure('position',[1245 587 1060 560])
tl=tiledlayout(4,3);
nexttile(1,[3,2])
nanimagesc(x,z,squeeze(w(90,:,:))')
cbar=colorbar;
% colormap(coolwarm_s)
% caxis([-max(w(:)),max(w(:))])
cbar.Label.String='w [m/s]';
xlabel('x [m]')
ylabel('z [m]')
%ylim([0 3000])
title('(a)')
set(gca,'fontsize',16)

nexttile(3,[4,1])
plot(1e3*squeeze(qv(1,2,:)),z,'linewidth',2)
xlabel('Specific humidity [g/kg]')
ylabel('Altitude [m]')
title('(b)')
set(gca,'fontsize',16)

nexttile(10,[1,2])
plot(t,max(w,[],[2,3]),'linewidth',2)
xlim([0 3600])
xlabel('Time [s]')
ylabel('Max w [m/s]')
title('(c)')
set(gca,'fontsize',16)
exportgraphics(gcf,'plots/p1/fig3.jpg','Resolution',300)
