clear
clear global
close all

global mconfig iw ia its ici nikki output_dir case_list_str vnum ...
   bintype aero_N_str w_spd_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-09-21';
case_interest=2; % 1:length(case_list_num);

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

for iconf=1%:length(mconfig_ls)
   mconfig=mconfig_ls{iconf};
   %     mconfig='adv_coll';
   run case_dep_var.m
   
   for ia=1:length(aero_N_str)
      %             close all
      for iw=1:length(w_spd_str)
         %                 close all
         
         its=1;
         [~, ~, ~, ~, tau_struct]=...
            loadnc('bin',case_interest);
         
         its=2;
         [~, ~, ~, ~, sbm_struct]=...
            loadnc('bin',case_interest);
         
         %             pause
         
         % indices of vars to compare
         vars=1;
         vare=length(indvar_name);
         
         % plot
         for ici=case_interest
            time=tau_struct(ici).time;
            z=tau_struct(ici).z;
            for ivar=vars:vare
               
               var_comp_raw_tau=tau_struct(ici).(indvar_name{ivar});
               var_tau_flt=var2phys(var_comp_raw_tau,ivar,0,1);
               
               var_comp_raw_sbm=sbm_struct(ici).(indvar_name{ivar});
               var_sbm_flt=var2phys(var_comp_raw_sbm,ivar,0,1);
               
               % get the non-nan indices for both bin and amp
               vidx=~isnan(var_tau_flt+var_sbm_flt);
               nzidx=var_tau_flt.*var_sbm_flt>0;
               
               weight=var_sbm_flt(vidx)/sum(var_sbm_flt(vidx));
               weight_log=log(var_sbm_flt(vidx))/sum(log(var_sbm_flt(vidx)));
               
               [mrsq,mr,rsq]=wrsq(var_tau_flt,var_sbm_flt,weight);
               
               pfm(ici).(indvar_name{ivar}).mrsq(ia,iw)=mrsq;
               pfm(ici).(indvar_name{ivar}).mr(ia,iw)=mr;
               pfm(ici).(indvar_name{ivar}).rsq(ia,iw)=rsq;
               pfm(ici).(indvar_name{ivar}).mpath_sbm(ia,iw)=mean(var_sbm_flt);
               
            end
            
         end
      end
   end
end

%% plot
fldnms=fieldnames(pfm(ici).(indvar_name{ivar}));
fldnms=fldnms(1:end-1);

close all
for iconf=1%:length(mconfig_ls)
   vars=1;
   vare=length(indvar_name);
   for ici=case_interest
      for ifn=2%1:length(fldnms)
         for ivar=vars:vare
            %%
            figure(ifn)
            tl=tiledlayout(4,1);
            
            nexttile(2,[3 1])
            nanimagesc(pfm(ici).(indvar_name{ivar}).(fldnms{ifn}))
            colorbar
            title('TAU dev. from SBM','FontWeight','normal')
            xticks(1:length(w_spd_str))
            yticks(1:length(aero_N_str))
            xticklabels(extractAfter(w_spd_str,'w'))
            yticklabels(extractAfter(aero_N_str,'a'))
            set(gca,'FontSize',16)
            
            if strcmp(fldnms{ifn},'mr')
               colormap(BrBG)
               set(gca,'ColorScale','log')
               caxis([.5 2])
               
               [XX,YY]=meshgrid(1:length(w_spd_str),1:length(aero_N_str));
               mpath_sbm_str=sprintfc('%0.3g',...
                  pfm(ici).(indvar_name{ivar}).mpath_sbm);
               for ia=1:length(aero_N_str)
                  for iw=1:length(w_spd_str)
                     
                     % ----- get text color -----
                     ngrads=size(coolwarm_r,1);
                     clr_idx=roundfrac(pfm(ici).(indvar_name{ivar}).rsq(ia,iw),1/ngrads)*ngrads;
                     clr_idx=round(clr_idx); % in case prev line outputs double
                     % ----- got text color -----
                     
                     if isnan(clr_idx) continue, end
                     if clr_idx==0 clr_idx=1; end
                     
                     text(iw+0.02,ia-0.02,mpath_sbm_str{ia,iw},'FontSize',15,...
                        'HorizontalAlignment','center',...
                        'Color',coolwarm_r(clr_idx,:)*.1,'FontName','Menlo')
                     text(iw,ia,mpath_sbm_str{ia,iw},'FontSize',15,...
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

            xlabel(tl,'max vertical velocity [m/s]','fontsize',16)
            ylabel(tl,['aerosol concetration [1/cc]' repelem(' ',23)],'fontsize',16)
            
            title(tl,[indvar_ename{ivar} indvar_units{ivar} ...
%                ' - ' (fldnms{ifn})...
               ],'fontsize',20,'fontweight','bold')
            saveas(figure(ifn),[plot_dir 'summ ' mconfig_ls{iconf} ' ' ...
               (indvar_ename{ivar}) ' ' fldnms{ifn}...
               ' ' case_list_str{ici} ' bin.png'])
            pause(.5)
         end
      end
      
   end
end