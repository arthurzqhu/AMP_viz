clear
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-10-06';
case_interest=2; % 1:length(case_list_num);

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir=dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags=[mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2)=0; % ignore the current and parent dir
mconfig_ls={mconfig_ls_dir(mconfig_ls_dir_flags).name};

set(0, 'DefaultFigurePosition',[1331 587 1250 390])

%%

% fig_prof=figure('visible','off');
% fig_path=figure('visible','off');
% fig_proc=figure('visible','off');
% fig_profdiff=figure('visible','off');
% fig_pathdiff=figure('visible','off');
% fig_procdiff=figure('visible','off');

% creating structures for performance analysis based on Rsq and ratio
pfm=struct;
iconf=1;
%for iconf=1%:length(mconfig_ls)
   mconfig=mconfig_ls{iconf}
   %     mconfig='adv_coll';
   run case_dep_var.m
   for its=1:length(bintype)
      for ivar1=1:length(var1_str)
         %             close all
         for ivar2=1:length(var2_str)
            %                 close all
           [its,ivar1,ivar2]
            [amp_fi, amp_fn, amp_info, amp_var_name, amp_struct]=...
               loadnc('amp',case_interest);
            [bin_fi, bin_fn, bin_info, bin_var_name, bin_struct]=...
               loadnc('bin',case_interest);
            
            for ici=1:length(case_interest)
               icase=case_interest(ici);
               

               % indices of vars to compare
               vars=1;
               vare=length(indvar_name);

               time=amp_struct.time;
               z=amp_struct.z;
               for ivar=vars:vare
                  
                  
                  
                  var_comp_raw_amp=amp_struct.(indvar_name{ivar});
                  var_amp_flt=var2phys(var_comp_raw_amp,ivar,0,1);
                  
                  var_comp_raw_bin=bin_struct.(indvar_name{ivar});
                  var_bin_flt=var2phys(var_comp_raw_bin,ivar,0,1);
                  
                  % get the non-nan indices for both bin and amp
                  vidx=~isnan(var_amp_flt+var_bin_flt);
                  nzidx=var_amp_flt.*var_bin_flt>0;
                  
                  weight=var_bin_flt(vidx)/sum(var_bin_flt(vidx));
                  weight_log=log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));
                  
                  [mrsq,mr,rsq]=wrsq(var_amp_flt,var_bin_flt,weight);
                  
                  pfm(ici).(indvar_name{ivar}).(bintype{its}).mrsq(ivar1,ivar2)=mrsq;
                  pfm(ici).(indvar_name{ivar}).(bintype{its}).mr(ivar1,ivar2)=mr;
                  pfm(ici).(indvar_name{ivar}).(bintype{its}).rsq(ivar1,ivar2)=rsq;
                  pfm(ici).(indvar_name{ivar}).(bintype{its}).mpath_bin(ivar1,ivar2)=mean(var_bin_flt);
                  
               end

            end
         end
      end
   end
%end
save([nikki '_' mconfig '_pfm.mat'],'pfm');

%% plot
fldnms=fieldnames(pfm(ici).(indvar_name{ivar}).(bintype{its}));
fldnms=fldnms(1:end-1);

close all
%for iconf=1%:length(mconfig_ls)
   vars=1;
   vare=length(indvar_name);
   for ici=1:length(case_interest)
      icase=case_interest(ici);
      for ifn=2%1:length(fldnms)
         for ivar=vars:vare
            %%
            figure(ifn)
            tl=tiledlayout(4,4);
            for its=1:length(bintype)
               nexttile(its*2+3,[3 2])
               nanimagesc(pfm(ici).(indvar_name{ivar}).(bintype{its}).(fldnms{ifn}))
               cb=colorbar;
               title(upper(bintype{its}),'FontWeight','normal')
               xticks(1:length(var2_str))
               yticks(1:length(var1_str))
               xticklabels(extractAfter(var2_str,lettersPattern))
               yticklabels(extractAfter(var1_str,lettersPattern))
               set(gca,'FontSize',16)
               
               if strcmp(fldnms{ifn},'mr')
                  colormap(BrBG)
                  set(gca,'ColorScale','log')
                  caxis([.5 2])
%                   cb.Ticks=[.25 .5 1 2 4];
                 
                  mpath=pfm(ici).(indvar_name{ivar}).(bintype{its}).mpath_bin;
                  [XX,YY]=meshgrid(1:length(var2_str),1:length(var1_str));
                  mpath_bin_str=sprintfc('%0.3g',mpath);

                  if strcmp(indvar_name{ivar}, 'mean_surface_ppt')
                     idx_ignore=mpath<0.01;
                     mpath_bin_str(idx_ignore)={' '};
                  end

                  for ivar1=1:length(var1_str)
                     for ivar2=1:length(var2_str)
                        
                        % ----- get text color -----
                        ngrads=size(coolwarm_r,1);
                        clr_idx=roundfrac(pfm(ici).(indvar_name{ivar}).(bintype{its}).rsq(ivar1,ivar2),1/ngrads)*ngrads;
                        clr_idx=round(clr_idx); % in case prev line outputs double
                        % ----- got text color -----
                        
                        if isnan(clr_idx) continue, end
                        if clr_idx==0 clr_idx=1; end
                        
                        text(ivar2+0.015,ivar1-0.015,mpath_bin_str{ivar1,ivar2},'FontSize',15,...
                           'HorizontalAlignment','center',...
                           'Color',coolwarm_r(clr_idx,:)*.1,'FontName','Menlo')
                        text(ivar2,ivar1,mpath_bin_str{ivar1,ivar2},'FontSize',15,...
                           'HorizontalAlignment','center',...
                           'Color',coolwarm_r(clr_idx,:),'FontName','Menlo')
                        
                        
                     end
                  end
%                elseif strcmp(fldnms{ifn},'rsq')
%                   colormap(coolwarm_r)
%                   set(gca,'ColorScale','lin')
%                   caxis([0 1])
%                elseif strcmp(fldnms{ifn},'mrsq')
%                   colormap(coolwarm_r)
%                   set(gca,'ColorScale','lin')
%                   caxis([-1 1])
               end
               
            end
            
            nexttile(2,[1,2])
%             imagesc()
            set(gca,'Color','none')
            set(gca,'XColor','none')
            set(gca,'YColor','none')
%             ax=gca;
            colormap(gca,coolwarm_r)
            cb=colorbar('southoutside');
            cb.Label.String='R^2';
            cb.Label.Position=[0.5000 3.3 0];
            set(gca,'FontSize',16)

            xlabel(tl,'Max vertical velocity [m/s]','fontsize',16)
            ylabel(tl,['Aerosol concentration [1/cc]' repelem(' ',23)],'fontsize',16)
            
            title(tl,[indvar_ename{ivar} indvar_units{ivar} ...
%                ' - ' (fldnms{ifn})...
               ],'fontsize',20,'fontweight','bold')
            saveas(figure(ifn),[plot_dir 'summ ' ...
               (indvar_ename{ivar}) ' ' fldnms{ifn}...
               ' ' case_list_str{icase} '.png'])
            pause(.5)
         end
      end
      
   end
%end
