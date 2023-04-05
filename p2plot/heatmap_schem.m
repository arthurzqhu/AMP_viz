clearvars -except cmaps
clear global
close all

global mconfig

nikki = 'conftest';
global_var

% as opposed to mean ratio. should be set between 0 and 1. 0.5 means rsq and mr are equally important
rsq_importance = 0.5; 

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);

mconfig = mconfig_ls{1};
load('score_summary/scores_conftest.mat')
case_dep_var

indvar_name = fieldnames(score_trim(1).tau);
name_idx = contains(indvar_name_all,indvar_name);
indvar_ename = indvar_ename_all(name_idx);
indvar_units = indvar_units_all(name_idx);
its = 1;

var2plot = 4;

nvar1 = size(score_trim(1).(bintype{1}).(indvar_name{1}),1);
nvar2 = size(score_trim(1).(bintype{1}).(indvar_name{1}),2);
ncase = length(score_trim);

% combine the separate score matrices into 1 3D matrix
% EXCEPT slice() doesn't show the color at the grid edge like imagesc()
% but instead automatically take the mean and show the color at the center
% of the grid. So need to do some reverse-interpolation first...

for icase = 1:ncase
   score3d(:,icase,:) = score_trim(icase).(bintype{its}).(indvar_name{var2plot});
end

% Calculate the dimensions of the new matrix
new_nvar1 = nvar1 + 1;
new_ncase = ncase + 1;
new_nvar2 = nvar2 + 1;

% Create the new matrix
new_score3d = zeros(new_nvar1, new_ncase, new_nvar2);

% Copy the original data into the new matrix
new_score3d(1:nvar1, 1:ncase, 1:nvar2) = score3d;

% Calculate the averages for each 2x2 chunk
for i = 1:new_nvar1-1
    for j = 1:new_ncase-1
        for k = 1:new_nvar2-1
            new_score3d(i:i+1, j:j+1, k:k+1) = mean(mean(mean(score3d(i:i+1-1, j:j+1-1, k:k+1-1))));
        end
    end
end

[X,Y,Z] = meshgrid(0:ncase, 0:nvar1, 0:nvar2);
xslice = [0 3 6 ncase];
yslice = [];
zslice = [];

figure('position',[0 0 1000 400])
s = slice(X,Y,Z,new_score3d,xslice,yslice,zslice,'linear');
% set(s,'EdgeColor','none');
caxis([.5 1])
colormap(gca,cmaps.magma_r)
cb = colorbar;
cb.Label.String = 'Similarity Score';
xlim([0 ncase+1])
ylim([0 nvar1+1])
zlim([0 nvar2+1])
yticks([.5:nvar1-.5])
yticklabels(momcombo_trimmed)
zticks([.5:nvar2-.5])
zticklabels(extractAfter(var2_str,lettersPattern))
set(gca,'ydir','reverse')
set(gca,'xcolor','none')
ylabel('Predicted Moments','rotation',-11)
zlabel('Assumed Shape Parameter')
set(gca,'fontsize',12)
grid off

% put some texts for better illustration
annotation('textbox',[.16 .45 .3 .3],'String','+','LineStyle','none','FontSize',20)
annotation('textbox',[.238 .476 .3 .3],'String','+','LineStyle','none','FontSize',20)
annotation('textbox',[.316 .502 .3 .3],'String','+','LineStyle','none','FontSize',20)
annotation('textbox',[0.3955 .54 .3 .3],'String','...','LineStyle','none','FontSize',20)
annotation('textbox',[.475 .565 .3 .3],'String','+','LineStyle','none','FontSize',20)

% put in the similarity score equation
hold on
plot3([0 0 0 0 0]+6, [0 1 1 0 0]+1, [0 0 1 1 0]+5, 'color', [.5 .5 .5], 'LineWidth', 2)
plot3([6 6], [1.5 1.5], [6 7], 'color', [.5 .5 .5], 'LineWidth', 2)
hold off

annotation('textbox',[.17 .815 .245 .05],'String',...
   '$$Similarity\ Score=a(1-|log(MR)|)+bR_0^2$$',...
   'Interpreter','latex','fontsize',12,'EdgeColor',[.5 .5 .5],'LineWidth',2)

exportgraphics(gcf,'plots/p2/heatmap_schem.pdf')
