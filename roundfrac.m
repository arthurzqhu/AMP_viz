function Xrounded = roundfrac(X,fraction,option)
% roundfrac rounds values to multiples of a fraction. 
% 
% 
%% Syntax
% 
% Xrounded = roundfrac(X,fraction)
% Xrounded = roundfrac(X,fraction,option)
% 
%% Description 
% 
% Xrounded = roundfrac(X,fraction) rounds X to multiples of nearest
% fraction. If fraction is a scalar, it is applied to all values in X. If
% dimensions of fraction match dimensions of X, it is applied element-wise. 
% If fraction is 1/3, values of X are rounded to the nearest one third.
% roundfrac(X,1) is equivalent to round(X). 
% 
% Xrounded = roundfrac(X,fraction,option) specifies an option string as
% 'floor', 'ceil', 'fix', or 'round'. Default rounding option is 'round'. 
% 
%% Examples 
% 
% % Create an array of numbers to round:
% x = [-1.4 -1.3 -1.1 0 1.1 1.3 1.4];
% 
% % Round them to the nearest one-third:
% roundfrac(x,1/3)
% ans =
%    -1.3333   -1.3333   -1.0000         0    1.0000    1.3333    1.3333
% 
% % Round them DOWN to the nearest one-third:
% roundfrac(x,1/3,'floor')
% ans =
%    -1.6667   -1.3333   -1.3333         0    1.0000    1.0000    1.3333
% 
% % Round them TOWARD ZERO to the nearest one-third:
% roundfrac(x,1/3,'fix')
% ans =
%    -1.3333   -1.0000   -1.0000         0    1.0000    1.0000    1.3333
%
% % Round x to the nearest multiple of 2.5: 
% roundfrac(x,2.5)
% ans =
%    -2.5000   -2.5000         0         0         0    2.5000    2.5000
% 
% % Round each value in x to a different multiple:  
% roundfrac(x,[1/3 1/2 1/16 3/7 4/7 44 .2])
% ans =
%    -1.3333   -1.5000   -1.1250         0    1.1429         0    1.4000
% 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at
% Austin's Institute for Geophysics. Chad has his own internet website at 
% http://www.chadagreene.com.  It is not a very nice website. 
% January 6, 2015. 
% 
% See also: round, ceil, floor, fix, mod, and rem.


%% Input checks: 

narginchk(2,3)
assert(isnumeric(X)==1,'Input X must be numeric.') 
assert(isnumeric(fraction)==1,'Input rounding fraction must be numeric.') 
if ~isscalar(fraction)
    assert(numel(X)==numel(fraction),'If rounding fraction is not a scalar, its dimensions must match dimensions of X.')
end

%% Set default rounding method to 'round': 
if nargin==2
    option = 'round'; 
else 
    assert(isnumeric(option)==0,'Rounding option must be a string (e.g., ''floor'', ''ceil'', etc.') 
end


%% Perform rounding: 

switch option 
    case 'round'
        Xrounded = round(X./fraction).*fraction;
        
    case 'floor'
        Xrounded = floor(X./fraction).*fraction;

    case 'ceil'
        Xrounded = ceil(X./fraction).*fraction;

    case 'fix'
        Xrounded = fix(X./fraction).*fraction;

    otherwise 
        error(['Unrecognized rounding option ''',option,'''.'])
end
       
