clear
clear global
close all

load('cutoff_summ')

var1_str = fieldnames(cutoff_summ);
var2_str = fieldnames(cutoff_summ.(var1_str{1}));
bintype = fieldnames(cutoff_summ.(var1_str{1}).(var2_str{1}));

for ivar1 = 1:length(var1_str)
   for ivar2 = 1:length(var2_str)
      for its = 1:length(bintype)
         disp([ivar1 ivar2 its])
         time = cutoff_summ.(var1_str{ivar1}).(var2_str{ivar2}).(bintype{its}).time;
         z = cutoff_summ.(var1_str{ivar1}).(var2_str{ivar2}).(bintype{its}).z;
         D_cutoff = cutoff_summ.(var1_str{ivar1}).(var2_str{ivar2}).(bintype{its}).D_cutoff;
         nanimagesc(time,z,D_cutoff*1e6)
         cb = colorbar;
         cb.Label.String = 'Diameter cutoff [\mum]';
         set(gca,'colorscale','log')
         saveas(gcf,['plots/cutoff_analysis/', var1_str{ivar1}, var2_str{ivar2}, bintype{its},...
            '.png'])
      end
   end
end

