clear
clear global
close all

global mconfig ivar2 ivar1 its nikki output_dir vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set %#ok<*NUSED>

vnum='0001';
nikki='2021-11-27';

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir=dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags=[mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2)=0; % ignore the current and parent dir
mconfig_ls={mconfig_ls_dir(mconfig_ls_dir_flags).name};

set(0, 'DefaultFigurePosition',[1834 591 747 386])

%%

% fig_prof=figure('visible','off');
% fig_path=figure('visible','off');
% fig_proc=figure('visible','off');
% fig_profdiff=figure('visible','off');
% fig_pathdiff=figure('visible','off');
% fig_procdiff=figure('visible','off');

% creating structures for performance analysis based on Rsq and ratio
pfm=struct;

for iconf=7%:length(mconfig_ls)
   mconfig=mconfig_ls{iconf}
   %     mconfig='adv_coll';
   run case_dep_var.m
   
   for ivar1=1:length(var1_str)
      %             close all
      for ivar2=1:length(var2_str)
         %                 close all
         [ivar1 ivar2]
         its=1;
         [~, ~, ~, ~, tau_struct]=...
            loadnc('bin');
         
         its=2;
         [~, ~, ~, ~, sbm_struct]=...
            loadnc('bin');
         
         %             pause
         
         % indices of vars to compare
         vars=1;
         vare=length(indvar_name);
         
         % plot
         time=tau_struct.time;
         z=tau_struct.z;
         for ivar=vars:vare
            var_comp_raw_tau=tau_struct.(indvar_name{ivar});
            var_tau_flt=var2phys(var_comp_raw_tau,ivar,0,1);
            
            var_comp_raw_sbm=sbm_struct.(indvar_name{ivar});
            var_sbm_flt=var2phys(var_comp_raw_sbm,ivar,0,1);
            
            % get the non-nan indices for both bin and amp
            vidx=~isnan(var_tau_flt+var_sbm_flt);
            nzidx=var_tau_flt.*var_sbm_flt>0;
            
            weight=var_sbm_flt(vidx)/sum(var_sbm_flt(vidx));
            weight_log=log(var_sbm_flt(vidx))/sum(log(var_sbm_flt(vidx)));
            
            [mr,rsq,er]=wrsq(var_tau_flt,var_sbm_flt,weight);
            
            pfm.(indvar_name{ivar}).mr(ivar1,ivar2)=mr;
            pfm.(indvar_name{ivar}).rsq(ivar1,ivar2)=rsq;
            pfm.(indvar_name{ivar}).mpath_sbm(ivar1,ivar2)=mean(var_sbm_flt);
            pfm.(indvar_name{ivar}).mpath_tau(ivar1,ivar2)=mean(var_tau_flt);
            pfm.(indvar_name{ivar}).er(ivar1,ivar2)=er;
            
         end
          
      end
   end
end
save(['pfm_summary/' nikki '_' mconfig '_pfm_bincomp.mat'],'pfm');


%% plot
fldnms=fieldnames(pfm.(indvar_name{ivar}));
fldnms=fldnms(1:end-1);

close all
for iconf=7%:length(mconfig_ls)
   vars=1;
   vare=length(indvar_name);
   for ifn=1%1:length(fldnms)
      for ivar=vars:vare
         %%
         figure(ifn)
         tl=tiledlayout(4,1);
         
         nexttile(2,[3 1])
         nanimagesc(pfm.(indvar_name{ivar}).(fldnms{ifn}))
         colorbar
         title('TAU dev. from SBM','FontWeight','normal')
         xticks(1:length(var2_str))
         yticks(1:length(var1_str))
         xticklabels(extractAfter(var2_str,'w'))
         yticklabels(extractAfter(var1_str,'a'))
         set(gca,'FontSize',16)
         
         if strcmp(fldnms{ifn},'mr')
            colormap(BrBG)
            set(gca,'ColorScale','log')
            caxis([.5 2])
            
            [XX,YY]=meshgrid(1:length(var2_str),1:length(var1_str));
            mpath_sbm_str=sprintfc('%0.3g',...
               pfm.(indvar_name{ivar}).mpath_sbm);
            for ivar1=1:length(var1_str)
               for ivar2=1:length(var2_str)
                  
                  % ----- get text color -----
                  ngrads=size(coolwarm_r,1);
                  clr_idx=roundfrac(pfm.(indvar_name{ivar}).rsq(ivar1,ivar2),1/ngrads)*ngrads;
                  clr_idx=round(clr_idx); % in case prev line outputs double
                  % ----- got text color -----
                  
                  if isnan(clr_idx) continue, end
                  if clr_idx==0 clr_idx=1; end
                  
                  text(ivar2+0.02,ivar1-0.02,mpath_sbm_str{ivar1,ivar2},'FontSize',15,...
                     'HorizontalAlignment','center',...
                     'Color',coolwarm_r(clr_idx,:)*.1,'FontName','Menlo')
                  text(ivar2,ivar1,mpath_sbm_str{ivar1,ivar2},'FontSize',15,...
                     'HorizontalAlignment','center',...
                     'Color',coolwarm_r(clr_idx,:),'FontName','Menlo')
                  
                  
               end
            end
         end
         
         nexttile(1)
         set(gca,'Color','none')
         set(gca,'XColor','none')
         set(gca,'YColor','none')
         colormap(gca,coolwarm_r)
         cb=colorbar('southoutside');
         cb.Label.String='R^2';
         cb.Label.Position=[0.5000 3.3 0];
         set(gca,'FontSize',16)

         xlab_key=extractBefore(var2_str,digitsPattern);
         ylab_key=extractBefore(var1_str,digitsPattern);
         xlab=[initVarName_dict(xlab_key{1}) initVarUnit_dict(xlab_key{1})];
         ylab=[initVarName_dict(ylab_key{1}) initVarUnit_dict(ylab_key{1})];
         xlabel(tl,xlab,'fontsize',16)
         ylabel(tl,ylab,'fontsize',16)
         
         title(tl,[indvar_ename{ivar} indvar_units{ivar} ...
            ],'fontsize',20,'fontweight','bold')
         saveas(figure(ifn),[plot_dir ' summ ' mconfig_ls{iconf} ' ' ...
            (indvar_ename{ivar}) ' ' fldnms{ifn}...
            ' bin.png'])
         pause(.5)
      end
   end
end
