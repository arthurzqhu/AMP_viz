clear
clear global

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
   bintype aero_N_str w_spd_str indvar2D_name indvar2D_units indvar2D_ename ...
   israin iscloud isprof ispath isproc %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-06-16';
case_interest = [7]; % 1:length(case_list_num);
doanimation=0;
run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

%%
close all
l_save=1;
l_visible=1;
fig_path=figure('Position',[1722 525 859 452]);

if ~l_visible
   set(fig_path,'Visible','off')
end

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
            
            mp_in='amp';
            [~, ~, ~, amp_var_name, amp_struct]=loadnc(mp_in,case_interest);
            mp_in='bin';
            [~, ~, ~, bin_var_name, bin_struct]=loadnc(mp_in,case_interest);
           
            
            % indices of vars to compare
            vars=1;
            vare=length(indvar2D_name);
            
            %%
            % plot
            for ici = case_interest
               time=bin_struct(ici).time;
               z=bin_struct(ici).z;
               x=bin_struct(ici).x;
               
               w=bin_struct(ici).w;
               cloudm1=bin_struct(ici).cloud_M1*pi/6*1000;
               rainm1=bin_struct(ici).rain_M1*pi/6*1000;
               
               indvar2D=rainm1;
               indvar2D(indvar2D==-999)=nan;
               
               
               for ivar = vars:vare
                  
                  var_comp_raw_amp = amp_struct(ici).(indvar2D_name{ivar});
                  [var_comp_amp,~,~] = var2phys(var_comp_raw_amp,ivar,1);
                  
                  var_comp_raw_bin = bin_struct(ici).(indvar2D_name{ivar});
                  [var_comp_bin,linORlog,range] = var2phys(var_comp_raw_bin,ivar,1);
                  
                  % change linestyle according to cloud/rain
                  if israin
                     lsty=':';
                  else
                     lsty='-';
                  end
                  
                  if ispath
                     set(0,'CurrentFigure',fig_path)

                     
                     plot(time,var_comp_amp,'LineWidth',2,...
                           'LineStyle',lsty,'color',color_order{1},...
                           'DisplayName',['amp ' indvar2D_ename{ivar}])
                     hold on
                     plot(time,var_comp_bin,'LineWidth',2,...
                           'LineStyle',lsty,'color',color_order{2},...
                           'DisplayName',['bin ' indvar2D_ename{ivar}])
                     xlim([min(time) max(time)])
                     xlabel('Time [s]')

                     if israin
                        ylabel(['LWP' indvar2D_units{ivar}])
                     else
                        ylabel([indvar2D_ename{ivar} indvar2D_units{ivar}])
                     end
                     
                     if israin || (~israin && ~iscloud)
                        legend('show')
                        set(gca,'fontsize',16)
                        title([mconfig ' ' bintype{its}], ...
                           'fontsize',20,...
                           'FontWeight','bold')
                        
                        vnifn=indvar2D_ename{ivar};
                        if israin vnifn='liquid water path'; end
                        
                        hold off
                        if l_save
                           saveas(fig_path,[plot_dir,...
                              vnifn, ' ',...
                              'amp vs bin-',bintype{its},' ',...
                              case_list_str{ici},'-',vnum,'.png'])
                        end
                     end
                     
                  end % if path
                  
               end
               %%
               if doanimation
                  time_step=2;
                  time_length = floor(length(time)/time_step);
                  for it_vididx = 1:time_length+1 %#ok<*UNRCH>
                     % it_vididx = time index in the video
                     % it_runidx = time index in the run
                     % itime = physical time passed since the beginning of the run

                     it_runidx = (it_vididx-1)*time_step;
                     if it_runidx>length(time) it_runidx=length(time); end
                     if it_runidx<1 it_runidx=1; end

                     itime = time(it_runidx);

                     % reshaped cloud m1
                     indvar_rs = reshape(indvar2D(it_runidx,:,:),length(x),[])';
                     nanimagesc(x,z,indvar_rs)
                     colorbar
                     
%                      colormap(BrBG20)
%                      wbound=max(indvar2D(:));
%                      caxis([-wbound wbound])
                     
                     colormap(Blues)
                     set(gca,'ColorScale','log')
                     caxis([1e-8 1e-2])
                     
                     title(['t=' num2str(itime) 's'])
                     F(it_vididx)=getframe(gcf);

                     it_vididx=it_vididx+1;

                  end

                  v = VideoWriter(['vids/2D rwc bin_sbm-' vnum],'MPEG-4');
                  v.FrameRate=10;
                  open(v)
                  writeVideo(v,F)
                  close(v)
               end % for
            end % if animation
         end
      end
   end
end