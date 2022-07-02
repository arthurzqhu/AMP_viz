clear
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest
close all

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;

rglobal_var
nikki = 'noUV';
mconfig_ls = get_mconfig_list(output_dir,nikki);

% index of variables to be plotted
% corresponding variables can be found in rglobal_var.m
var_int_idx = [1:3 6:8 11];

% whether we want the domain averaged quantity
% can be set to an array but needs to have the same length as var_int_idx
l_da = 1; 

% get var_interest as an object
var_interest = get_varint(var_int_idx);


for iconf = 1:length(mconfig_ls)
mconfig = mconfig_ls{iconf}

% load RAMS output
for its = 1:length(bintype)
   for iab = 1:length(ampORbin)
      mps = [ampORbin{iab} '_' bintype{its}];
      mp_runs.(mps) = loadrams(ampORbin{iab});
      % make sure that z is never negative
      z = z(2:end-1);
   end
end

%%

if doplot
varname_interest = {var_interest.da_name};
varename_interest = {var_interest.da_ename};
varunit_interest = {var_interest.units};

for ivar = 1:length(varname_interest)
   figure('position',[0 0 700 400])
   tl = tiledlayout('flow');
   varn = varname_interest{ivar};
   pRange = var_interest(ivar).range;
   linORlog = var_interest(ivar).linORlog;
   for its = 1:length(bintype)
      for iab = 1:length(ampORbin)
         mps = [ampORbin{iab} '_' bintype{its}];
         if size(mp_runs.(mps).(varn), 2) == 1
            % domain averaged path
            if its*iab == 1
               nexttile
            end
            plot(mp_runs.(mps).time,mp_runs.(mps).(varn),'LineWidth',2,'displayname',mps)
            hold on
         elseif length(size(mp_runs.(mps).(varn))) < 3
            % domain averaged profile
            nexttile
            nanimagesc(mp_runs.(mps).time, z, mp_runs.(mps).(varn))
            ylim([600 1100])
            cbar = colorbar;
            cbar.Label.String = [varename_interest{ivar} varunit_interest{ivar}];
            colormap(cmap.Blues)
            datetick('keeplimits')
            caxis(pRange)
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
      datetick('keeplimits')
      xtickangle(45)
      legend('show','Interpreter','none','location','southwest')
      ylabel([varename_interest{ivar} varunit_interest{ivar}])
      hold off
   elseif length(size(mp_runs.(mps).(varn))) < 3
      title(tl, mconfig(end-2:end), 'fontsize', 20, 'fontweight', 'bold')
      ylabel(tl, 'Altitude [m]', 'fontsize', 20, 'fontweight', 'bold')
   end

   print(sprintf('plots/rams/%s/%s_%s.png',nikki,varn,mconfig),'-dpng','-r300')
end % ivar

end % doplot

%%

if doanim
set(0, 'DefaultFigurePosition', [0 0 800 600])
varname_interest = {var_interest.var_name};
varename_interest = {var_interest.var_ename};
varunit_interest = {var_interest.units};
for ivar = 1:length(varname_interest)
   varn = varname_interest{ivar};
   for its = 1:length(bintype)
      for iab = 1:length(ampORbin)
         mps = [ampORbin{iab} '_' bintype{its}];
         for it = 1:size(mp_runs.(mps).time)
            it
            contourf(runs.GLON,runs.GLAT,...
               squeeze(mp_runs.(mps).(varn)(:,:,it)),...
               'LineColor','none')
            colorbar
            colormap(cmap.Blues)
            caxis([1e-3 3e2])
            set(gca,'ColorScale','log')

            xlabel('long')
            ylabel('lat')
            title(['time = ' fn{it}(end-11:end-6)])

            cdata = print('-RGBImage','-r144');
            F(it) = im2frame(cdata);
            %F(it)=getframe(gcf);
         end
         saveVid(F,sprintf('rams/%s/%s_%s_%s',nikki,varn,mconfig,mps),30)
      end % iab
   end % its
end % ivar


end % if doanim
end % iconf
