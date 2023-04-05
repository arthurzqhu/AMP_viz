function [stct, mask_c, mask_r, mask_l]=loadnc(mp_in,varargin)

global ivar1 ivar2 its nikki mconfig output_dir vnum ...
   bintype var1_str var2_str indvar_name_set indvar_name ...
   indvar_units indvar_ename indvar_ename_set indvar_units_set ...
   indvar2D_name indvar2D_units indvar2D_ename indvar2D_name_set ...
   indvar2D_ename_set indvar2D_units_set casenum split_bins col ...
   binmean cloud_mr_th rain_mr_th

if isempty(vnum)
   vnum = '0001';
end

if isempty(var1_str)
   filedir=[output_dir,nikki,'/',mconfig,'/',upper(mp_in),'_',...
      upper(bintype{its}),'/KiD_m-amp_b-',lower(mp_in),'+',...
      bintype{its},'_u-Adele_c-0*_v-',vnum,'.nc'];
else
   filedir=[output_dir,nikki,'/',mconfig,'/',upper(mp_in),'_',...
      upper(bintype{its}),'/',var1_str{ivar1},...
      '/', var2_str{ivar2},'/KiD_m-amp_b-',lower(mp_in),'+',...
      bintype{its},'_u-Adele_c-0*_v-',vnum,'.nc'];
% else
%    filedir=[output_dir,nikki,'/',mconfig,'/',mp_in,...
%       '/',var1_str{ivar1},'/', var2_str{ivar2},'/KiD_m-',mp_in,'_b-','+',...
%       '_u-Adele_c-0*_v-',vnum,'.nc'];
end

filemeta = dir(filedir);
filename = [filemeta.folder, '/', filemeta.name];
fileinfo = ncinfo(filename);
casenum=str2num(extractBetween(string(filemeta.name),'c-0','_v-'));

stct.time = ncread(filename, 'time');
stct.z = ncread(filename, 'z');

if isempty(varargin)
   for ivar = 1:length(fileinfo.Variables)
      var_name{ivar,1} = fileinfo.Variables(ivar).Name;
      stct.(var_name{ivar}) = ncread(filename, var_name{ivar});
      stct.(var_name{ivar})(stct.(var_name{ivar})==-999)=nan;
   end

else
   for ivar = 1:length(indvar_name_set)
      try
         var_name{ivar,1} = indvar_name_set{ivar};
         stct.(var_name{ivar}) = ncread(filename, var_name{ivar});
         stct.(var_name{ivar})(stct.(var_name{ivar}) == -999) = nan;
      catch
      end
   end

   % add additional specified variables
   for ivar = 1:length(varargin{1})
      try
         stct.(varargin{1}{ivar}) = ncread(filename, varargin{1}{ivar});
         stct.(varargin{1}{ivar})(stct.(varargin{1}{ivar}) == -999) = nan;
      catch
         if ~contains(varargin{1}{ivar}, {'liq','half_life_c'})
            % warning(['Variable ' varargin{1}{ivar} ' does not exist. Skipping...'])
         end
      end
   end
   for iliq = find(contains(varargin{1},'liq'))
      varn = varargin{1}{contains(varargin{1},'liq')};
      varn_wc = replace(varn,'liq','cloud');
      varn_wr = replace(varn,'liq','rain');
      var_cloud = ncread(filename, varn_wc);
      var_rain = ncread(filename, varn_wr);
      stct.(varargin{1}{iliq}) = var_cloud + var_rain;
   end
end

if exist('var_name', 'var')
   % combine cloud and rain type
   nvar = length(var_name);
   var_wcloud=var_name(contains(var_name,'cloud'));
   var_wrain=replace(var_wcloud,'cloud','rain');
   var_wliq=replace(var_wcloud,'cloud','liq');
   var_name=[var_name;var_wliq];
   liq_count=length(var_wliq);
   ivar=1;
   for ivaradd = nvar+1:nvar+liq_count
      try % in case I only want to EITHER cloud OR rain
         stct.(var_name{ivaradd})=stct.(var_wcloud{ivar})+stct.(var_wrain{ivar});
         ivar=ivar+1;
      end
   end

   % % calculate supersaturation
   % var_name=[var_name;'ss_w'];
   % supsat = stct.RH - 100;
   % supsat(supsat < 0) = nan;
   % stct.ss_w = supsat;

   % var_name=[var_name;'ss_wpremphys'];
   % supsat = stct.RH_premphys - 100;
   % supsat(supsat < 0) = nan;
   % stct.ss_wpremphys = supsat;

   % calculate cloud half life
   if contains('half_life_c', indvar_name_set)
      var_name=[var_name;'half_life_c'];
      time=stct.time;
      z=stct.z;
      if casenum<200
         cpath=stct.cloud_M1_path;
         rpath=stct.rain_M1_path;
      else
         cpath=stct.mean_cloud_M1_path;
         rpath=stct.mean_rain_M1_path;
      end
      stct.half_life_c=time(find(cpath<rpath,1));
      if isempty(stct.half_life_c)
         stct.half_life_c=nan;
      end
   end
end

% calculate relative dispersion of each grid
%var_name=[var_name;'reldisp'];
%
%if mp_in=='amp'
%   mdist=stct.mass_dist_init;
%elseif mp_in=='bin'
%   mdist=stct.mass_dist;
%end
%
%if its==2
%   binmean = load('diamg_sbm.txt');
%   mdist=mdist(:,1:length(binmean),:);
%elseif its==1
%   binmean = load('diamg_tau.txt');
%end
%
%mdist(mdist<0)=0;
%
%for itime=1:length(time)
%   for iz=1:length(z)
%      meanD = wmean(binmean,mdist(itime,:,iz));
%      stdD = std(binmean,mdist(itime,:,iz));
%      stct.reldisp(itime,iz) = stdD/meanD;
%   end
%end
%stct.(var_name{ivaradd+1})

% only select the available vars as indvars
if exist('var_name', 'var')
   indvar_name=intersect(indvar_name_set,var_name,'stable');
   vidx=ismember(indvar_name_set,indvar_name);
   indvar_ename=indvar_ename_set(vidx);
   indvar_units=indvar_units_set(vidx);

   indvar2D_name=intersect(indvar2D_name_set,var_name,'stable');
   vidx=ismember(indvar2D_name_set,indvar2D_name);
   indvar2D_ename=indvar2D_ename_set(vidx);
   indvar2D_units=indvar2D_units_set(vidx);
else
   var_name = {};
end


% % masks of datapoints higher than cloud/rain/liquid threshold
% mass_c = stct.diagM3_cloud*pi/6*1000;
% mass_r = stct.diagM3_rain*pi/6*1000;
% mass_l = stct.diagM3_liq*pi/6*1000;

% mask_c = mass_c > cloud_mr_th(1);
% mask_r = mass_r > rain_mr_th(1);
% mask_l = mass_c > min([cloud_mr_th(1), rain_mr_th(1)]);

end
