clearvars -except cmaps
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iab l_da var1_str script_name
close all

script_name = mfilename;

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;

nikki = 'UvsS';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);

var_int_idx = [5];
t_snap = [1800];
dt = 60;
it_snap = ceil(t_snap/dt);

l_da = 3; 

mp_runs = struct;

mconfig = mconfig_ls{1};
rcase_dep_var

figure('position',[0 0 1200 1200])
tl = tiledlayout(4,4,'TileSpacing','compact','padding','compact');
ifig=0;

for ivar1 = 1:length(var1_str_list)
var1_str = var1_str_list{ivar1};

for iconf = [1 2]
mconfig = mconfig_ls{iconf};
disp(mconfig)

% mp_runs(length(var1_str_list)) = struct;

% load RAMS output
for its = 2:length(bintype)
   for iab = 1:length(ampORbin)
      if iconf > 1 && iab == 2
         % dont need to load the same bin scheme more than once
         continue
      end

      disp([ampORbin{iab} '-' bintype{its}])
      % disp([ivar1 its iab])
      if doanim
         l_da = 0; 
      else
         l_da = 1;
      end
      l_da = repelem(l_da,length(var_int_idx));
      % the single column at x=50, y=50 will be selected instead of domain averaging
      l_da(contains({var_name_set{var_int_idx}},{'DSD','ppt'})) = 2;

      % cloud/rain/liquid water content is viewed as a cross section of the cloud at x=50
      l_da(contains({var_name_set{var_int_idx}},{'CWC','RWC','LWC'})) = 3;

      % skip bin if the var is AMP-specific
      if any(contains([var_req_set{var_int_idx}],'GUESS')) && iab==2
         continue
      end

      % get var_interest as an object
      var_interest = get_varint(var_int_idx);
      % mp = microphysics scheme
      if iab == 1
         mp = [ampORbin{iab} extractAfter(mconfig,lettersPattern) '_' bintype{its}]; 
         mp_amp{iconf} = mp;
      else
         mp = [ampORbin{iab} '_' bintype{its}]; 
         mp_bin = mp;
      end

      mp_runs.(mp) = loadrams(ampORbin{iab},it_snap);
      % make sure that z is never negative
      z = z(2:end-1);
   end % iab
end % its

var_names = {var_interest.var_name};
var_enames = {var_interest.var_ename};
var_da_names = {var_interest.da_name};
var_da_enames = {var_interest.da_ename};
var_units = {var_interest.units};

end % iconf

ivar=1;
var_name = var_names{ivar};
var_da_name = var_da_names{ivar};
pRange = var_interest(ivar).range;
linORlog = var_interest(ivar).linORlog;

% find the max value of the caxis limits with a nice round number
max_samp = round(max(mp_runs.(mp_amp{1}).(var_da_name)(:))*20)/20;
max_bin = round(max(mp_runs.(mp_bin).(var_da_name)(:))*20)/20;
max_uamp = round(max(mp_runs.(mp_amp{end}).(var_da_name)(:))*20)/20;

max_color = max([max_samp max_bin max_uamp]);

y_dist=(-49:30)*100;

nexttile
ifig=ifig+1;
nanimagesc(y_dist, z, mp_runs.(mp_amp{1}).(var_da_name)(:,:)')
title(['(',Alphabet(ifig),') ','S-AMP ' var1_str])
set(gca,'fontsize',16)
xlim([-1200 1200])
ylim([0 5000])
colormap(cmaps.Blues_s)
cb = colorbar;
caxis([0 max_color])
cb.Label.String = [var_name var_units{ivar}];

nexttile
ifig=ifig+1;
nanimagesc(y_dist, z, mp_runs.(mp_bin).(var_da_name)(:,:)')
title(['(',Alphabet(ifig),') ','bin ' var1_str])
set(gca,'fontsize',16)
xlim([-1200 1200])
ylim([0 5000])
colormap(cmaps.Blues_s)
cb = colorbar;
caxis([0 max_color])

nexttile
ifig=ifig+1;
nanimagesc(y_dist, z, mp_runs.(mp_amp{end}).(var_da_name)(:,:)')
title(['(',Alphabet(ifig),') ','U-AMP ' var1_str])
set(gca,'fontsize',16)
xlim([-1200 1200])
ylim([0 5000])
colormap(cmaps.Blues_s)
cb = colorbar;
caxis([0 max_color])


nexttile
ifig=ifig+1;
hold on
plot(mp_runs.(mp_amp{1}).(var_da_name)(50,2:end-1),z,'LineWidth',1.5,'displayname',...
   'S-AMP-SBM','LineStyle',':','Color',color_order{2})
plot(mp_runs.(mp_bin).(var_da_name)(50,2:end-1),z,'LineWidth',.5,'displayname',...
   'bin-SBM','LineStyle','-','Color',color_order{2})
plot(mp_runs.(mp_amp{end}).(var_da_name)(50,2:end-1),z,'LineWidth',1,'displayname',...
   'U-AMP-SBM','LineStyle','--','Color',color_order{2})
title(['(',Alphabet(ifig),')'])
set(gca,'fontsize',16)
xlabel(['Central ' var_names{ivar} var_units{ivar}])
ylim([0 5000])
legend('show')
grid on
hold off

% var1_short = extractBefore(var1_str,digitsPattern);
% var1_symb = initVarSymb_dict(var1_short);
% var1_units = initVarUnit_dict(var1_short);
% var1_val = extractAfter(var1_str,lettersPattern);
% title_text = [var1_symb, ' = ', var1_val, var1_units(3:end-1)];
% title(title_text)

% shape_param = extractBetween(mp,'_','_');
end % ivar1

xlabel(tl,'Distance from Center of Cloud [m]        ','fontweight','bold','fontsize',24)
ylabel(tl,'Altitude [m]','fontweight','bold','fontsize',24)
title(tl,'U-AMP vs. S-AMP in RAMS @ t = 30 min','fontweight','bold','fontsize',24)
exportgraphics(gcf,['plots/p2/f11_' nikki, ' ', var_name, ' snapshot at t=', num2str(t_snap),'.pdf'])
saveas(gcf,['plots/p2/f11_' nikki, ' ', var_name, ' snapshot at t=', num2str(t_snap),'.fig'])
