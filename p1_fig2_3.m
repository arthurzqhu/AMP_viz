clear
clear global
close all

run global_var.m

%% fig 2 read files
oneDcase_meta=dir('./cases for plot/1D case.nc');
oneDcasename = [oneDcase_meta.folder, '/', oneDcase_meta.name];
oneDcaseinfo = ncinfo(oneDcasename);

for ivar = 1:length(oneDcaseinfo.Variables)
   var_name{ivar,1} = oneDcaseinfo.Variables(ivar).Name;
   oneD_struct.(var_name{ivar}) = ncread(oneDcasename, var_name{ivar});
end

%% fig 2 plot
tl=tiledlayout(1,4);
nexttile(1,[1,3])
plot(oneD_struct.time,oneD_struct.w(:,1),'LineWidth',2)
set(gca,'FontSize',16)
xlim([0 3600])
xlabel('Time [s]')
ylabel('Vertical velocity [m/s]')

nexttile
yyaxis left
set(gca,'YColor','none')
yyaxis right
plot(oneD_struct.vapour(1,:)*1e3,oneD_struct.z,'LineWidth',2)
set(gca,'FontSize',16)
xlabel('Specific humidity [g/kg]')
ylabel('Altitude [m]')

exportgraphics(gcf,'../paper in progress/p1/plots/fig2.jpg','Resolution',300)


%% fig 3 read files
twoDcase_meta=dir('./cases for plot/2D case.nc');
twoDcasename = [twoDcase_meta.folder, '/', twoDcase_meta.name];
twoDcaseinfo = ncinfo(twoDcasename);

for ivar = 1:length(twoDcaseinfo.Variables)
   var_name{ivar,1} = twoDcaseinfo.Variables(ivar).Name;
   twoD_struct.(var_name{ivar}) = ncread(twoDcasename, var_name{ivar});
end

%% figure 3 plot

t=twoD_struct.time;
x=twoD_struct.x;
z=twoD_struct.z;
w=twoD_struct.w;
w(w==-999)=nan;

% fix the discontinuity!!
w(:,46,:)=0;
w(:,135,:)=0;

qv=twoD_struct.vapor;
qv(qv==-999)=nan;

tl=tiledlayout(4,2);
nexttile(1,[3,1])
nanimagesc(x,z,squeeze(w(90,:,:))')
cbar=colorbar;
colormap(coolwarm_s)
caxis([-max(w(:)),max(w(:))])
cbar.Label.String='w [m/s]';
xlabel('x [m]')
ylabel('z [m]')
set(gca,'fontsize',16)

nexttile(2,[4,1])
plot(1e3*squeeze(qv(1,2,:)),z)
xlabel('Specific humidity [g/kg]')
ylabel('Altitude [m]')
set(gca,'fontsize',16)

nexttile
plot(t,max(w,[],[2,3]))
xlim([0 3600])
xlabel('Time [s]')
ylabel('Max w [m/s]')
set(gca,'fontsize',16)
exportgraphics(gcf,'../paper in progress/p1/plots/fig3.jpg','Resolution',300)