clearvars -except cmaps
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iab l_da var1_str
close all

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;

nikki = 'UvsS';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);

var_int_idx = [6 15];

l_da = 2; 

mp_runs = struct;

mconfig = mconfig_ls{1};
rcase_dep_var

t_snaps = [1200 1400];
dt = 60;
it_snaps = floor(t_snaps/dt);

for it = 1:length(t_snaps)
it_snap = it_snaps(it);
t_snap = t_snaps(it);
disp(t_snap)
figure('position',[0 0 1200 1200])
tl = tiledlayout(4,4,'TileSpacing','compact','padding','compact');


for ivar1 = 1:length(var1_str_list)
var1_str = var1_str_list{ivar1};

for iconf = [1 2]
mconfig = mconfig_ls{iconf};
disp(mconfig)

% mp_runs(length(var1_str_list)) = struct;

% load RAMS output
for its = 2:length(bintype)
   if its==2
      binmean = load('diamg_sbm.txt')*1e6;
   elseif its==1
      binmean = load('diamg_tau.txt')*1e6;
   end

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

      mp_runs.(mp) = loadrams(ampORbin{iab},it_snap-1);
      % make sure that z is never negative
      z = z(2:end-1);
   end % iab
end % its

varname_interest = {var_interest.da_name};
varename_interest = {var_interest.da_ename};
varunit_interest = {var_interest.units};

end % iconf

ivar=2;
varn = varname_interest{ivar};
pRange = var_interest(ivar).range;
linORlog = var_interest(ivar).linORlog;

nexttile
nanimagesc(binmean, z, mp_runs.(mp_amp{1}).(varn)(:,:))
title(['S-AMP ' var1_str])
set(gca,'fontsize',16)
ylabel('Altitude [m]')
ylim([0 5000])
caxis([1e-8 1e-2])
set(gca,'XScale','log')
set(gca,'ColorScale','log')
xlim([binmean(1) binmean(end)])
xticks([1e1 1e2 1e3])
grid on
if ivar1==length(var1_str)
   xlabel('Diameter [\mum]')
end

nexttile
nanimagesc(binmean, z, mp_runs.(mp_bin).(varn)(:,:))
title(['bin ' var1_str])
set(gca,'fontsize',16)
ylim([0 5000])
caxis([1e-8 1e-2])
set(gca,'XScale','log')
set(gca,'ColorScale','log')
xlim([binmean(1) binmean(end)])
xticks([1e1 1e2 1e3])
grid on
if ivar1==length(var1_str)
   xlabel('Diameter [\mum]')
end

nexttile
nanimagesc(binmean, z, mp_runs.(mp_amp{end}).(varn)(:,:))
title(['U-AMP ' var1_str])
set(gca,'fontsize',16)
ylim([0 5000])
caxis([1e-8 1e-2])
set(gca,'XScale','log')
set(gca,'ColorScale','log')
xlim([binmean(1) binmean(end)])
xticks([1e1 1e2 1e3])
grid on
if ivar1==length(var1_str)
   xlabel('Diameter [\mum]')
end

colormap(cmaps.Blues_s)

ivar=1;
varn = varname_interest{ivar};
pRange = var_interest(ivar).range;
linORlog = var_interest(ivar).linORlog;
nexttile
hold on
plot(mp_runs.(mp_amp{1}).(varn)(50,2:end-1),z,'LineWidth',1,'displayname',...
   'S-AMP-SBM','LineStyle','--','Color',color_order{2})
plot(mp_runs.(mp_bin).(varn)(50,2:end-1),z,'LineWidth',.5,'displayname',...
   'bin-SBM','LineStyle','-','Color',color_order{2})
plot(mp_runs.(mp_amp{end}).(varn)(50,2:end-1),z,'LineWidth',1.5,'displayname',...
   'U-AMP-SBM','LineStyle',':','Color',color_order{2})
set(gca,'fontsize',16)
xlabel('LWC [g/kg]')
ylabel('Altitude [m]')
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

title(tl,'U-AMP vs. S-AMP in RAMS','fontweight','bold','fontsize',24)
exportgraphics(gcf,['plots/p2/' nikki, ' DSD snapshot at t=', num2str(t_snap),'.pdf'])
% saveas(gcf,['plots/p2/' nikki, ' ', var1_str, ' ', shape_param{1}, ' ', varn '.fig'])
% saveas(gcf,['plots/p2/' varn '.fig'])
end
