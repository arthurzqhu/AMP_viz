clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
   bintype aero_N_str w_spd_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-09-16';
case_interest = [1]; % 1:length(case_list_num);

run global_var.m
% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

t1=1;
t2=300;
t3=600;
t4=900;

dofig=1;
doanim=0;

%%
for iconf = 1:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   %    mconfig = 'sedonly_c_cr';
   run case_dep_var.m
   %% read files
   %     close all
   
   
   
   for its = 1:length(bintype)
      for ia = 1:length(aero_N_str)
         %             close all
         for iw = 1:length(w_spd_str)
            close all
            
            [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
               loadnc('amp',case_interest);
            [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
               loadnc('bin',case_interest);
            % indices of vars to compare
            vars=1;
            vare=length(indvar_name);
            
            % plot figures
            if dofig
            for ici = case_interest
               %%
               for iab=1:length(ampORbin)
                  if strcmpi(ampORbin{iab},'amp')
                     mphys_struct=amp_struct;
                  elseif strcmpi(ampORbin{iab},'bin')
                     mphys_struct=bin_struct;
                  end
                  time = mphys_struct(ici).time;
                  z = mphys_struct(ici).z;
                  % assuming all vertical layers have the same
                  % thickness
                  dz = z(2)-z(1);
                  
                  N_Tr=mphys_struct(ici).diagM0_rain;
                  RWC=(mphys_struct(ici).diagM3_rain)*pi/6*1000;
                  M6=(mphys_struct(ici).diagM6_rain);
                  Dm=mphys_struct(ici).Dm;
                  
                  figure('Position',[1722 632 859 345])
                  tl=tiledlayout(1,4);
                  nexttile
                  plot(N_Tr(t1,:),z,':','LineWidth',2,'Color','k'); hold on
                  plot(N_Tr(t2,:),z,'--','LineWidth',1,'Color','k')
                  plot(N_Tr(t3,:),z,'LineWidth',1,'Color','k')
                  plot(N_Tr(t4,:),z,'LineWidth',2,'Color','k'); hold off
                  xlabel('rain M_0 [kg^{-3}]')
                  ylabel('z [m]')
                  
                  nexttile
                  plot(RWC(t1,:),z,':','LineWidth',2,'Color','k'); hold on
                  plot(RWC(t2,:),z,'--','LineWidth',1,'Color','k')
                  plot(RWC(t3,:),z,'LineWidth',1,'Color','k')
                  plot(RWC(t4,:),z,'LineWidth',2,'Color','k'); hold off
                  xlabel('M_3 [kg kg^{-3}]')
                  
                  nexttile
                  plot(M6(t1,:),z,':','LineWidth',2,'Color','k'); hold on
                  plot(M6(t2,:),z,'--','LineWidth',1,'Color','k')
                  plot(M6(t3,:),z,'LineWidth',1,'Color','k')
                  plot(M6(t4,:),z,'LineWidth',2,'Color','k'); hold off
                  xlabel('M_6 [m^6 kg^{-3}]')
                  
                  nexttile
                  plot(Dm(t1,:),z,':','LineWidth',2,'Color','k'); hold on
                  plot(Dm(t2,:),z,'--','LineWidth',1,'Color','k')
                  plot(Dm(t3,:),z,'LineWidth',1,'Color','k')
                  plot(Dm(t4,:),z,'LineWidth',2,'Color','k'); hold off
                  xlabel('Dm [m]')
                  
                  title(tl,[ampORbin{iab} '-' bintype{its}],...
                     'fontweight','bold','fontsize',16)
                  saveas(gcf,[plot_dir, 'sedcomp_milbrandt ' bintype{its} '-' ...
                     ampORbin{iab} '.png'])
                  pause(0.5)
               end
            end
            end
            
            % plot animation
            if doanim
            for ici = case_interest
               %%
               
               time = amp_struct(ici).time;
               z = amp_struct(ici).z;
               % assuming all vertical layers have the same
               % thickness
               dz = z(2)-z(1);
               time_step=5;
               
               N_Tr_a=amp_struct(ici).diagM0_rain;
               RWC_a=amp_struct(ici).diagM3_rain*pi/6*1000;
               M6_a=amp_struct(ici).diagM6_rain;
%                Dm_a=amp_struct(ici).Dm;
               Dmr_a=(amp_struct(ici).diagM3_rain./amp_struct(ici).diagM0_rain).^(1/3);
               
               N_Tr_b=bin_struct(ici).diagM0_rain;
               RWC_b=bin_struct(ici).diagM3_rain*pi/6*1000;
               M6_b=bin_struct(ici).diagM6_rain;
%                Dm_b=bin_struct(ici).Dm;
               Dmr_b=(bin_struct(ici).diagM3_rain./bin_struct(ici).diagM0_rain).^(1/3);
               
               time_total=1800;%length(time);
               time_length = floor(time_total/time_step);
               figure('Position',[1722 632 859 345])
               
               for it_idx = 1:time_length+1
                  itime=(it_idx-1)*time_step;
                  if itime>time_total itime=time_total; end
                  if itime<1 itime=1; end
                  
                  tl=tiledlayout(1,4);
                  nexttile
                  hold on
                  plot(N_Tr_a(itime,:),z,'LineWidth',1,'Color',color_order{1})
                  plot(N_Tr_b(itime,:),z,'LineWidth',1,'Color',color_order{2})
                  hold off
                  xlabel('M_0 [kg^{-3}]')
                  ylabel('z [m]')
                  xlim([0 max([N_Tr_a(:);N_Tr_b(:)])])
                  
                  nexttile
                  hold on
                  plot(RWC_a(itime,:),z,'LineWidth',1,'Color',color_order{1})
                  plot(RWC_b(itime,:),z,'LineWidth',1,'Color',color_order{2})
                  hold off
                  xlabel('M_3 [kg kg^{-3}]')
                  xlim([0 max([RWC_a(:);RWC_b(:)])])
                  
                  nexttile
                  hold on
                  plot(M6_a(itime,:),z,'LineWidth',1,'Color',color_order{1})
                  plot(M6_b(itime,:),z,'LineWidth',1,'Color',color_order{2})
                  hold off
                  xlabel('M_6 [m^6 kg^{-3}]')
                  xlim([0 max([M6_a(:);M6_b(:)])])
                  
                  nexttile
                  hold on
                  plot(Dmr_a(itime,:),z,'LineWidth',1,'Color',color_order{1})
                  plot(Dmr_b(itime,:),z,'LineWidth',1,'Color',color_order{2})
                  legend('amp','bin')
                  hold off
                  xlabel('Rain Dm [m]')
                  ylim([0 max(z)])
                  xlim([0 max([Dmr_a(:);Dmr_b(:)])])
                  
                  title(tl,[bintype{its} ', ' sprintf('t = %.0f s', itime)])
                  F(it_idx) = getframe(gcf);
               end
               
               v=VideoWriter(['vids/' mconfig ' sedcomp_milbrandt ' ...
                  bintype{its}],'MPEG-4');
               v.FrameRate=24;
               open(v)
               writeVideo(v,F)
               close(v)
            end
            end
         end
      end
   end
end