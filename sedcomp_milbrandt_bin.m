clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
   bintype aero_N_str w_spd_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-09-08';
case_interest = [1]; % 1:length(case_list_num);

run global_var.m
% bintype = {'sbm'};
% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

t1=1;
t2=300;
t3=600;
t4=900;
%%
for iconf = 1:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   %    mconfig = 'sedonly_c_cr';
   run case_dep_var.m
   %% read files
   
      for ia = 1:length(aero_N_str)
         %             close all
         for iw = 1:length(w_spd_str)
            close all
            
            its=1;
            [~, ~, ~, ~, tau_struct]=...
               loadnc('bin',case_interest);
            
            its=2;
            [~, ~, ~, ~, sbm_struct]=...
               loadnc('bin',case_interest);
            
            % plot figures
            for ici = case_interest
               %%
               time = sbm_struct(ici).time;
               z = sbm_struct(ici).z;

               % assuming all vertical layers have the same
               % thickness
               dz = z(2)-z(1);

               dN_Tr=sbm_struct(ici).diagM0_rain-tau_struct(ici).diagM0_rain;
               dRWC=(sbm_struct(ici).diagM3_rain-tau_struct(ici).diagM3_rain)*pi/6*1000;
               dM6=sbm_struct(ici).diagM6_rain-tau_struct(ici).diagM6_rain;
               dDm=sbm_struct(ici).Dm-tau_struct(ici).Dm;

               figure('Position',[1722 632 859 345])
               tl=tiledlayout(1,4);
               nexttile
               grid
               plot(dN_Tr(t1,:),z,':','LineWidth',2,'Color','k'); hold on
               plot(dN_Tr(t2,:),z,'--','LineWidth',1,'Color','k')
               plot(dN_Tr(t3,:),z,'LineWidth',1,'Color','k')
               plot(dN_Tr(t4,:),z,'LineWidth',2,'Color','k'); hold off
               xlabel('rain M_0 [kg^{-3}]')
               ylabel('z [m]')
               xlim([-500 500])

               nexttile
               grid
               plot(dRWC(t1,:),z,':','LineWidth',2,'Color','k'); hold on
               plot(dRWC(t2,:),z,'--','LineWidth',1,'Color','k')
               plot(dRWC(t3,:),z,'LineWidth',1,'Color','k')
               plot(dRWC(t4,:),z,'LineWidth',2,'Color','k'); hold off
               xlabel('M_3 [kg kg^{-3}]')
               xlim([-1e-4 1e-4])

               nexttile
               grid
               plot(dM6(t1,:),z,':','LineWidth',2,'Color','k'); hold on
               plot(dM6(t2,:),z,'--','LineWidth',1,'Color','k')
               plot(dM6(t3,:),z,'LineWidth',1,'Color','k')
               plot(dM6(t4,:),z,'LineWidth',2,'Color','k'); hold off
               xlabel('M_6 [m^6 kg^{-3}]')
               xlim([-1e-15 1e-15])

               nexttile
               grid
               plot(dDm(t1,:),z,':','LineWidth',2,'Color','k'); hold on
               plot(dDm(t2,:),z,'--','LineWidth',1,'Color','k')
               plot(dDm(t3,:),z,'LineWidth',1,'Color','k')
               plot(dDm(t4,:),z,'LineWidth',2,'Color','k'); hold off
               xlabel('Dm [m]')
               xlim([-3e-4 3e-4])

               title(tl,'SBM-TAU difference',...
                  'fontweight','bold','fontsize',16)
               saveas(gcf,[plot_dir, 'sedcomp_milbrandt bin.png'])
               pause(0.5)
            end
         end
      end
%    end
end