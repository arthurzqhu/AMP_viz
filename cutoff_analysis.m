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

   lwc = bin_struct{its}.diagM3_liq;
   cutoff_summ.(var1_str{ivar1}).(var2_str{ivar2}).(bintype{its}).time = time;
   cutoff_summ.(var1_str{ivar1}).(var2_str{ivar2}).(bintype{its}).z = z;

   for itime=1:length(time)
      for iz=1:length(z)
         dsd_mass=bin_struct{its}.mass_dist(itime,1:nbins,iz);
         bc = get_bimocoeff(dsd_mass,binmean);
         % ignore dists that has too little water or are unimodal
         if bc > 5/9 && lwc(itime,iz) > lwc_mr_th(1)
            cutoff_summ.(var1_str{ivar1}).(var2_str{ivar2}).(bintype{its}).D_cutoff(itime,iz) = ...
               binmean(find_cutoff(dsd_mass));
            % cutoff_summ{ivar1,ivar2,its}(itime,iz)=binmean(find_cutoff(dsd_mass));
         else
            cutoff_summ.(var1_str{ivar1}).(var2_str{ivar2}).(bintype{its}).D_cutoff(itime,iz) = nan;
            % cutoff_summ{ivar1,ivar2,its}(itime,iz)=nan;
         end
      end
   end
end
end
end

save('cutoff_summ.mat','cutoff_summ')
