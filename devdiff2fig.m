function devdiff2fig(dev1, dev2)

global indvar_name_set indvar_name_all indvar_ename_all color_order

fldnms = fieldnames(dev1);
ivarplot = find(contains(fldnms, indvar_name_set));
ivarset = contains(indvar_name_all, fldnms(ivarplot));
Y1_mat = reshape(struct2array(dev1), [], length(fieldnames(dev1)))';
Y1 = Y1_mat(ivarplot, :);
Y2_mat = reshape(struct2array(dev2), [], length(fieldnames(dev2)))';
Y2 = Y2_mat(ivarplot, :);

Xc = indvar_ename_all(ivarset);
Xc(contains(Xc, 'cloud water path')) = {'CWP'};
Xc(contains(Xc, 'rain water path')) = {'RWP'};
Xc(contains(Xc, 'cloud number')) = {'N_c'};
Xc(contains(Xc, 'rain number')) = {'N_r'};
Xc(contains(Xc, 'mean surface pcpt.')) = {'MSP'};
Xc(contains(Xc, 'liquid water path')) = {'LWP'};
% Xc(contains(Xc, 'cloud half-life')) = {'t_{1/2, c}'};
X = categorical(Xc);
X = reordercats(X, Xc);

%%
hold on
b = bar(X, (abs(Y2-1)-abs(Y1-1))*100, 1);
b(1).FaceColor = color_order{1};
b(2).FaceColor = color_order{2};
b(1).FaceAlpha = 0.75;
b(2).FaceAlpha = 0.75;
b(1).LineWidth = 1;
b(2).LineWidth = 1;
b(1).BaseLine.Color = [.8 .8 .8];

hold off
ylim([-15 15])
grid()
set(gca,'fontsize',12)
