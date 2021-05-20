clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
   bintype aero_N_str w_spd_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-05-17';
case_interest = [2]; % 1:length(case_list_num);

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

%%
for iconf = 1:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   %     mconfig = 'adv_coll';
   run case_dep_var.m
   %% read files
   %     close all
   
   
   
   for its = 1:length(bintype)
      for ia = 1:length(aero_N_str)
         %             close all
         for iw = 1:length(w_spd_str)
            %                 close all
            
            [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
               loadnc('amp',case_interest);
            [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
               loadnc('bin',case_interest);
            % indices of vars to compare
            vars=1;
            vare=length(indvar_name);
            
            % plot figures
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
                  
                  N_Tr=mphys_struct(2).diagM0_rain;
                  RWC=mphys_struct(2).diagM3_rain*pi/6*1000;
                  M6=mphys_struct(2).diagM6_rain;
                  Dm=mphys_struct(2).Dm;
                  
                  figure('Position',[1722 632 859 345])
                  tl=tiledlayout(1,4);
                  nexttile
                  plot(N_Tr(1,:),z,':','LineWidth',2,'Color','k'); hold on
                  plot(N_Tr(300,:),z,'--','LineWidth',1,'Color','k')
                  plot(N_Tr(600,:),z,'LineWidth',1,'Color','k')
                  plot(N_Tr(900,:),z,'LineWidth',2,'Color','k'); hold off
                  xlabel('M_0 [kg^{-3}]')
                  ylabel('z [m]')
                  
                  nexttile
                  plot(RWC(1,:),z,':','LineWidth',2,'Color','k'); hold on
                  plot(RWC(300,:),z,'--','LineWidth',1,'Color','k')
                  plot(RWC(600,:),z,'LineWidth',1,'Color','k')
                  plot(RWC(900,:),z,'LineWidth',2,'Color','k'); hold off
                  xlabel('M_3 [kg kg^{-3}]')
                  
                  nexttile
                  plot(M6(1,:),z,':','LineWidth',2,'Color','k'); hold on
                  plot(M6(300,:),z,'--','LineWidth',1,'Color','k')
                  plot(M6(600,:),z,'LineWidth',1,'Color','k')
                  plot(M6(900,:),z,'LineWidth',2,'Color','k'); hold off
                  xlabel('M_6 [m^6 kg^{-3}]')
                  
                  nexttile
                  plot(Dm(1,:),z,':','LineWidth',2,'Color','k'); hold on
                  plot(Dm(300,:),z,'--','LineWidth',1,'Color','k')
                  plot(Dm(600,:),z,'LineWidth',1,'Color','k')
                  plot(Dm(900,:),z,'LineWidth',2,'Color','k'); hold off
                  xlabel('Dm [m]')
                  
                  title(tl,[ampORbin{iab} '-' bintype{its}],...
                     'fontweight','bold','fontsize',16)
                  saveas(gcf,[plot_dir, 'sedcomp_milbrandt ' bintype{its} '-' ...
                     ampORbin{iab} '.png'])
               end
            end
            
%             % plot animation
%             for ici = case_interest
%                %%
%                for iab=1:length(ampORbin)
%                   if strcmpi(ampORbin{iab},'amp')
%                      mphys_struct=amp_struct;
%                   elseif strcmpi(ampORbin{iab},'bin')
%                      mphys_struct=bin_struct;
%                   end
%                   
%                   time = mphys_struct(ici).time;
%                   z = mphys_struct(ici).z;
%                   % assuming all vertical layers have the same
%                   % thickness
%                   dz = z(2)-z(1);
%                   time_step=1;
%                   
%                   N_Tr=mphys_struct(2).diagM0_rain;
%                   RWC=mphys_struct(2).diagM3_rain*pi/6*1000;
%                   M6=mphys_struct(2).diagM6_rain;
%                   Dm=mphys_struct(2).Dm;
%                   
%                   time_total=length(time);
%                   time_length = floor(time_total/time_step);
%                   figure('Position',[1722 632 859 345])
%                   
%                   for it_idx = 1:time_length
%                      itime=(it_idx-1)*time_step+1;
%                      if itime>time_total itime=time_total; end
%                      
%                      tl=tiledlayout(1,4);
%                      nexttile
%                      plot(N_Tr(itime,:),z,'LineWidth',1,'Color','k')
%                      xlabel('M_0 [kg^{-3}]')
%                      ylabel('z [m]')
%                      
%                      nexttile
%                      plot(RWC(itime,:),z,'LineWidth',1,'Color','k')
%                      xlabel('M_3 [kg kg^{-3}]')
%                      
%                      nexttile
%                      plot(M6(itime,:),z,'LineWidth',1,'Color','k')
%                      xlabel('M_6 [m^6 kg^{-3}]')
%                      
%                      nexttile
%                      plot(Dm(itime,:),z,'LineWidth',1,'Color','k')
%                      xlabel('Dm [m]')
%                      
%                      title(tl,sprintf('t = %.0f s', itime))
%                      F(it_idx) = getframe(gcf);
%                   end
%                   
%                   v = VideoWriter(['vids/sedcomp_milbrandt ' bintype{its} '-' ...
%                      ampORbin{iab} '.png'],'MPEG-4');
%                   v.FrameRate=24;
%                   open(v)
%                   writeVideo(v,F)
%                   close(v)
%                end
%             end
         end
      end
   end
end