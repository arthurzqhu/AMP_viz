function devcomp2fig(dev_strt1,dev_strt2,dev_strt_bin)

global indvar_name_set indvar_name_all indvar_ename_all color_order

fldnms1=fieldnames(dev_strt1.mean_ratio);
fldnms2=fieldnames(dev_strt2.mean_ratio);
fldnms_bin=fieldnames(dev_strt_bin.mean_ratio);
ivarplot=find(contains(fldnms1,indvar_name_set));
ivarset=contains(indvar_name_all,fldnms1(ivarplot));
ivarplot_bin=find(contains(fldnms_bin,indvar_name_set));

Y_val_mat1=reshape(struct2array(dev_strt1.mean_ratio),[],length(fldnms1))';
Y_err_mat=reshape(struct2array(dev_strt1.std_ratio),[],length(fldnms1))';
Y_val1=Y_val_mat1(ivarplot,:);
Y_err=Y_err_mat(ivarplot,:);
Y_val_mat2=reshape(struct2array(dev_strt2.mean_ratio),[],length(fldnms2))';
Y_val2=Y_val_mat2(ivarplot,:);

Y_val_mat_bin=reshape(struct2array(dev_strt_bin.mean_ratio),[],length(fldnms_bin))';
Y_val_bin=Y_val_mat_bin(ivarplot_bin,:);
Y_err_mat_bin=reshape(struct2array(dev_strt_bin.std_ratio),[],length(fldnms_bin))';
Y_err_bin=Y_err_mat_bin(ivarplot_bin,:);

% combine the variables
Y_val1 = [Y_val1 Y_val_bin];
Y_val2 = [Y_val2 ones(size(Y_val_bin))];
Y_err = [Y_err Y_err_bin];

Xc=indvar_ename_all(ivarset);
Xc(contains(Xc,'cloud water path'))={'CWP'};
Xc(contains(Xc,'rain water path'))={'RWP'};
Xc(contains(Xc,'cloud number'))={'N_c'};
Xc(contains(Xc,'rain number'))={'N_r'};
Xc(contains(Xc,'surface pcpt. rate'))={'MSP'};
Xc(contains(Xc,'liquid water path'))={'LWP'};
Xc(contains(Xc,'cloud half-life'))={'t_{1/2,c}'};

X=categorical(Xc);
X=reordercats(X,Xc);

%%
hold on

b1=bar(X,Y_val1,1);
b1(1).FaceColor=color_order{1};
b1(2).FaceColor=color_order{2};
b1(3).FaceColor=color_order{3};
b1(1).FaceAlpha=0.5;
b1(2).FaceAlpha=0.5;
b1(3).FaceAlpha=0.5;
b1(1).LineWidth=1;
b1(2).LineWidth=1;
b1(1).BaseValue=1;
b1(1).BaseLine.Color=[.8 .8 .8];

b2=bar(X,Y_val2,1);
b2(1).FaceColor=color_order{1};
b2(2).FaceColor=color_order{2};
b2(3).FaceColor=color_order{3};
b2(1).FaceAlpha=0.5;
b2(2).FaceAlpha=0.5;
b2(1).LineWidth=1;
b2(2).LineWidth=1;
b2(1).BaseValue=1;
b2(1).LineStyle=':';
b2(2).LineStyle=':';
b2(1).BaseLine.Color=[.8 .8 .8];

barwidth = b1(1).BarWidth;
yneg = 1-1./(1+Y_err(:,1));
ypos = Y_err(:,1);
erb = errorbar((1:length(X)) - barwidth/4.5, Y_val1(:,1), yneg, ypos, 'LineWidth', 1);
erb.Color = color_order{1};
erb.LineStyle = 'none';

yneg = 1-1./(1+Y_err(:,2)); 
ypos = Y_err(:,2);
erb = errorbar((1:length(X)), Y_val1(:,2), yneg, ypos, 'LineWidth', 1);
erb.Color = color_order{2};
erb.LineStyle = 'none';

yneg = 1-1./(1+Y_err(:,3)); 
ypos = Y_err(:,3);
erb = errorbar((1:length(X)) + barwidth/4.5, Y_val1(:,3), yneg, ypos, 'LineWidth', 1);
erb.Color = color_order{3};
erb.LineStyle = 'none';


hold off

set(gca,'YScale','log')
ylim([0.3 3])
yticks([.3 0.50 0.8 1 1.5 2 3])
yticklabels({'-70', '-50','-20','0','+50','+100', '+200'})
box on

grid()

set(gca,'fontsize',12)

end
