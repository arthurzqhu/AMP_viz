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
plot(oneD_struct.time,oneD_struct.w(:,1)/wmax,'LineWidth',1,...
   'DisplayName','Full MP')
wmax=max(oneD_struct_condonly.w(:));
plot(oneD_struct_condonly.time,oneD_struct_condonly.w(:,1)/wmax,...
   'LineWidth',3,'LineStyle',':','DisplayName','Cond.')
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
oneD_struct.z = [oneD_struct.z;[6050:50:8000]'];
oneD_struct.RH(1,end+1:end+40) = oneD_struct.RH(1,end);
yyaxis left
set(gca,'YColor','none')
yyaxis right
rectangle('position', [0 600 max(oneD_struct.RH(:)) 600], ...
   'facecolor', [color_order{5} .3], 'linestyle', 'none')
rectangle('position', [0 5500 max(oneD_struct.RH(:)) 7000], ...
   'facecolor', [color_order{6} .3], 'linestyle', 'none')
hold on
plot(oneD_struct.RH(1,:),oneD_struct.z,'LineWidth',2)
title('(b)')
set(gca,'xTick',[0 100])
set(gca,'xticklabels',{'0' 'RH_{max}'})
hold off
set(gca,'FontSize',16)
xlabel('RH [%]')
ylabel('Altitude [m]')
ylim([0 8000])

print('plots/p1/model setup.png','-dpng','-r300')
