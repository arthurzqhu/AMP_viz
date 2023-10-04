clearvars -except cmaps
clear global

global nfile filedir runs mpdat mp_list deltaz deltax z nikki mconfig its ...
   var_interest iab l_da var1_str script_name islink
close all

script_name = mfilename;

addpath('ramsfuncs/')
doanim = 0;
doplot = 1;

nikki = 'UvsS';
rglobal_var
mconfig_ls = get_mconfig_list(output_dir,nikki);

var_int_idx = [1 2 36];

mp_runs = struct;

mconfig = mconfig_ls{1};
rcase_dep_var

figure('position',[0 0 1000 1200])
tl = tiledlayout(4,3,'TileSpacing','compact','padding','compact');
ifig = 0;

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

      mp_runs.(mp) = loadrams(ampORbin{iab});
      % make sure that z is never negative
      z = z(2:end-1);
   end % iab
end % its

varname_interest = {var_interest.da_name};
varename_interest = {var_interest.da_ename};
varunit_interest = {var_interest.units};

end % iconf

for ivar = 1:length(var_int_idx)
varn = varname_interest{ivar};
pRange = var_interest(ivar).range;
linORlog = var_interest(ivar).linORlog;

nexttile
ifig=ifig+1;
time = (mp_runs.(mp_amp{1}).time-mp_runs.(mp_amp{1}).time(1))*1440;
time = int32(time);
plot(time, mp_runs.(mp_amp{1}).(varn),'LineWidth',1.5,'displayname',...
   'S-AMP-SBM','LineStyle',':','Color',color_order{fibonacci(ivar)})
hold on
plot(time, mp_runs.(mp_bin).(varn),'LineWidth',.5,'displayname',...
   'bin-SBM','LineStyle','-','Color',color_order{fibonacci(ivar)})
plot(time, mp_runs.(mp_amp{end}).(varn),'LineWidth',1,...
   'displayname','U-AMP-SBM','LineStyle','--','Color',color_order{fibonacci(ivar)})

set(gca,'fontsize',16)
xlim([0 max(time)])
xticks([0 15 30 45 60])
if ivar1 == 1
   legend('show','Interpreter','none','location','best')
end
ylabel([varename_interest{ivar} varunit_interest{ivar}])

var1_short = extractBefore(var1_str,digitsPattern);
var1_symb = initVarSymb_dict(var1_short);
var1_units = initVarUnit_dict(var1_short);
var1_val = extractAfter(var1_str,lettersPattern);
title_text = ['(',Alphabet(ifig),') ',var1_symb, ' = ', var1_val, var1_units(3:end-1)];
title(title_text)
hold off

% shape_param = extractBetween(mp,'_','_');
end % ivar
end % ivar1

title(tl,'U-AMP vs. S-AMP in RAMS','fontweight','bold','fontsize',24)
xlabel(tl,'Time [min]','fontweight','bold','fontsize',24)
exportgraphics(gcf,['plots/p2/f10_' nikki, ' crp time series.pdf'])
saveas(gcf,['plots/p2/f10_' nikki, ' crp time series.fig'])
