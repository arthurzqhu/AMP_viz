clear
close all
clear global
global indvar_name_set indvar_name_all indvar_ename_all %#ok<*NUSED>


condonly_dev=devfun(load('pfm_summary/2021-11-27_condnuc_noinit_pfm.mat').pfm);
collonly_dev=devfun(load('pfm_summary/2022-02-24_collonly_pfm.mat').pfm);
evaponly_dev=devfun(load('pfm_summary/2022-01-25_evaponly_cloud_pfm.mat').pfm);
sedonly_dev=devfun(load('pfm_summary/2022-02-04_sedonly_i_pfm.mat').pfm);

collsed_dev=devfun(load('pfm_summary/2021-11-23_collsed_pfm.mat').pfm);
condcoll_dev=devfun(load('pfm_summary/2021-11-27_condcoll_pfm.mat').pfm);
evapsed_dev=devfun(load('pfm_summary/2021-11-27_evapsed_pfm.mat').pfm);

condcollsed_dev=devfun(load('pfm_summary/2021-11-27_condcollsed_pfm.mat').pfm);
collsedevap_dev=devfun(load('pfm_summary/2021-11-27_collsedevap_pfm.mat').pfm);

fullmic_dev=devfun(load('pfm_summary/2021-11-27_fullmic_pfm.mat').pfm);

echodemo('global_var',9);

%%
close all
figure('Position',[1013 59 1292 1134])
tl=tiledlayout(4,8,'TileSpacing','compact','Padding','compact');

% fullmic
nexttile(3,[1 4])
[X_fullmic,Y_fullmic]=dev2fig(fullmic_dev);
title('(a) Full MP','FontSize',16')

% condevapcoll
nexttile(11,[1 2])
[X_condevapcoll,Y_condevapcoll]=dev2fig(condcollsed_dev);
title('(b) Cond. Coll. Sed.','FontSize',16')


% evapsedcoll
nexttile(13,[1 2])
[X_rainshaft,Y_rainshaft]=dev2fig(collsedevap_dev);
title('(c) Evap. Coll. Sed.','FontSize',16')


% condcoll
nexttile(18,[1 2])
[X_condcoll,Y_condcoll]=dev2fig(condcoll_dev);
title('(d) Cond. Coll.','FontSize',16')


% collsed
nexttile(20,[1 2])
[X_collsed,Y_collsed]=dev2fig(collsed_dev);
title('(e) Coll. Sed.','FontSize',16')


% evapsed
nexttile(22,[1 2])
[X_evapsed,Y_evapsed]=dev2fig(evapsed_dev);
title('(f) Evap. Sed.','FontSize',16')


% cond
nexttile(25,[1 2])
[X_condonly,Y_condonly]=dev2fig(condonly_dev);
title('(g) Cond. (incl. Nucl.)','FontSize',16')


% coll
nexttile(27,[1 2])
[X_collonly,Y_collonly]=dev2fig(collonly_dev);
title('(h) Coll. only','FontSize',16')

% sed
nexttile(29,[1 2])
[X_sedonly,Y_sedonly]=dev2fig(sedonly_dev);
title('(i) Sed. only','FontSize',16')


% evap
nexttile(31,[1 2])
[X_evaponly,Y_evaponly]=dev2fig(evaponly_dev);
title('(j) Evap. only','FontSize',16')

ylabel(tl,'AMP-bin % difference','fontsize',20,...
   'fontweight','bold')


for iax = 1:10
   ax_pos{iax}=tl.Children(end+2-iax*2).Position;
end

ax_map={[2 3],[4 5],[5 6],[7 8],[8 9],[9 10]};
lsty={':',':','-.',':','-.','--'};
lclr={[0 0 0],[0 0 0],[.4 .4 .4],[0 0 0],[.4 .4 .4],[.4 .4 .4]};

for iax=1:6
   % left line
   x1=ax_pos{iax}(1);
   x2=ax_pos{ax_map{iax}(1)}(1);
   y1=ax_pos{iax}(2);
   y2=ax_pos{ax_map{iax}(1)}(2)+ax_pos{ax_map{iax}(1)}(4);
   annotation('line',[x1 x2], [y1 y2], ...
      'Color',lclr{iax}, ...
      'LineStyle',lsty{iax},'LineWidth',1);
   % right line
   x1=ax_pos{iax}(1)+ax_pos{iax}(3);
   x2=ax_pos{ax_map{iax}(2)}(1)+ax_pos{ax_map{iax}(2)}(3);
   y1=ax_pos{iax}(2);
   y2=ax_pos{ax_map{iax}(2)}(2)+ax_pos{ax_map{iax}(2)}(4);
   annotation('line',[x1 x2], [y1 y2], ...
      'Color',lclr{iax}, ...
      'LineStyle',lsty{iax},'LineWidth',1);
end

str={'CWP: cloud water path',...
   'RWP: rain water path',...
   'LWP: liquid water path',...
   'N_c: cloud droplet number',...
   'N_r: raindrop number',...
   't_{1/2,c}: cloud half-life',...
   'MSP: mean surface pcpt.'};

annotation('textbox',[0.77 0.54 0.19 0.41],'String', str,...
           'FitBoxToText','on','FontSize',14)
exportgraphics(gcf,['plots/p1/pyramid.jpg'],'Resolution',300)

%%
function [X,Y]=dev2fig(dev_strt)

global indvar_name_set indvar_name_all indvar_ename_all

fldnms=fieldnames(dev_strt);
ivarplot=find(contains(fldnms,indvar_name_set));
ivarset=contains(indvar_name_all,fldnms(ivarplot));
Y_mat=cell2mat(struct2cell(dev_strt));
Y=Y_mat(ivarplot,:);
% indv_abbr=indvar_ename_all(ivarset);
Xc=indvar_ename_all(ivarset);
Xc(contains(Xc,'cloud water path'))={'CWP'};
Xc(contains(Xc,'rain water path'))={'RWP'};
Xc(contains(Xc,'cloud number'))={'N_c'};
Xc(contains(Xc,'rain number'))={'N_r'};
Xc(contains(Xc,'mean surface pcpt.'))={'MSP'};
Xc(contains(Xc,'liquid water path'))={'LWP'};
Xc(contains(Xc,'cloud half-life'))={'t_{1/2,c}'};

X=categorical(Xc);
X=reordercats(X,Xc);



%%
b=bar(X,Y,1);
b(1).BaseValue=1;
b(1).BaseLine.Color=[.8 .8 .8];
set(gca,'YScale','log')
ylim([0.5 2])
grid
yticks([0.5 0.8 1 1.2 1.5 2 2.5])
yticklabels({'-50','-20','0','20','50','100','150'})

l=legend('TAU','SBM');
set(gca,'fontsize',16)
set(gca,'GridColor',[1 1 1])

end
