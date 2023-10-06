clear
clear global
close all

global ivar1 ivar2 its nikki mconfig output_dir vnum ...
   bintype var1_str var2_str indvar_name_set indvar_name ...
   indvar_units indvar_ename indvar_ename_set indvar_units_set ...
   casenum split_bins col binmean cloud_mr_th rain_mr_th

nikki = 'fullmic_kid';
global_var

mconfig='';
case_dep_var

for ivar1=1:length(var1_str)
for ivar2=1:length(var2_str)
   disp([ivar1,ivar2])
for its = 1:2

   bin_struct{its} = loadnc('bin');

   if its==2
      binmean = load('diamg_sbm.txt')';
      nbins=33;
   elseif its==1
      binmean = load('diamg_tau.txt')';
      nbins=34;
   end
   z=bin_struct{its}.z;
   time=bin_struct{its}.time;

   for itime=1:length(time)
      for iz=1:length(z)
         dsd_mass=bin_struct{its}.mass_dist(itime,1:nbins,iz);
         % determine whether the distribution is bimodal
         cutoff_summ{ivar1,ivar2,its}(itime,iz)=binmean(find_cutoff(dsd_mass));
      end
   end
end
end
end

save('cutoff_summ.mat','cutoff_summ')
