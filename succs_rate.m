clear
clear global
close all

global mconfig ivar2 ivar1 its ici nikki output_dir case_list_str vnum ...
   bintype var1_str var2_str indvar_name indvar_name_set ...
   indvar_ename indvar_ename_set indvar_units indvar_units_set %#ok<*NUSED>

vnum='0001'; % last four characters of the model output file.
nikki='2021-10-07';
case_interest=2; % 1:length(case_list_num);

run global_var.m

% get the list of configs. cant put it into globar_var
mconfig_ls_dir=dir([output_dir,nikki,'/']);
mconfig_ls_dir_flags=[mconfig_ls_dir.isdir];
mconfig_ls_dir_flags(1:2)=0; % ignore the current and parent dir
mconfig_ls={mconfig_ls_dir(mconfig_ls_dir_flags).name};

set(0, 'DefaultFigurePosition',[1331 587 1250 390])

%%

iconf=2;
mconfig=mconfig_ls{iconf};

run case_dep_var.m

for its=1:length(bintype)
   for ivar1=1:length(var1_str)
      for ivar2=1:length(var2_str)

         [~, ~, ~, ~, amp_struct]=loadnc('amp',case_interest);


         flagc=amp_struct.oflagc;
         flagr=amp_struct.oflagr;
         success_rate_c(its,ivar1,ivar2)=sum(flagc(:)==0)/sum(flagc(:)>=0);
         success_rate_r(its,ivar1,ivar2)=sum(flagr(:)==0)/sum(flagr(:)>=0);

      end
   end
end

%%
close all

figure('Position',[1331 333 1250 644])
tl=tiledlayout(2,2);
   
for its=1:length(bintype)
   
   
   nexttile(its)
   nanimagesc(squeeze(success_rate_c(its,:,:)))
   xticklabels(extractAfter(var2_str,1))
   yticklabels(extractAfter(var1_str,1))
   set(gca,'FontSize',16)
   title(['AMP-' upper(bintype{its}) ' cloud success rate'])
   colorbar
   colormap(parula(10))
   caxis([.9 1])
   
   nexttile(its+2)
   nanimagesc(squeeze(success_rate_r(its,:,:)))
   xticklabels(extractAfter(var2_str,1))
   yticklabels(extractAfter(var1_str,1))
   set(gca,'FontSize',16)
   title(['AMP-' upper(bintype{its}) ' rain success rate'])
   colorbar
   colormap(parula(10))
   caxis([.9 1])
   
end

save([nikki '_' mconfig '_success_rate.mat'],'success_rate_c','success_rate_r');
% saveas(gcf,[plot_dir 'success rate comparison.png'])