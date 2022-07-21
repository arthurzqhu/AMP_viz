function devdiff2fig(dev1, dev2)

global indvar_name_set indvar_name_all indvar_ename_all color_order

fldnms = fieldnames(dev1.mean_ratio);
ivarplot = find(contains(fldnms, indvar_name_set));
ivarset = contains(indvar_name_all, fldnms(ivarplot));
Y1_val_mat = reshape(struct2array(dev1.mean_ratio), [], length(fieldnames(dev1.mean_ratio)))';
Y2_val_mat = reshape(struct2array(dev2.mean_ratio), [], length(fieldnames(dev2.mean_ratio)))';
Y1_err_mat = reshape(struct2array(dev1.std_ratio), [], length(fieldnames(dev1.mean_ratio)))';
Y2_err_mat = reshape(struct2array(dev2.std_ratio), [], length(fieldnames(dev2.mean_ratio)))';
Y1_val = Y1_val_mat(ivarplot, :);
Y2_val = Y2_val_mat(ivarplot, :);
Y1_err = Y1_err_mat(ivarplot, :);
Y2_err = Y2_err_mat(ivarplot, :);

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
Y_val = (abs(Y2_val-1)-abs(Y1_val-1))+1;
b = bar(X, Y_val, 1);
b(1).FaceColor = color_order{1};
b(2).FaceColor = color_order{2};
b(1).FaceAlpha = 0.5;
b(2).FaceAlpha = 0.5;
b(1).LineWidth = 1;
b(2).LineWidth = 1;
b(1).BaseValue=1;
b(1).BaseLine.Color = [.8 .8 .8];

ypos = zeros(size(Y1_err));
yneg = zeros(size(Y1_err));
for i = 1:numel(Y1_err)
   if Y2_err(i) > Y1_err(i)
      ypos(i) = Y2_err(i) - Y1_err(i);
   else
      yneg(i) = Y1_err(i) - Y2_err(i);
   end
end

hold off
set(gca,'YScale','log')
ylim([0.4 2])
yticks([0.5 0.67 0.8 1 1.25 1.5 2])
yticklabels({'-50','-33','-20','0','+25','+50','+100'})

yyaxis right
hold on
barwidth = b(1).BarWidth;
erb = errorbar((1:length(X)) - barwidth/7, Y_val(:,1)*0+1, yneg(:,1), ypos(:,1), 'LineWidth', 2);
erb.Color = color_order{1};
erb.LineStyle = 'none';
erb = errorbar((1:length(X)) + barwidth/7, Y_val(:,2)*0+1, yneg(:,2), ypos(:,2), 'LineWidth', 2);
erb.Color = color_order{2};
erb.LineStyle = 'none';
set(gca,'YScale','log')
ylim([0.4 2])
yticks([])
set(gca,'ycolor',color_order{1})
hold off

grid()
set(gca,'fontsize',12)
