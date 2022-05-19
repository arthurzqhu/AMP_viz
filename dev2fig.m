function [X,Y]=dev2fig(dev_strt,dev_strt_a)

global indvar_name_set indvar_name_all indvar_ename_all color_order

fldnms=fieldnames(dev_strt);
ivarplot=find(contains(fldnms,indvar_name_set));
ivarset=contains(indvar_name_all,fldnms(ivarplot));
Y_mat=reshape(struct2array(dev_strt),[],length(fieldnames(dev_strt)))';
% Y_mat=cell2mat(struct2cell(dev_strt));
Y=Y_mat(ivarplot,:);
Y_mat_a=reshape(struct2array(dev_strt_a),[],length(fieldnames(dev_strt_a)))';
% Y_mat_a=cell2mat(struct2cell(dev_strt_a));
Y_a=Y_mat_a(ivarplot,:);
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
b=bar(X,Y,1);
b(1).FaceColor=color_order{1};
b(2).FaceColor=color_order{2};
b(1).FaceAlpha=0.75;
b(2).FaceAlpha=0.75;
b(1).LineWidth=1;
b(2).LineWidth=1;
b(1).BaseValue=1;
b(1).BaseLine.Color=[.8 .8 .8];

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
ylim([0.67 1.7])
yticks([0.67 0.8 1 1.2 1.5])
yticklabels({'-33','-20','0','20','50'})

grid()

set(gca,'fontsize',12)

end
