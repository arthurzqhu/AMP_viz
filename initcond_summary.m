clear
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
%nikkis={'2021-09-22','2021-10-07','2021-10-11','2021-10-12',...
%         '2021-10-14','2021-10-16','2021-10-27','2021-10-28','2021-10-29',...
%         '2021-11-04','2021-11-05','2021-11-06','2021-11-08','2021-11-09',...
%         '2021-11-10','2021-11-12','2021-11-15'};
nikkis={'2022-01-05'};
%case_interest=1; % 1:length(case_list_num);

for ink=1:length(nikkis)
   nikki=nikkis{ink}
   
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
   for iconf=1%length(mconfig_ls)
      pfm=struct;
      mconfig=mconfig_ls{iconf}
      %     mconfig='adv_coll';
      run case_dep_var.m
      for its=1:length(bintype)
         for ivar1=1:length(var1_str)
            %             close all
            for ivar2=1:length(var2_str)
               %                 close all
               [its,ivar1,ivar2]
               [~, ~, ~, ~, amp_struct]=...
                  loadnc('amp');
               [~, ~, ~, ~, bin_struct]=...
                  loadnc('bin');
             %     'pause'
             %     pause
%               for ici=1:length(case_interest)
%                  icase=case_interest(ici);
                  
   
                  % indices of vars to compare
               vars=1;
               vare=length(indvar_name);
   
               time=amp_struct.time;
               z=amp_struct.z;
               for ivar=vars:vare
                  if strcmp(indvar_name{ivar},'mean_surface_ppt') && ~contains(mconfig,{'fullmic','sed'})
                     continue
                  elseif strcmp(indvar_name{ivar},'albedo') && ~contains(mconfig,{'fullmic'})
                     continue
                  elseif contains(indvar_name{ivar},'rain') && contains(mconfig,{'condnuc_noinit'})
                     continue
                  elseif contains(indvar_name{ivar},'cloud') && contains(mconfig,{'sedonly'})
                     continue
                  end
   
                  var_comp_raw_amp=amp_struct.(indvar_name{ivar});
                  var_amp_flt=var2phys(var_comp_raw_amp,ivar,0,1);
                  
                  var_comp_raw_bin=bin_struct.(indvar_name{ivar});
                  var_bin_flt=var2phys(var_comp_raw_bin,ivar,0,1);
                  
                  % get the non-nan indices for both bin and amp
                  vidx=~isnan(var_amp_flt+var_bin_flt);
                  nzidx=var_amp_flt.*var_bin_flt>0;
                  
                  weight=var_bin_flt(vidx)/sum(var_bin_flt(vidx));
                  weight_log=log(var_bin_flt(vidx))/sum(log(var_bin_flt(vidx)));
                  
                  [mr,rsq,er]=wrsq(var_amp_flt,var_bin_flt,weight);
                  
                  %pfm(ici).(indvar_name{ivar}).(bintype{its}).mrsq(ivar1,ivar2)=mrsq;
                  pfm.(indvar_name{ivar}).(bintype{its}).mr(ivar1,ivar2)=mr;
                  pfm.(indvar_name{ivar}).(bintype{its}).rsq(ivar1,ivar2)=rsq;
                  pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin(ivar1,ivar2)=nanmean(var_bin_flt);
                  pfm.(indvar_name{ivar}).(bintype{its}).mpath_amp(ivar1,ivar2)=nanmean(var_amp_flt);
                  pfm.(indvar_name{ivar}).(bintype{its}).er(ivar1,ivar2)=er;
                  
               end % ivar

            end
         end
      end
      save(['pfm_summary/' nikki '_' mconfig '_pfm.mat'],'pfm');


%% plot
      tmpvarname=fieldnames(pfm(1));
      fldnms=fieldnames(pfm(1).(tmpvarname{1}).(bintype{1}));
      fldnms=fldnms(1:end-1);
      
      close all
      vars=1;
      vare=length(indvar_name);
      for ifn=1%1:length(fldnms)
         for ivar=vars:vare
            if strcmp(indvar_name{ivar},'mean_surface_ppt') && ~contains(mconfig,{'fullmic','sed'})
               continue
            elseif strcmp(indvar_name{ivar},'albedo') && ~contains(mconfig,{'fullmic'})
               continue
            elseif contains(indvar_name{ivar},'rain') && contains(mconfig,{'condnuc_noinit'})
               continue
            elseif contains(indvar_name{ivar},'cloud') && contains(mconfig,{'sedonly'})
               continue
            end
            %%
            figure(ifn)
            tl=tiledlayout(4,4);
            for its=1:length(bintype)
               nexttile(its*2+3,[3 2])
               nanimagesc(pfm.(indvar_name{ivar}).(bintype{its}).(fldnms{ifn}))
               cb=colorbar;
               if its==length(bintype), cb.Label.String='AMP/bin'; end
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
   %                cb.Ticks=[.25 .5 1 2 4];
                 
                  mpath=pfm.(indvar_name{ivar}).(bintype{its}).mpath_bin;
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
                        clr_idx=roundfrac(pfm.(indvar_name{ivar}).(bintype{its}).rsq(ivar1,ivar2),1/ngrads)*ngrads;
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
   %             elseif strcmp(fldnms{ifn},'rsq')
   %                colormap(coolwarm_r)
   %                set(gca,'ColorScale','lin')
   %                caxis([0 1])
   %             elseif strcmp(fldnms{ifn},'mrsq')
   %                colormap(coolwarm_r)
   %                set(gca,'ColorScale','lin')
   %                caxis([-1 1])
               end
               
            end
            
            nexttile(2,[1,2])
   %          imagesc()
            set(gca,'Color','none')
            set(gca,'XColor','none')
            set(gca,'YColor','none')
   %          ax=gca;
            colormap(gca,coolwarm_r)
            cb=colorbar('southoutside');
            cb.Label.String='R^2';
            cb.Label.Position=[0.5000 3.3 0];
            set(gca,'FontSize',16)
   
            xlab_key=extractBefore(var2_str,digitsPattern);
            ylab_key=extractBefore(var1_str,digitsPattern);
            xlab=[initVarName_dict(xlab_key{1}) ' [' initVarUnit_dict(xlab_key{1}) ']'];
            ylab=[initVarName_dict(ylab_key{1}) ' [' initVarUnit_dict(ylab_key{1}) ']'];
            xlabel(tl,xlab,'fontsize',16)
            ylabel(tl,ylab,'fontsize',16)
            %ylabel(tl,[ylab repelem(' ',23)],'fontsize',16)
            
            title(tl,[indvar_ename{ivar} indvar_units{ivar} ...
   %             ' - ' (fldnms{ifn})...
               ],'fontsize',20,'fontweight','bold')
            saveas(figure(ifn),[plot_dir ' summ ' ...
               (indvar_ename{ivar}) ' ' fldnms{ifn}...
               '.png'])
            pause(.5)
         end
      end


   end

end
%end
%return

      
%   end
%end
