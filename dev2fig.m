function [X,Y_val]=dev2fig(dev_strt,dev_strt_a)

global indvar_name_set indvar_name_all indvar_ename_all color_order

fldnms=fieldnames(dev_strt.mean_ratio);
ivarplot=find(contains(fldnms,indvar_name_set));
ivarset=contains(indvar_name_all,fldnms(ivarplot));
Y_val_mat=reshape(struct2array(dev_strt.mean_ratio),[],length(fldnms))';
Y_err_mat=reshape(struct2array(dev_strt.std_ratio),[],length(fldnms))';
% Y_val_mat=cell2mat(struct2cell(dev_strt));
Y_val=Y_val_mat(ivarplot,:);
Y_err=Y_err_mat(ivarplot,:);
% Y_mat_a=reshape(struct2array(dev_strt_a.mean_ratio),[],length(fieldnames(dev_strt_a)))';
% Y_mat_a=cell2mat(struct2cell(dev_strt_a));
% Y_a=Y_mat_a(ivarplot,:);
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
hold on
b=bar(X,Y_val,1);
b(1).FaceColor=color_order{1};
b(2).FaceColor=color_order{2};
b(1).FaceAlpha=0.5;
b(2).FaceAlpha=0.5;
b(1).LineWidth=1;
b(2).LineWidth=1;
b(1).BaseValue=1;
b(1).BaseLine.Color=[.8 .8 .8];
barwidth = b(1).BarWidth;
yneg = 1-1./(1+Y_err(:,1));
ypos = Y_err(:,1);
erb = errorbar((1:length(X)) - barwidth/7, Y_val(:,1), yneg, ypos, 'LineWidth', 1);
erb.Color = color_order{1};
erb.LineStyle = 'none';
yneg = 1-1./(1+Y_err(:,2)); 
ypos = Y_err(:,2);
erb = errorbar((1:length(X)) + barwidth/7, Y_val(:,2), yneg, ypos, 'LineWidth', 1);
erb.Color = color_order{2};
erb.LineStyle = 'none';


% b_a=bar(X,Y_a,1);
% b_a(1).FaceColor=color_order{1};
% b_a(2).FaceColor=color_order{2};
% b_a(1).FaceAlpha=0.5;
% b_a(2).FaceAlpha=0.5;
% b_a(1).LineStyle=':';
% b_a(2).LineStyle=':';
% b_a(1).BaseValue=1;
% b_a(1).BaseLine.Color=[.8 .8 .8];

hold off

set(gca,'YScale','log')
ylim([0.5 2])
yticks([0.5 0.67 0.8 1 1.25 1.5 2])
yticklabels({'-50','-33','-20','0','+25','+50','+100'})
box on

grid()

set(gca,'fontsize',12)

end
