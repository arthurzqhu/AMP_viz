function rank = RankData(data, alongDim, invalidRank)
% rank = RankData(data, alongDim, invalidRank)
%
% Returns the rank for each element in data.
%
% Matched entries have the same integer rank (this differs from tiedrank).
% Invalid values (Nan,missing,etc.) are set to invalidRank (default NaN) rank.
% 
% Handles all data types accepted by matlab function unique.
%
% Params
%   alongDim (default [])
%       If empty, rank will be across all elements. Otherwise, rank will
%       be computed across the entries in alongDim.
%
%       E.g., data of size [2 4 5] with alongDim of 1, will have max
%       ranking of 2 for each of the 2nd and 3rd dims. And if alongDim was
%       3, the max rank would be 5. If alongDim was empty, maxRank is
%       2*4*5=40.
% 
%   invalidRank (default NaN)
%       What rank value invalid entries are set to.
%   
% 
% Example 1
%
% data = randn(3,4,5);
% rank = RankData(data); 
%
% Example 2
%
% data = [10 nan 11 nan nan 1 2 5 1 7];
% rank = RankData(data)
%
% Example 3
% Output similar to tiedrank. 
% Specify a dimension to rank data (similar to how tiedrank handles matrices).
% While we demonstrate matched results, RankData can handle non numeric entries.
%
% data = rand(3,4,2);
% data(3,:,:) = data(2,:,:); % Match entries to force ties
% alongDim = 1;
% rank = tiedrank(RankData(data,alongDim));
% isequal(rank,tiedrank(data))
% 
% 
% See also: unique, tiedrank
% 
%--------------------------------------------------------------------------
% History:
%   2022.03      Copyright Tommy Hosman, All Rights Reserved
%   2022.03.13 - Added alongDim to easily match tiedrank outputs.
%--------------------------------------------------------------------------

    
    if nargin < 2
        alongDim = []; % Default rank across all elements on all dims
    end
    
    if nargin < 3
        invalidRank = NaN; % Default invalid entry rank values
    end
    
    if ~isempty(alongDim)
        % Rank along a specific dim and then return
        rank = LocalRankAlongDim(data, alongDim, invalidRank);
        return
    end
    
    
    % Find rank order
    [u,~,rank] = unique(data(:));
    
    
    % Set rank for missing entries (nan, invalid, etc.)
    nValid = sum(~ismissing(u));
    rank(rank>nValid) = invalidRank;
    
    
    % Reshape to original
    rank = reshape(rank,size(data));
end


function rank = LocalRankAlongDim(data, alongDim, invalidRank)
    %% Rank along elements of alongDim
    
    % Setup permute inds 
    maxDim = max(ndims(data),alongDim);
    permuteInds = [alongDim setdiff(1:maxDim, alongDim)];
    
    % Permute
    data = permute(data,permuteInds);
    
    % Call RankData for each non-row dim
    n = prod(size(data,2:maxDim));
    rank = nan(size(data));
    for ii = 1:n
        rank(:,ii) = RankData(data(:,ii), [], invalidRank);
    end
    
    % ipermute to original shape
    rank = ipermute(rank, permuteInds);
    
end