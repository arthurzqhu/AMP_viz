clearvars -except cmaps
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set ...
   indvar_name_all indvar_ename_all indvar_units_all cwp_th

vnum = '0001'; % last four characters of the model output file.
nikki = '2023-01-03';
disp(nikki)
global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
get_var_comp([3 4 16])
confs = [2 3 1 4]; % should be in the order of vcm, dmr, vcm_4m, vdmr_4m

%%
ientry = 0;
pfm = struct;
for iconf = confs
ientry = ientry + 1;
mconfig = mconfig_ls{iconf};
disp(mconfig)
case_dep_var
for its = 1:length(bintype)
   for ivar1 = 1:length(var1_str)
      for ivar2 = 1:length(var2_str)
         disp([its, ivar1, ivar2])
         amp_struct = loadnc('amp', indvar_name_set);
         bin_struct = loadnc('bin', indvar_name_set);

         time = amp_struct.time;
         z = amp_struct.z;

         for ivar = 2
            var_comp_raw_amp = amp_struct.(indvar_name{ivar});
            var_amp_flt = var2phys(var_comp_raw_amp,ivar,0,1,1);

            var_comp_raw_bin = bin_struct.(indvar_name{ivar});
            var_bin_flt = var2phys(var_comp_raw_bin,ivar,0,1,1);

            % get delta from the initial value
            var_amp_flt = var_amp_flt - var_amp_flt(1);
            var_bin_flt = var_bin_flt - var_bin_flt(1);

            % get the non-nan indices for both bin and amp
            vidx = ~isnan(var_amp_flt+var_bin_flt);
            nzidx = var_amp_flt.*var_bin_flt>0;

            weight = var_bin_flt(vidx)/sum(var_bin_flt(vidx));
            weight_log = log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));

            [mr, rsq, mval_amp, mval_bin] = wrsq(var_amp_flt, var_bin_flt, weight);

            pfm(ientry).(indvar_name{ivar}).(bintype{its}).mr(ivar1, ivar2) = mr;
            pfm(ientry).(indvar_name{ivar}).(bintype{its}).rsq(ivar1, ivar2) = rsq;
            pfm(ientry).(indvar_name{ivar}).(bintype{its}).mpath_bin(ivar1, ivar2) = mval_bin;
            pfm(ientry).(indvar_name{ivar}).(bintype{its}).mpath_amp(ivar1, ivar2) = mval_amp;
         end
      end % ivar2
   end % ivar1
end % its
pfm(ientry).misc.var1_str = var1_str;
pfm(ientry).misc.var2_str = var2_str;
end % iconf
save(['pfm_summary/' nikki '_pfm.mat'],'pfm')

%%%
%figure('position',[0 0 1000 600])
%tl = tiledlayout('flow');
%% cmi = [1-.1./(2.^(-2:9)) 1];
%cmi = [.8 .9 0.95 0.975 0.9875 0.99375 0.996875 0.9984375 0.99921875 1.];
%dmr = 30:5:100;

%ifig = 0;
%ientry = 0;
%for iconf = confs
%   ientry = ientry + 1;
%   nexttile
%   ifig = ifig + 1;
%   if ifig < 3
%      cat_text = ' (original AMP)';
%   else
%      cat_text = ' (unified category AMP)';
%   end
%   hold on
%   for its = 1:2
%      if mod(ifig,2) == 1
%         xx=cmi;
%         yy1=pfm(ientry).rain_M1_path.(bintype{its}).mr';
%         yy2=ones(size(yy1));
%         pt=patch([xx fliplr(xx)], [yy1 fliplr(yy2)], color_order{its},'edgecolor','none',...
%            'FaceAlpha', .2);
%         set(get(get(pt,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

%         plot(cmi, pfm(ientry).rain_M1_path.(bintype{its}).mr,'-*', 'linewidth',2)
%         xlabel('Initial L1 mode mass fraction')
%         title(['(',char(96+ifig),') D_{L2m} = 50 \mum', cat_text])
%      else
%         xx=dmr;
%         yy1=pfm(ientry).rain_M1_path.(bintype{its}).mr;
%         yy2=ones(size(yy1));
%         pt=patch([xx fliplr(xx)], [yy1 fliplr(yy2)], color_order{its},'edgecolor','none',...
%            'FaceAlpha', .2);
%         set(get(get(pt,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

%         plot(dmr, pfm(ientry).rain_M1_path.(bintype{its}).mr,'-*', 'linewidth',2)
%         xlabel('Initial L2 mode D_m [\mum]')
%         xlim([30 100])
%         xticks([30:10:100])
%         title(['(',char(96+ifig),') X_{L1} = 0.999', cat_text])
%      end
%      ylim([0.7 1.05])
%   end
%   grid
%   legend('TAU', 'SBM', 'location', 'best')
%   hold off
%   set(gca,'fontsize', 16)
%end

%ylabel(tl, 'AMP/bin ratio in RWP', 'fontsize', 18)
%title(tl, 'Effects of autoconversion on AMP/bin RWP ratio', 'fontsize', 20, 'fontweight', 'bold')

%exportgraphics(gcf,['plots/p1/autoconv_rwp.png'],'Resolution',300)
