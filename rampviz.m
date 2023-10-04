clearvars -except cmaps
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iab l_da var1_str
close all

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;
ab_plot = [1 2];

nikki = 'SCMS045_66';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);

% ampORbin = {'amp'}; %temporary
% ampORbin = {'bin'}; %temporary
% bintype = {'tau'};
% bintype = {'sbm'};

% index of variables to be plotted
% corresponding variables can be found in rglobal_var.m
if doplot
   var_int_idx = [39:42];
end

if doanim
   % var_int_idx = [6];
   var_int_idx = [15];
end

% whether we want the domain averaged quantity
% can be set to an array but needs to have the same length as var_int_idx


for iconf = [1]%length(mconfig_ls)
mconfig = mconfig_ls{iconf};
rcase_dep_var
disp(mconfig)

mp_runs = struct;
% mp_runs(length(var1_str_list)) = struct;

% load RAMS output
for ivar1 = 1%:length(var1_str_list)
var1_str = var1_str_list{ivar1};
for its = 2:length(bintype)
   for iab = ab_plot%:length(ampORbin)
      disp([ampORbin{iab} '-' bintype{its}])
      % disp([ivar1 its iab])
      if doanim
         l_da = 0; 
         % set the view of LWC to a vertical cross section
         l_da(contains({var_name_set{var_int_idx}},{'LWC','LW','SW'})) =2;

      else
         l_da = 1;
         l_da(contains({var_name_set{var_int_idx}},{'LWC','LW','SW'})) =2;
      end
      l_da = repelem(l_da,length(var_int_idx));
      % set DSD to domain averaged value
      l_da(contains({var_name_set{var_int_idx}},'DSD')) =2;

      % skip bin if the var is AMP-specific
      if any(contains([var_req_set{var_int_idx}],'GUESS')) && iab==2
         continue
      end

      % get var_interest as an object
      var_interest = get_varint(var_int_idx);
      mps = [ampORbin{iab} '_' bintype{its}]; % mps = microphysics scheme
      mp_runs.(mps) = loadrams(ampORbin{iab});
      % make sure that z is never negative
      z = z(2:end-1);
   end
end
% end

%%

% {{{ figs:

if doplot
varname_interest = {var_interest.da_name};
varename_interest = {var_interest.da_ename};
varunit_interest = {var_interest.units};

for ivar1 = 1:length(var1_str_list)
% var1_str = var1_str_list{ivar1};
% var1_val = var1_val_arr(ivar1);

for ivar = 1:length(varname_interest)
   figure('position',[0 0 800 400])
   tl = tiledlayout('flow');
   varn = varname_interest{ivar};
   pRange = var_interest(ivar).range;

   linORlog = var_interest(ivar).linORlog;
   for its = 2:length(bintype)
      for iab = ab_plot%:length(ampORbin)

         % skip bin if the var is AMP-specific
         if any(contains([var_req_set{var_int_idx}],'GUESS')) && iab==2
            continue
         end

         mps = [ampORbin{iab} '_' bintype{its}];
         ubound = max(abs(mp_runs.(mps).(varn)(:)));
         % if min(mp_runs(ivar1).(mps).(varn)(:)) < 0
         %    lbound = -ubound;
         % else
         %    lbound = min(mp_runs(ivar1).(mps).(varn), [], 'all');
         % end
         % pRange = [lbound ubound];
         if size(mp_runs.(mps).(varn), 2) == 1
            % domain averaged path
            if its*iab == 1
               nexttile
            end
            plot(mp_runs.(mps).time,mp_runs.(mps).(varn),'LineWidth',2,'displayname',mps,...
               'LineStyle', ampbin_lsty{iab},'Color',color_order{its},'LineWidth',ampbin_lwid(iab))
            hold on
         elseif length(size(mp_runs.(mps).(varn))) < 3
            % domain averaged profile
            nexttile
            nanimagesc(mp_runs.(mps).time, z, mp_runs.(mps).(varn))
            cbar = colorbar;
            cbar.Label.String = [varename_interest{ivar} varunit_interest{ivar}];
            % ylim([0 1100])
            if contains(varn,{'w_da','SS_da','wp_'})
               colormap(cmaps.coolwarm_11)
            elseif contains(varn, 'flag')
               colormap(cmaps.coolwarm_s)
            else
               colormap(cmaps.Blues_s)
            end
            datetick('keeplimits')
            if ~isempty(pRange)
               caxis(pRange)
            end
            set(gca,'ColorScale',linORlog)
            title(mps,'Interpreter','none')
            set(gca,'fontsize',16)
         else
            error("Haven't written the visualization for 3D variables input. Check the var_int_idx.")
         end
      end % iab
   end % its

   if size(mp_runs.(mps).(varn), 2) == 1
      set(gca,'fontsize',16)
      % ylim(pRange)
      datetick('keeplimits')
      xtickangle(45)
      legend('show','Interpreter','none','location','best')
      ylabel([varename_interest{ivar} varunit_interest{ivar}])
      hold off
   elseif length(size(mp_runs.(mps).(varn))) < 3
      title(tl, mconfig(end-2:end), 'fontsize', 20, 'fontweight', 'bold')
      ylabel(tl, 'Altitude [m]', 'fontsize', 20, 'fontweight', 'bold')
   end

   print(sprintf('plots/rams/%s/%s_%s%s.png',nikki,varn,mconfig,var1_str),'-dpng','-r300')
end % ivar
end % ivar1

end % doplot
% }}}

%%

if doanim
set(0, 'DefaultFigurePosition', [0 0 800 600])
varname_interest = {var_interest.da_name};
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

      for iab = ab_plot%:length(ampORbin)
         mps = [ampORbin{iab} '_' bintype{its}]; % mps = microphysics scheme

         if any(contains([var_req_set{var_int_idx}],'GUESS')) && iab==2
            continue
         end

         if contains(varn,'DSD')
            DSD_rightord = permute(mp_runs.(mps).DSDm_da(2:end-1, :, :), [3, 1, 2]);
         else
            if length(size(mp_runs.(mps).(varn))) == 4
               var_xy = squeeze(nanmean(mp_runs.(mps).(varn),3));
               var_xz = squeeze(nansum(mp_runs.(mps).(varn),2));
               var_yz = squeeze(nansum(mp_runs.(mps).(varn),1));
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
            itime = it*2-1;
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

            else

               % top down view
               nanimagesc(runs.GLON(:,1),runs.GLAT(1,:), var_xy(:,:,it))
               colorbar
               if contains(varname_interest{ivar}, 'flag')
                  colormap(cmaps.coolwarm_s)
               else
                  colormap(cmaps.Blues_s)
               end
               if isempty(pRange)
                  caxis([min(var_xy(:)) max(var_xy(:))])
               else
                  caxis(pRange)
               end
               set(gca,'ColorScale',linORlog)
               xlabel('long')
               ylabel('lat')

               % % side view
               % nanimagesc(var_xz(30:70,:,itime)')
               % colormap(cmaps.Blues_s)
               % colorbar
               % if isempty(pRange)
               %    caxis([min(var_xz(:)) max(var_xz(:))])
               % else
               %    caxis(pRange)
               % end

               set(gca,'ColorScale','log')

            end

            title(['time = ' mp_runs.(mps).time_str{itime}])

            cdata{it} = print('-RGBImage','-r300');
            F(it) = im2frame(cdata{it});
         end
         saveVid(F,sprintf('rams/%s/%s_%s_%s_%s',nikki,varn,mconfig,mps,var1_str),5)
      end
   end % its
end % ivar

end % if doanim
end % ivar1
end % iconf
