function pertdata=calcpert(data)
%Calculate perturbation from the mean field

%Input a 4D variable

n=size(data);

meandata=mean(mean(mean(data,4)));
meandata=repmat(meandata,[n(1),n(2),1,n(4)]);

pertdata=data-meandata;
