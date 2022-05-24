clear
clear global
close all

global mconfig ivar1 ivar2 its nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2022-05-24';

global_var
% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir, nikki);

t1=1;
t2=300;
t3=600;
t4=900;

dofig=1;
doanim=0;

%%
for iconf = 1:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   case_dep_var
   %% read files
   
   
   
   figure('Position',[1722 632 859 600])
   tl = tiledlayout(2,4);
   for its = 1:length(bintype)
      its
      for ivar1 = length(var1_str)
         for ivar2 = 2%:length(var2_str)
            amp_struct = loadnc('amp');
            bin_struct = loadnc('bin');

            % indices of vars to compare
            vars=1;
            vare=length(indvar_name);
            
            % plot figures
            if dofig
            %%

               time = amp_struct.time;
               z = amp_struct.z;
               dz = z(2)-z(1);
               N_Tr_a=amp_struct.diagM0_rain;
               RWC_a=(amp_struct.diagM3_rain)*pi/6*1000;
               M6_a=(amp_struct.diagM6_rain);
               Dm_a=amp_struct.Dm_w*1e3;

               N_Tr_b=bin_struct.diagM0_rain;
               RWC_b=(bin_struct.diagM3_rain)*pi/6*1000;
               M6_b=(bin_struct.diagM6_rain);
               Dm_b=bin_struct.Dm_w*1e3;

               nexttile
               plot(N_Tr_a(t1,:),z,':','LineWidth',2,'Color',color_order{5-its}); hold on
               plot(N_Tr_a(t2,:),z,'--','LineWidth',1,'Color',color_order{5-its})
               plot(N_Tr_a(t3,:),z,'LineWidth',1,'Color',color_order{5-its})
               plot(N_Tr_a(t4,:),z,'LineWidth',2,'Color',color_order{5-its}) 
               plot(N_Tr_b(t1,:),z,':','LineWidth',2,'Color',color_order{its})
               plot(N_Tr_b(t2,:),z,'--','LineWidth',1,'Color',color_order{its})
               plot(N_Tr_b(t3,:),z,'LineWidth',1,'Color',color_order{its})
               plot(N_Tr_b(t4,:),z,'LineWidth',2,'Color',color_order{its}); hold off
               title(['(' char(96+(its-1)*4+1) ')'])
               xlabel('rain number [kg^{-3}]')
               ylabel('z [m]')

               nexttile
               plot(RWC_a(t1,:)*1e3,z,':','LineWidth',2,'Color',color_order{5-its}); hold on
               plot(RWC_a(t2,:)*1e3,z,'--','LineWidth',1,'Color',color_order{5-its})
               plot(RWC_a(t3,:)*1e3,z,'LineWidth',1,'Color',color_order{5-its})
               plot(RWC_a(t4,:)*1e3,z,'LineWidth',2,'Color',color_order{5-its})
               plot(RWC_b(t1,:)*1e3,z,':','LineWidth',2,'Color',color_order{its})
               plot(RWC_b(t2,:)*1e3,z,'--','LineWidth',1,'Color',color_order{its})
               plot(RWC_b(t3,:)*1e3,z,'LineWidth',1,'Color',color_order{its})
               plot(RWC_b(t4,:)*1e3,z,'LineWidth',2,'Color',color_order{its}); hold off
               title(['(' char(96+(its-1)*4+2) ')'])
               xlabel('RWP [g kg^{-3}]')

               nexttile
               plot(M6_a(t1,:),z,':','LineWidth',2,'Color',color_order{5-its}); hold on
               plot(M6_a(t2,:),z,'--','LineWidth',1,'Color',color_order{5-its})
               plot(M6_a(t3,:),z,'LineWidth',1,'Color',color_order{5-its})
               plot(M6_a(t4,:),z,'LineWidth',2,'Color',color_order{5-its})
               plot(M6_b(t1,:),z,':','LineWidth',2,'Color',color_order{its})
               plot(M6_b(t2,:),z,'--','LineWidth',1,'Color',color_order{its})
               plot(M6_b(t3,:),z,'LineWidth',1,'Color',color_order{its})
               plot(M6_b(t4,:),z,'LineWidth',2,'Color',color_order{its}); hold off
               title(['(' char(96+(its-1)*4+3) ')'])
               xlabel('M_6 [m^6 kg^{-3}]     ')

               nexttile
               plot(Dm_a(t1,:),z,':','LineWidth',2,'Color',color_order{5-its}); hold on
               plot(Dm_a(t2,:),z,'--','LineWidth',1,'Color',color_order{5-its})
               plot(Dm_a(t3,:),z,'LineWidth',1,'Color',color_order{5-its})
               plot(Dm_a(t4,:),z,'LineWidth',2,'Color',color_order{5-its})
               plot(Dm_b(t1,:),z,':','LineWidth',2,'Color',color_order{its})
               plot(Dm_b(t2,:),z,'--','LineWidth',1,'Color',color_order{its})
               plot(Dm_b(t3,:),z,'LineWidth',1,'Color',color_order{its})
               plot(Dm_b(t4,:),z,'LineWidth',2,'Color',color_order{its}); hold off
               title(['(' char(96+(its-1)*4+4) ')'])
               xlabel('D_m [mm]')
               legend('', '', ['AMP-' upper(bintype{its})], '', ...
                      '', '', ['BIN-' upper(bintype{its})], '')

            end
            
            % plot animation
            if doanim
            for ici = case_interest
               %%
               
               time = amp_struct.time;
               z = amp_struct.z;
               % assuming all vertical layers have the same
               % thickness
               dz = z(2)-z(1);
               time_step=5;
               
               N_Tr_a=amp_struct.diagM0_rain;
               RWC_a=amp_struct.diagM3_rain*pi/6*1000;
               M6_a=amp_struct.diagM6_rain;
%                Dm_a=amp_struct.Dm;
               Dmr_a=(amp_struct.diagM3_rain./amp_struct.diagM0_rain).^(1/3);
               
               N_Tr_b=bin_struct.diagM0_rain;
               RWC_b=bin_struct.diagM3_rain*pi/6*1000;
               M6_b=bin_struct.diagM6_rain;
%                Dm_b=bin_struct.Dm;
               Dmr_b=(bin_struct.diagM3_rain./bin_struct.diagM0_rain).^(1/3);
               
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
                  xlabel('rain number [kg^{-3}]')
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

      if its == 1
         title(tl, upper(bintype{its}),'fontweight','bold','fontsize',16)
      end
   end

   annotation('textbox', [.41 .4 .2 .2],'String','SBM','FitBoxToText', 'on',...
      'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
      'fontweight', 'bold', 'fontsize', 16, 'edgecolor', [1 1 1])
   % saveas(gcf,[plot_dir, 'sedcomp_milbrandt.png'])
   exportgraphics(gcf,['plots/p1/sedcomp_' mconfig(end) '.jpg'],'Resolution',300)
end
