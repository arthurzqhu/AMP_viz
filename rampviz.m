clearvars -except cmaps
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iwrap l_da var1_str
close all

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;
mp_plot = [1:3];

nikki = 'MASE14_3069'
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);

% wrappers = {'amp'}; %temporary
% wrappers = {'bin'}; %temporary
% bintype = {'tau'};
% bintype = {'sbm'};

% index of variables to be plotted
% corresponding variables can be found in rglobal_var.m
if doplot
   var_int_idx = [18]
   % var_int_idx = [4:6 10 11 24 25 36 53:54 63 65];
end

if doanim
   % var_int_idx = [6];
   var_int_idx = [15];
end

% whether we want the domain averaged quantity
% can be set to an array but needs to have the same length as var_int_idx


for iconf = 1:2 %length(mconfig_ls)
mconfig = mconfig_ls{iconf};
rcase_dep_var
disp(mconfig)

mp_runs = struct;
% mp_runs(length(var1_str_list)) = struct;

% load RAMS output
ivar1=iconf;
% for ivar1 = 1%:length(var1_str_list)
var1_str = var1_str_list{ivar1};
for its = 2:length(bintype)
   for iwrap = mp_plot%:length(wrappers)
      disp([wrappers{iwrap} '-' bintype{its}])
      % disp([ivar1 its iwrap])
      if doanim
         l_da(1:length(var_int_idx)) = 0; 
         % set the view of LWC to a vertical cross section
         % l_da(contains({var_name_set{var_int_idx}},{'LW','SW'})) =2;
         % l_da(contains({var_name_set{var_int_idx}},{'LWC','CWC','RWC'})) =1;

      else
         l_da(1:length(var_int_idx)) = 1;
         % l_da(contains({var_name_set{var_int_idx}},{'LW','SW'})) =2;
         l_da(contains({var_name_set{var_int_idx}},{'prof','flux_'})) = 0;
      end
      % l_da = repelem(l_da,length(var_int_idx));
      % set DSD to domain averaged value
      l_da(contains({var_name_set{var_int_idx}},'DSD')) =1;

      % skip bin if the var is AMP-specific
      if any(contains([var_req_set{var_int_idx}],'GUESS')) && iwrap==3
         continue
      end

      % get var_interest as an object
      var_interest = get_varint(var_int_idx);
      mps = [wrappers{iwrap} '_' bintype{its}]; % mps = microphysics scheme
      mp_runs.(mps) = loadrams(wrappers{iwrap});
      % make sure that z is never negative
      dz = z(2) - z(1);
      % dz = z(2:end)-z(1:end-1);
      % dz(length(z))=dz(end)*1.1;
      z = z+dz;
   end % iwrap
end % its
% end

% % align the t_0
% mps = [wrappers{mp_plot(1)} '_' bintype{its}];
% t_0 = mp_runs.(mps).time(1);

%%

% {{{ figs:

if doplot
daname_interest = {var_interest.da_name};
daename_interest = {var_interest.da_ename};
varname_interest = {var_interest.var_name};
varename_interest = {var_interest.var_ename};
varunit_interest = {var_interest.units};

for ivar1 = 1:length(var1_str_list)
% var1_str = var1_str_list{ivar1};
% var1_val = var1_val_arr(ivar1);

for ivar = 1:length(daname_interest)
   figure('position',[0 0 800 400])
   tl = tiledlayout('flow');
   if l_da(ivar) == 0
      varn = varname_interest{ivar};
   else
      varn= daname_interest{ivar};
   end
   pRange = var_interest(ivar).range;
   linORlog = var_interest(ivar).linORlog;
   for its = 2:length(bintype)
      for iwrap = mp_plot%:length(wrappers)

         % skip bin if the var is AMP-specific
         if any(contains([var_req_set{var_int_idx}],'GUESS')) && iwrap==3
            continue
         end

         mps = [wrappers{iwrap} '_' bintype{its}];
         ubound = max(abs(mp_runs.(mps).(varn)(:)));
         % it_0_align = findInSorted(mp_runs.(mps).time,t_0);
         % if min(mp_runs(ivar1).(mps).(varn)(:)) < 0
         %    lbound = -ubound;
         % else
         %    lbound = min(mp_runs(ivar1).(mps).(varn), [], 'all');
         % end
         % pRange = [lbound ubound];
         if size(mp_runs.(mps).(varn), 2) == 1
            % domain averaged path
            if its*iwrap == 1
               nexttile
            end
            if l_da(ivar)==4
               plot(mp_runs.(mps).(varn),z,...
                  'LineWidth',2,...
                  'displayname',mps,...
                  'LineStyle', wrap_lsty{iwrap},...
                  'Color',color_order{its},...
                  'LineWidth',wrap_lwid(iwrap))
               set(gca,'XScale',linORlog)
               if ~isempty(pRange)
                  xlim(pRange)
               end
            else
               plot(mp_runs.(mps).time,mp_runs.(mps).(varn),...
                  'LineWidth',2,...
                  'displayname',mps,...
                  'LineStyle', wrap_lsty{iwrap},...
                  'Color',color_order{its},...
                  'LineWidth',wrap_lwid(iwrap))
               set(gca,'YScale',linORlog)
               if ~isempty(pRange)
                  ylim(pRange)
               end
            end
            hold on
         elseif size(mp_runs.(mps).(varn),1) == length(z)
            % domain averaged profile
            nexttile
            nanimagesc(mp_runs.(mps).time, z(1:60), mp_runs.(mps).(varn)(1:60,:))
            % yline(1175)
            cbar = colorbar;
            cbar.Label.String = [daename_interest{ivar} varunit_interest{ivar}];
            % ylim([0 1100])
            if contains(varn,{'w_da','SS_da','wp_','WUP','WDN','W_net','RH'})
               colormap(cmaps.coolwarm_rs)
            elseif contains(varn,{'emissivity','fthrd','cec','cer','cel','lh_'})
               colormap(cmaps.coolwarm_r20)
            elseif contains(varn, 'flag')
               colormap(cmaps.coolwarm_s)
            elseif contains(varn, 'meand')
               colormap(cmaps.Blues_s)
            else
               colormap(cmaps.Blues)
            end
            datetick('keeplimits')
            if ~isempty(pRange)
               caxis(pRange)
            end
            set(gca,'ColorScale',linORlog)
            title(mps,'Interpreter','none')
            set(gca,'fontsize',16)
         elseif size(mp_runs.(mps).(varn),1) == size(runs.GLAT,1)
            nexttile
            nanimagesc(runs.GLON(:,1),runs.GLAT(1,:),mp_runs.(mps).(varn)(1:60,:))
            cbar = colorbar;
            cbar.Label.String = [daename_interest{ivar} varunit_interest{ivar}];
            colormap(cmaps.coolwarm_r)
            if ~isempty(pRange)
               caxis(pRange)
            end
            set(gca,'ColorScale',linORlog)
            title(mps,'Interpreter','none')
            set(gca,'fontsize',16)
         else
            error("Haven't written the visualization for 3D variables input. Check the var_int_idx.")
         end
      end % iwrap
   end % its

   if size(mp_runs.(mps).(varn), 2) == 1
      set(gca,'fontsize',16)
      % ylim(pRange)
      if l_da(ivar)~=4
         datetick('keeplimits')
         xtickangle(45)
         ylabel([daename_interest{ivar} varunit_interest{ivar}])
      else
         xlabel([daename_interest{ivar} varunit_interest{ivar}])
         ylabel('Altitude [m]')
      end
      % legend('show','Interpreter','none','location','best')
      hold off
   elseif length(size(mp_runs.(mps).(varn))) < 3
      title(tl, mconfig, 'fontsize', 20, 'fontweight', 'bold')
      ylabel(tl, 'Altitude [m]', 'fontsize', 20, 'fontweight', 'bold')
   end

   print(sprintf('plots/rams/%s/%s_%s_%s.png',nikki,varn,mps,mconfig),'-dpng','-r300')
end % ivar
end % ivar1

end % doplot
% }}}

%%

if doanim
set(0, 'DefaultFigurePosition', [0 0 800 600])
varname_interest = {var_interest.var_name};
varename_interest = {var_interest.var_ename};
varunit_interest = {var_interest.units};
varscale_interest = {var_interest.linORlog};
for ivar = 1:length(varname_interest)
   varn = varname_interest{ivar};
   linORlog = varscale_interest{ivar};
   pRange = var_interest(ivar).range;
   for its = 2:length(bintype)
      mps_amp = ['amp_' bintype{its}];
      mps_bin = ['bin_' bintype{its}];

      if its==2
         binmean = load('diamg_sbm.txt')*1e6;
      elseif its==1
         binmean = load('diamg_tau.txt')*1e6;
      end

      for iwrap = mp_plot%:length(wrappers)
         mps = [wrappers{iwrap} '_' bintype{its}]; % mps = microphysics scheme

         if any(contains([var_req_set{var_int_idx}],'GUESS')) && iwrap==3
            continue
         end

         if contains(varn,'DSD')
            DSD_rightord = permute(mp_runs.(mps).DSDm_da(2:end-1, :, :), [3, 1, 2]);
         else
            if length(size(mp_runs.(mps).(varn))) == 4
               var_xy = squeeze(nanmean(mp_runs.(mps).(varn),3));
               var_xz = squeeze(nanmean(mp_runs.(mps).(varn),2));
               var_yz = squeeze(nanmean(mp_runs.(mps).(varn),1));
            elseif length(size(mp_runs.(mps).(varn))) == 3
               var_xy = mp_runs.(mps).(varn);
               var_xz = [];
               var_yz = [];
            end
         end

         totalsteps = ceil(length(mp_runs.(mps).time));
         F(totalsteps) = struct('cdata',[],'colormap',[]);

         for it = 1:totalsteps
            disp(it)
            itime = it;
            if contains(varn,'DSD')

               xlabel('Diameter [\mum]')
               nanimagesc(binmean, z, DSD_rightord(:,:,it)')
               colorbar
               colormap(cmaps.Blues_s)
               caxis([1e-8 1e-2])
               set(gca,'XScale','log')
               set(gca,'ColorScale','log')
               ylabel('Altitude [m]')
               xlim([binmean(1) binmean(end)])
               viewpoint = '';

            else

               % % top down view
               % nanimagesc(runs.GLON(:,1),runs.GLAT(1,:), var_xy(:,:,it))
               % colorbar
               % if contains(varname_interest{ivar}, 'flag')
               %    colormap(cmaps.coolwarm_s)
               % else
               %    colormap(cmaps.Blues_s)
               % end
               % if isempty(pRange)
               %    caxis([min(var_xy(:)) max(var_xy(:))])
               % else
               %    caxis(pRange)
               % end
               % set(gca,'ColorScale',linORlog)
               % xlabel('long')
               % ylabel('lat')
               % viewpoint = ' td';

               % side view
               nanimagesc(runs.GLON(:,1),z,var_yz(:,:,itime)')
               colormap(cmaps.Blues_s)
               colorbar
               if isempty(pRange)
                  caxis([min(var_yz(:)) max(var_yz(:))])
               else
                  caxis(pRange)
               end
               viewpoint = ' side';
               set(gca,'ColorScale',linORlog)

            end

            title(['time = ' mp_runs.(mps).time_str{itime}])

            cdata{it} = print('-RGBImage','-r300');
            F(it) = im2frame(cdata{it});
         end
         saveVid(F,sprintf('rams/%s/%s_%s_%s_%s%s',nikki,varn,mconfig,mps,var1_str,viewpoint),5)
      end
   end % its
end % ivar

end % if doanim
% end % ivar1
end % iconf
