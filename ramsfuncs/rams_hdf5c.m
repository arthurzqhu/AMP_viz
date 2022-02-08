function rams_hdf5c(var,hr,fold,varargin)
%var is a string or cell array of strings indicating the variables to load.
%   Lower or upper case is acceptable
%hr is the file number you wish to load. The first file
%   in the specified folder is file 0.
%fold is a string or cell array of strings of the folder(s) from which to
%   load the data.  Change "pref" below to modify the start of the path.  
%varargin{1} is for the vertical levels - default is all above ground
%varargin{2} is for the grid number - default is 2

%tic

%pref='~/rams6_bin/bin/';
%pref='~/Desktop/rams6_bin/bin/';
%pref='G:\\CopyHDD\';
pref=[];

if iscell(fold)
    folder=fold;
elseif ischar(fold)
    folder={fold};
else
    'Error: please enter a valid folder format'
end
    
if ~iscell(var)
    var={var};
end

if numel(varargin)>0
    cb = varargin{1};
else
    cb = [2 139]; %start and length
end

global runs filepath

for f=1:length(folder)  
%    folder{f}
    files=dir([pref,folder{f},'/*g1.h5']);
%     nd=0;
%     for ff=1:length(files)
%         if ~strcmp(files(ff).name(18:21),'0000') & ~strcmp(files(ff).name(18:21),'1500') ...
%                 & ~strcmp(files(ff).name(18:21),'3000') & ~strcmp(files(ff).name(18:21),'4500')
%             nd=nd+1;
%             delind(nd)=ff;
%         end
%     end
    for v=1:length(var)
%        try
        for t=1:length(hr)
            filepath=[pref,folder{f},'/',files(hr(t)+1).name];
            datapath=['/',upper(var{v})];
            %if strcmpi(var{v},'FFCD')
                test=h5read(filepath,datapath);
            %else
            %    test=h5read(filepath,datapath,[1 1 cb(1)],[256 256 cb(2)]);
            %end
            %info=h5info(filepath,datapath);
            %ndim=length(info.ChunkSize);
            dims = size(test);
            ndim = length(dims);
            %nr=info.ChunkSize(1);
            %nc=info.ChunkSize(2);
           
            %files(hr(t)+1).name
            
            %test=permute(test,[2 1 3 4]);
            levs=size(test,3);
            if ndim <=3
                if t==1
                    A=zeros(size(test,1),size(test,2),size(test,3),length(hr));
                end
                A(:,:,:,t)=test(:,:,:);
            elseif ndim==4
                if t==1
                    A=zeros(dims(1),dims(2),levs,length(hr),33);
                end
                A(:,:,:,t,:)=test;
            end
        end
%         if numel(varargin)>0
%             if ~isempty(varargin{1})
%                 A=A(:,:,varargin{1},:);
%             elseif levs>1
%                 A=A(:,:,2:end,:);
%             end
%         elseif levs>1
%             if ndim <=3
%                 A=A(:,:,2:end,:);
%             elseif ndim==4
%                 A=A(:,:,2:end,:,:);
%             end
%         end
        runs(f).(var{v})=A;
        
%        catch
%            'An error occurred'
%        end
        %suf=num2str(f);
        %assignin('base',[var{v},suf],A);
    end
end
%assignin('base','A',runs);
evalin('base','global runs')
%toc
