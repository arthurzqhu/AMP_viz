clear
clear global

global mconfig ivar1 ivar2 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units_set indvar_units ...
   israin iscloud isprof ispath isproc %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2022-01-05';

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

%%
close all
l_anim=1;
l_save=0;
l_fig=0;
l_visible=1;


if l_fig, fig_path=figure('Position',[1722 525 859 452]); end
if ~l_visible, set(fig_path,'Visible','off'), end

for iconf = 1%:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   run case_dep_var.m
   %% read files
   
   
   
   for its = 1:length(bintype)
      for ivar1 = 1:length(var1_str)
         %             close all
         for ivar2 = 1:length(var2_str)
            %                 close all
            
            [~, ~, ~, ~, amp_struct]=...
               loadnc('amp');
            [~, ~, ~, ~, bin_struct]=...
               loadnc('bin');
            
            % indices of vars to compare
            vars=1;
            vare=length(indvar_name);
            
            %%
            % plot
            time=bin_struct.time;
            z=bin_struct.z;
            x=bin_struct.x;
            
            w=bin_struct.w;
            cloudm1=bin_struct.cloud_M1*pi/6*1000;
            rainm1=bin_struct.rain_M1*pi/6*1000;
            
            indvar=rainm1;
            indvar(indvar==-999)=nan;
            if l_fig
               
               for ivar = vars:vare
                  
                  var_comp_raw_amp = amp_struct.(indvar_name{ivar});
                  [var_comp_amp,~,~] = var2phys(var_comp_raw_amp,ivar,1);
                  
                  var_comp_raw_bin = bin_struct.(indvar_name{ivar});
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
                        'DisplayName',['amp ' indvar_ename{ivar}])
                     hold on
                     plot(time,var_comp_bin,'LineWidth',2,...
                        'LineStyle',lsty,'color',color_order{2},...
                        'DisplayName',['bin ' indvar_ename{ivar}])
                     xlim([min(time) max(time)])
                     xlabel('Time [s]')
                     
                     if israin
                        ylabel(['LWP' indvar_units{ivar}])
                     else
                        ylabel([indvar_ename{ivar} indvar_units{ivar}])
                     end
                     
                     if israin || (~israin && ~iscloud)
                        legend('show')
                        set(gca,'fontsize',16)
                        title([mconfig ' ' bintype{its}], ...
                           'fontsize',20,...
                           'FontWeight','bold')
                        
                        vnifn=indvar_ename{ivar};
                        if israin vnifn='liquid water path'; end
                        
                        hold off
                        if l_save
                           saveas(fig_path,[plot_dir,...
                              vnifn, ' ',...
                              'amp vs bin-',bintype{its},' ',...
                              vnum,'.png'])
                        end
                     end
                     
                  end % if path
               end
            end
            %%
            if l_anim
               time_step=1;
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
                  indvar_rs = reshape(indvar(it_runidx,:,:),length(x),[])';
                  nanimagesc(x,z,indvar_rs)
                  colorbar
                  
                  %                      colormap(BrBG20)
                  %                      wbound=max(indvar(:));
                  %                      caxis([-wbound wbound])
                  
                  colormap(Blues)
                  set(gca,'ColorScale','log')
                  caxis([1e-8 1e-2])
                  
                  title(['t=' num2str(itime) 's'])
                  F(it_vididx)=getframe(gcf);
                  
                  it_vididx=it_vididx+1;
                  
               end % for
               
               saveVid(F,['2D yesdown rwc bin_sbm-' vnum], 10)
               %                   saveVid(F,['2D wind bin_sbm-' vnum], 10)
            end % if doanimation
         end
      end
   end
end