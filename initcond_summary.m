clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
   bintype aero_N_str w_spd_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-05-25';
case_interest = 2; % 1:length(case_list_num);

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir = dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags = [mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2) = 0; % ignore the current and parent dir
mconfig_ls = {mconfig_ls_dir(mconfig_ls_dir_flags).name};

set(0, 'DefaultFigurePosition',[1553 458 1028 527])

%%

% fig_prof=figure('visible','off');
% fig_path=figure('visible','off');
% fig_proc=figure('visible','off');
% fig_profdiff=figure('visible','off');
% fig_pathdiff=figure('visible','off');
% fig_procdiff=figure('visible','off');

% creating structures for performance analysis based on Rsq and ratio
pfm=struct;

for iconf = 1:length(mconfig_ls)
   mconfig = mconfig_ls{iconf};
   %     mconfig = 'adv_coll';
   run case_dep_var.m
   
   for its = 1:length(bintype)
      for ia = 1:length(aero_N_str)
         %             close all
         for iw = 1:length(w_spd_str)
            %                 close all
            
            [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
               loadnc('amp',case_interest);
            [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
               loadnc('bin',case_interest);
            
%             pause
            
            % indices of vars to compare
            vars=1;
            vare=length(indvar_name);
            
            % plot
            for ici = case_interest
               time = amp_struct(ici).time;
               z = amp_struct(ici).z;
               for ivar = vars:vare
                  var_comp_raw_amp = amp_struct(ici).(indvar_name{ivar});
                  var_amp_flt = var2phys(var_comp_raw_amp,ivar,0,1);
                  
                  var_comp_raw_bin = bin_struct(ici).(indvar_name{ivar});
                  var_bin_flt = var2phys(var_comp_raw_bin,ivar,0,1);
                  
                  % get the non-nan indices for both bin and amp
                  vidx=~isnan(var_amp_flt+var_bin_flt);
                  nzidx=var_amp_flt.*var_bin_flt>0;
                  
                  weight=var_bin_flt(vidx)/sum(var_bin_flt(vidx));
                  weight_log=log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));
                  
                  [mrsq,mr,rsq]=wrsq(var_amp_flt,var_bin_flt,weight);
                  
                  pfm(ici).(indvar_name{ivar}).(bintype{its}).mrsq(ia,iw)=mrsq;
                  pfm(ici).(indvar_name{ivar}).(bintype{its}).mr(ia,iw)=mr;
                  pfm(ici).(indvar_name{ivar}).(bintype{its}).rsq(ia,iw)=rsq;
                  pfm(ici).(indvar_name{ivar}).(bintype{its}).mpath_bin(ia,iw)=mean(var_bin_flt);
                  
               end
            end
         end
      end
   end
end

%% plot
fldnms=fieldnames(pfm(ici).(indvar_name{ivar}).(bintype{its}));
fldnms=fldnms(1:end-1);

close all
for iconf = 1:length(mconfig_ls)
   vars=1;
   vare=length(indvar_name);
   for ici = case_interest
      for ifn = 1:length(fldnms)
         for ivar = vars:vare
            %%
            figure(ivar)
            tl=tiledlayout('flow');
            for its = 1:length(bintype)
               nexttile
               nanimagesc(pfm(ici).(indvar_name{ivar}).(bintype{its}).(fldnms{ifn}))
               colorbar
               title(upper(bintype{its}),'FontWeight','normal')
               xticks(1:length(w_spd_str))
               yticks(1:length(aero_N_str))
               xticklabels(extractAfter(w_spd_str,'w'))
               yticklabels(extractAfter(aero_N_str,'a'))
               set(gca,'FontSize',16)
               
               if strcmp(fldnms{ifn},'mr')
                  colormap(BrBG)
                  set(gca,'ColorScale','log')
                  caxis([1e-1 1e1])
                  
                  [XX,YY]=meshgrid(1:length(w_spd_str),1:length(aero_N_str));
                  mpath_bin_str=sprintfc('%0.2g',...
                     pfm(ici).(indvar_name{ivar}).(bintype{its}).mpath_bin);
                  for ia = 1:length(aero_N_str)
                     for iw = 1:length(w_spd_str)
                        text(iw,ia,mpath_bin_str{ia,iw},'FontSize',16,...
                           'FontWeight','bold','HorizontalAlignment','center')
                     end
                  end
                  
               elseif strcmp(fldnms{ifn},'rsq')
                  colormap(coolwarm_r)
                  set(gca,'ColorScale','lin')
                  caxis([0 1])
               elseif strcmp(fldnms{ifn},'mrsq')
                  colormap(coolwarm_r)
                  set(gca,'ColorScale','lin')
                  caxis([-1 1])
               end
               
            end
            xlabel(tl,'max vertical velocity [m/s]','fontsize',16)
            ylabel(tl,'aerosol concetration [1/cc]','fontsize',16)
            
            title(tl,[indvar_ename{ivar} ' - ' (fldnms{ifn})],...
               'fontsize',20,'fontweight','bold')
            saveas(figure(ivar),['plots/summ ' mconfig_ls{iconf} ' ' ...
               (indvar_ename{ivar}) ' ' fldnms{ifn}...
               ' ' case_list_str{ici} '.png'])
         end
      end
      
   end
end