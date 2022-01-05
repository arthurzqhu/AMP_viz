clear 
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set %#ok<*NUSED>


vnum='0001'; % last four characters of the model output file.
nikki='2021-10-18';
run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir=dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags=[mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2)=0; % ignore the current and parent dir
mconfig_ls={mconfig_ls_dir(mconfig_ls_dir_flags).name};

iconf=1;
mconfig=mconfig_ls{iconf};
run case_dep_var.m
col=log(2)/3;

%% plot
close all
for its=1%:length(bintype)
   for ivar1=1%:length(var1_str)
      for ivar2=1%:length(var2_str)
         
         [~, ~, ~, ~, amp_struct]=loadnc('amp');
         [~, ~, ~, ~, bin_struct]=loadnc('bin');
         
         
         time = amp_struct.time;
         z = amp_struct.z;
         amp_DSDprof = amp_struct.mass_dist_init;
         bin_DSDprof = bin_struct.mass_dist;
         bin_DSDprof(2:end,:,:)=bin_DSDprof(1:end-1,:,:);
         
         if strcmpi(bintype{1},'sbm')
            binmean = load('diamg_sbm.txt');
            binmass = load('meanm_sbm.txt');
            amp_DSDprof=amp_DSDprof(:,1:length(binmean),:);
            bin_DSDprof=bin_DSDprof(:,1:length(binmean),:);
         elseif strcmpi(bintype{1},'tau')
            binmean = load('diamg_tau.txt');
            binmass = load('meanm_tau.txt');
         end
         
         % fig
         
         for itime=1:length(time)
            for iz=1:length(z)
               amp_mean_diag(itime,iz)=wmean(binmean,amp_DSDprof(itime,:,iz));
               bin_mean_diag(itime,iz)=wmean(binmean,bin_DSDprof(itime,:,iz));
               amp_mass_bt(itime,iz)=sum(amp_DSDprof(itime,:,iz)'./binmass.*(binmean.^3*col*pi/6*1000));
               bin_mass_bt(itime,iz)=sum(bin_DSDprof(itime,:,iz)'./binmass.*(binmean.^3*col*pi/6*1000));
            end 
         end
         
%          plot(time,amp_mean_diag(:,1),time,bin_mean_diag(:,1),'LineWidth',2)
%          yyaxis right
%          plot(time,amp_mass_bt(:,1),time,bin_mass_bt(:,1),'LineWidth',2)
         
%          amp_mass_bt=sum(amp_DSDprof(it_runidx,:,1)'./binmass.*(binmean.^3*col*pi/6*1000));
%          bin_mass_bt=sum(bin_DSDprof(it_runidx,:,1)'./binmass.*(binmean.^3*col*pi/6*1000));
         
         
         
         % anim
         time_step=5;
         time_length=floor(length(time)/time_step);
         
         F(time_length+1) = struct('cdata',[],'colormap',[]);
         for it=1:time_length+1
            
            it_runidx = (it-1)*time_step;
            if it_runidx>length(time) it_runidx=length(time); end
            if it_runidx<1 it_runidx=1; end
            itime = time(it_runidx);
            
            semilogx(binmean,amp_DSDprof(it_runidx,:,1),...
               'LineWidth',1,...
               'DisplayName','AMP'); hold on
            semilogx(binmean,bin_DSDprof(it_runidx,:,1),...
               'LineWidth',1,...
               'DisplayName','BIN')
            legend('show')
            
            amp_mass=sum(amp_DSDprof(it_runidx,:,1)'./binmass.*(binmean.^3*col*pi/6*1000));
            bin_mass=sum(bin_DSDprof(it_runidx,:,1)'./binmass.*(binmean.^3*col*pi/6*1000));
            
            annotation('textbox',[.67 .77 .23 .05],'String', ...
               ['AMP mass ' num2str(amp_mass)])
            annotation('textbox',[.67 .72 .23 .05],'String', ...
               ['BIN mass ' num2str(bin_mass)])
            hold off
            
            title(['t=' num2str(itime) 's'])
            F(it)=getframe(gcf);
            
            delete(findall(gcf,'type','annotation'))
            
         end
         saveVid(F,[mconfig ' ' bintype{its} ' ' var1_str{ivar1} ' ' ...
            var2_str{ivar2}], 10)
         
      end
   end
end
