clear
clear global

global nfile runs mpdat mp_list imp deltaz z mconfig bintype its output_dir var_int_idx ...
   filedir bintype
close all

addpath('ramsfuncs/')
doplot = 1
doload = 1

rglobal_var
nikki='noUV';
mconfig_ls = get_mconfig_list(output_dir,nikki);

% index of variables to be plotted
% corresponding variables can be found in rglobal_var.m
var_int_idx = [1:3 6:8 11];

% whether we want the domain averaged quantity
% can be set to an array but needs to have the same length as var_int_idx
l_da = 1; 

% get var_interest as an object
var_interest = get_varint(var_int_idx);

if ~doload
   for iconf = 1:length(mconfig_ls)-1

   mconfig = mconfig_ls{iconf}
   for its = 1:length(bintype)

      amp_runs = loadrams('amp');
      bin_runs = loadrams('bin');

      clear runs

      deltaz=z(2)-z(1);

      varname_interest = {var_interest.da_name};
      varename_interest = {var_interest.da_ename};
      varunit_interest = {var_interest.units};

      for ivar = 1:length(varname_interest)
         varn = varname_interest{ivar};

         amp_var_flat = amp_runs.(varn)(:);
         bin_var_flat = bin_runs.(varn)(:);
         vidx = ~isnan(amp_var_flat + bin_var_flat);
         weight = bin_var_flat(vidx) / sum(bin_var_flat);
         [mr, rsq, ~, ~, ~, ~, ~, ~, mval_amp, mval_bin] = wrsq(amp_var_flat, bin_var_flat, weight);

         pfm.(varn).(bintype{its}).mr(conf2grid{iconf}(1), conf2grid{iconf}(2)) = mr;
         pfm.(varn).(bintype{its}).rsq(conf2grid{iconf}(1), conf2grid{iconf}(2)) = rsq;
         pfm.(varn).(bintype{its}).mval_amp(conf2grid{iconf}(1), conf2grid{iconf}(2)) = mval_amp;
         pfm.(varn).(bintype{its}).mval_bin(conf2grid{iconf}(1), conf2grid{iconf}(2)) = mval_bin;
      end

   end % its
   end % iconf
   save(sprintf('rpfm_summary/%s_pfm.mat',nikki), 'pfm')
else % if doload
   load(sprintf('rpfm_summary/%s_pfm.mat',nikki))
end % doload

if doplot
   varname_interest = {var_interest.da_name};
   varename_interest = {var_interest.da_ename};
   varunit_interest = {var_interest.units};
   for ivar = 1:length(varname_interest)
      varn = varname_interest{ivar};
      pRange = var_interest(ivar).range;
      linORlog = var_interest(ivar).linORlog;

      set(gcf,'position',[1331 587 1250 390])
      tl = tiledlayout(4,4);
      for its = 1:length(bintype)
         nexttile(its*2+3,[3 2])
         mean_ratio = pfm.(varn).(bintype{its}).mr;
         mean_ratio(mean_ratio==0) = nan;
         nanimagesc(mean_ratio)

         set(gca,'ydir','reverse')
         cb = colorbar;
         if its == length(bintype)
            cb.Label.String = 'AMP/bin'; 
         end

         mval_bin = pfm.(varn).(bintype{its}).mval_bin;
         title(sprintf('%s - %0.3g', upper(bintype{its}), mval_bin(1)), ...
            'FontWeight', 'normal')

         colormap(cmap.BrBG)
         set(gca,'ColorScale','log')
         caxis([.5 2])

         mval_amp = pfm.(varn).(bintype{its}).mval_amp;
         [XX, YY] = meshgrid(1:size(mval_amp,1), 1:size(mval_amp,2));
         mval_str = sprintfc('%0.3g', mval_amp);

         xticks(1:size(mval_amp,2))
         yticks(1:size(mval_amp,1))
         xticklabels((1:size(mval_amp,2))*2)
         yticklabels((0:size(mval_amp,1)-1)*2)

         set(gca,'FontSize',16)
         for imom1 = 1:size(mval_amp,1)
            for imom2 = 1:size(mval_amp,2)

               % get text color
               ngrads = size(cmap.coolwarm_r11,1);
               rsq = pfm.(varn).(bintype{its}).rsq(imom1, imom2);
               rsq(rsq==0) = nan;
               clr_idx = roundfrac(rsq, 1/ngrads)*ngrads;
               clr_idx = round(clr_idx);

               if isnan(clr_idx) 
                  continue
               end
               if clr_idx == 0 
                  clr_idx = 1; 
               end

               text(imom2+0.015,imom1-0.015,mval_str{imom1, imom2},'fontsize',15,...
                  'horizontalalignment','center',...
                  'color',cmap.coolwarm_r11(clr_idx,:)*.1,'fontname','menlo')
               text(imom2,imom1,mval_str{imom1, imom2},'fontsize',15,...
                  'horizontalalignment','center',...
                  'color',cmap.coolwarm_r11(clr_idx,:),'fontname','menlo')
            end
         end

         nexttile(2,[1,2])
         set(gca,'Color','none')
         set(gca,'XColor','none')
         set(gca,'YColor','none')
         colormap(gca,cmap.coolwarm_r)
         cb = colorbar('southoutside');
         cb.Label.String = 'R^2';
         cb.Label.Position = [0.5000 3.3 0];
         set(gca,'FontSize',16)
         
         xlabel(tl, 'M2', 'FontSize', 16)
         ylabel(tl, 'M1', 'FontSize', 16)
         title(tl, [nikki ' - ' varn], 'Interpreter', 'none',...
            'FontSize', 20, 'FontWeight', 'bold')
      end % its

      print(sprintf('plots/rams/%s/pfm summary %s.png',nikki,varn),'-dpng','-r300')
   end % ivar
end % doplot
