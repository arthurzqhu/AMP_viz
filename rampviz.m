clearvars -except cmaps
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iab l_da var1_str
close all

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;

nikki = '2023-02-25';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);

% ampORbin = {'amp'}; %temporary
% ampORbin = {'bin'}; %temporary
% bintype = {'tau'};
% bintype = {'sbm'};

% index of variables to be plotted
% corresponding variables can be found in rglobal_var.m
var_int_idx = [1 2 4 5 36];

% whether we want the domain averaged quantity
% can be set to an array but needs to have the same length as var_int_idx


for iconf = 1:length(mconfig_ls)
rcase_depvar
mconfig = mconfig_ls{iconf};
disp(mconfig)

mp_runs(length(var1_str_list)) = struct;

% load RAMS output
for ivar1 = 1:length(var1_str_list)
var1_str = var1_str_list{ivar1};
for its = 1:length(bintype)
   for iab = 1:length(ampORbin)
      disp([ivar1 its iab])
      if doanim
         l_da = 0; 
      else
         l_da = 1;
      end
      l_da = repelem(l_da,length(var_int_idx));
      % set DSD to domain averaged value
      l_da(contains({var_name_set{var_int_idx}},'DSD')) = 2;

      % skip bin if the var is AMP-specific
      if any(contains([var_req_set{var_int_idx}],'GUESS')) && iab==2
         continue
      end

      % get var_interest as an object
      var_interest = get_varint(var_int_idx);
      mps = [ampORbin{iab} '_' bintype{its}]; % mps = microphysics scheme
      mp_runs(ivar1).(mps) = loadrams(ampORbin{iab});
      % make sure that z is never negative
      z = z(2:end-1);
   end
end
end

% 'pause'
% pause

%%

% {{{ figs:

if doplot
varname_interest = {var_interest.da_name};
varename_interest = {var_interest.da_ename};
varunit_interest = {var_interest.units};

for ivar1 = 1:length(var1_str_list)
var1_str = var1_str_list{ivar1};
var1_val = var1_val_arr(ivar1);

for ivar = 1:length(varname_interest)
   figure('position',[0 0 800 400])
   tl = tiledlayout('flow');
   varn = varname_interest{ivar};
   pRange = var_interest(ivar).range;

   linORlog = var_interest(ivar).linORlog;
   for its = 1:length(bintype)
      for iab = 1:length(ampORbin)

         % skip bin if the var is AMP-specific
         if any(contains([var_req_set{var_int_idx}],'GUESS')) && iab==2
            continue
         end

         mps = [ampORbin{iab} '_' bintype{its}];
         ubound = max(abs(mp_runs(ivar1).(mps).(varn)(:)));
         % if min(mp_runs(ivar1).(mps).(varn)(:)) < 0
         %    lbound = -ubound;
         % else
         %    lbound = min(mp_runs(ivar1).(mps).(varn), [], 'all');
         % end
         % pRange = [lbound ubound];
         if size(mp_runs(ivar1).(mps).(varn), 2) == 1
            % domain averaged path
            if its*iab == 1
               nexttile
            end
            plot(mp_runs(ivar1).(mps).time,mp_runs(ivar1).(mps).(varn),'LineWidth',2,'displayname',mps,...
               'LineStyle', ampbin_lsty{iab},'Color',color_order{its},'LineWidth',ampbin_lwid(iab))
            hold on
         elseif length(size(mp_runs(ivar1).(mps).(varn))) < 3
            % domain averaged profile
            nexttile
            nanimagesc(mp_runs(ivar1).(mps).time, z, mp_runs(ivar1).(mps).(varn))
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

   if size(mp_runs(ivar1).(mps).(varn), 2) == 1
      set(gca,'fontsize',16)
      % ylim(pRange)
      datetick('keeplimits')
      xtickangle(45)
      legend('show','Interpreter','none','location','best')
      ylabel([varename_interest{ivar} varunit_interest{ivar}])
      hold off
   elseif length(size(mp_runs(ivar1).(mps).(varn))) < 3
      title(tl, mconfig(end-2:end), 'fontsize', 20, 'fontweight', 'bold')
      ylabel(tl, 'Altitude [m]', 'fontsize', 20, 'fontweight', 'bold')
   end

   print(sprintf('plots/rams/%s/%s_%s_%.1f.png',nikki,varn,mconfig,var1_val),'-dpng','-r300')
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
   for its = 1:length(bintype)
      mps_amp = ['amp_' bintype{its}];
      mps_bin = ['bin_' bintype{its}];

      if its==2
         binmean = load('diamg_sbm.txt')*1e6;
      elseif its==1
         binmean = load('diamg_tau.txt')*1e6;
      end

      % when plotting difference b/w amp and bin
      % pRange(2) = abs(max(mp_runs(ivar1).(mps_amp).(varn)(:)) - max(mp_runs(ivar1).(mps_bin).(varn)(:)));
      % pRange(1) = -pRange(2);


      for iab = 2:length(ampORbin)
         mps = [ampORbin{iab} '_' bintype{its}]; % mps = microphysics scheme

         % % when plotting the absolute quantities
         % if isempty(pRange)
         %    pRange(2) = max(mp_runs(ivar1).(mps).(varn)(:));
         %    pRange(1) = pRange(2)/1e4;
         % end

         if any(contains([var_req_set{var_int_idx}],'GUESS')) && iab==2
            continue
         end

         if contains(varn,'DSD')
            DSD_rightord = permute(mp_runs(ivar1).(mps).DSDm_da(2:end-1, :, :), [3, 1, 2]);
         else
            if length(size(mp_runs(ivar1).(mps).(varn))) == 4
               var_2D = squeeze(nanmean(mp_runs(ivar1).(mps).(varn),3));
            elseif length(size(mp_runs(ivar1).(mps).(varn))) == 3
               var_2D = mp_runs(ivar1).(mps).(varn);
            end
         end

         F(length(mp_runs(ivar1).(mps).time)) = struct('cdata',[],'colormap',[]);

         parfor (it = 1:length(mp_runs(ivar1).(mps).time),24)
            it
            if contains(varn,'DSD')

               % xlabel('Diameter [\mum]')
               % nanimagesc(binmean, z, DSD_rightord(:,:,it)')
               % colorbar
               % colormap(cmaps.Blues_s)
               % caxis([1e-8 1e-2])
               % set(gca,'XScale','log')
               % set(gca,'ColorScale','log')
               % ylabel('Altitude [m]')
               % xlim([binmean(1) binmean(end)])

            else
               % var_diff = mp_runs(ivar1).(mps_amp).(varn)(:,:,it)-mp_runs(ivar1).(mps_bin).(varn)(:,:,it);

               % if isempty(pRange)
               %    pRange(1) = ;
               %    pRange(2) = max(var_2D(:));
               % end

               % nanimagesc(runs.GLON(:,1),runs.GLAT(1,:), var_2D(:,:,it))
               nanimagesc(var_2D(:,:,it))
               colorbar

               if contains(varname_interest{ivar}, 'flag')
                  colormap(cmaps.coolwarm_s)
               else
                  colormap(cmaps.Blues_s)
               end


               if isempty(pRange)
                  caxis([min(var_2D(:)) max(var_2D(:))])
               else
                  caxis(pRange)
               end
               set(gca,'ColorScale',linORlog)
               xlabel('long')
               ylabel('lat')

            end

            title(['time = ' mp_runs(ivar1).(mps).time_str{it}])

            cdata{it} = print('-RGBImage','-r300');
            F(it) = im2frame(cdata{it});
         end
         saveVid(F,sprintf('rams/%s/%s_%s_%s',nikki,varn,mconfig,mps),5)
      end
   end % its
end % ivar

end % if doanim
end % iconf
