clearvars -except cmaps
clear global
close all

global mconfig script_name

script_name = mfilename;

nikki = 'conftest_fullmic';
global_var

% get the list of configs. cant put it into globar_var
mconfig_ls = get_mconfig_list(output_dir,nikki);
nconf = length(mconfig_ls);

mconfig = mconfig_ls{1};
load([score_dir 'fullmic_scores_conftest.mat'])
case_dep_var

indvar_name = fieldnames(score_trim(1).tau);
name_idx = contains(indvar_name_all,indvar_name);
indvar_ename = indvar_ename_all(name_idx);
indvar_units = indvar_units_all(name_idx);
its = 1;

var2plot = 4;

nvar1 = size(score_trim(1).(bintype{1}).(indvar_name{1}),2);
nvar2 = size(score_trim(1).(bintype{1}).(indvar_name{1}),1);
ncase = length(score_trim);

% combine the separate score matrices into 1 3D matrix
% EXCEPT slice() doesn't show the color at the grid edge like imagesc()
% but instead automatically take the mean and show the color at the center
% of the grid. So need to do some reverse-interpolation first...

for icase = 1:ncase
   score3d(:,icase,:) = score_trim(icase).(bintype{its}).(indvar_name{var2plot});
end
score3d = permute(score3d, [3 2 1]);
score3d(isnan(score3d)) = 0;

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
            new_score3d(i:i+1, j:j+1, k:k+1) = nanmean(nanmean(nanmean(score3d(i:i+1-1, j:j+1-1, k:k+1-1))));
        end
    end
end

[X,Y,Z] = meshgrid(0:ncase, 0:nvar1, 0:nvar2);
xslice = [1 3 5 ncase-1];
yslice = [];
zslice = [];

figure('position',[0 0 1000 800])
s = slice(X,Y,Z,new_score3d,xslice,yslice,zslice,'linear');
% view(-25,30)
% set(s,'EdgeColor','none');
caxis([0 1])
colormap(gca,cmaps.magma_r)
cb = colorbar;
cb.Label.String = 'Similarity Score';
xlim([1 ncase+1])
ylim([0 nvar1+1])
zlim([0 nvar2+1])
yticks([.5:nvar1-.5])
yticklabels(sp_combo_str)
zticks([.5:nvar2-.5])
zticklabels(momcombo_trimmed)
set(gca,'ydir','reverse')
set(gca,'xcolor','none')
ylb=ylabel('Assumed Shape Parameters \nu_1-\nu_2','rotation',-25);
ylb.Position(2) = 13;
ylb.Position(3) = -3.5;
zlb=zlabel('Predicted Moments M_x-M_y');
set(gca,'fontsize',16)
grid off
title(['Illustration of composite heat map for ' indvar_ename{var2plot}],'fontsize',24)

% put some texts for better illustration
annotation('textbox',[.14 .48 .3 .3],'String','+','LineStyle','none','FontSize',20)
annotation('textbox',[.2 .496 .3 .3],'String','+','LineStyle','none','FontSize',20)
annotation('textbox',[.26 .512 .3 .3],'String','+','LineStyle','none','FontSize',20)
annotation('textbox',[.35 .536 .3 .3],'String','...','LineStyle','none','FontSize',20)
annotation('textbox',[.44 .56 .3 .3],'String','+','LineStyle','none','FontSize',20)

% put in the similarity score equation
hold on
plot3([0 0 0 0 0]+5, [0 1 1 0 0]+2, [0 0 1 1 0]+nvar2-1, 'color', [.5 .5 .5], 'LineWidth', 2)
plot3([5 5], [2.5 2.5], [nvar2 nvar2+5], 'color', [.5 .5 .5], 'LineWidth', 2)
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off
hold off

annotation('textbox',[.17 .85 .245 .05],'String',...
   '$$S=1-\frac{\sum(Q_{AMP}-Q_{BIN})^2}{\sum(Q_{BIN}-\overline{Q_{BIN}})^2}$$',...
   'Interpreter','latex','fontsize',12,'EdgeColor',[.5 .5 .5],'LineWidth',2,...
   'FitBoxToText','on')

exportgraphics(gcf,'plots/p2/f04_heatmap_schem.pdf')
saveas(gcf,'plots/p2/f04_heatmap_schem.fig')
