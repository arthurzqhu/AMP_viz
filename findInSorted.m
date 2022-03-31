function [a,b] = findInSorted(arr,minv,maxv)
    % input: arr, minv, (maxv)
    % output: a, b
    % output two boundary indices (a, b) of an interval (minv,maxv] in a sorted array 'arr' using binary search
    % function will return the two indices adjacent to minv if maxv is not specified
    
    if nargin < 2
        error('Please specify the sorted array and/or the minimum and/or maximum value')
    end
    
    L = 1; % lower bound
    R = length(arr); % upper bound
    m = floor((L+R)/2); % mid value
    
    while R>L+1 % while R and L is more than 1 apart
        if arr(m)<=minv
            L = m;
            m = ceil((L+R)/2); % ceil() is used here and floor() below to avoid skipping indices
        elseif arr(m)>minv 
            R = m;
            m = floor((L+R)/2);
        else
            break
        end
    end
    
    a=R; % set a to the upper bound
    

    if nargin == 2
        b = a;
        a = a-1;
    elseif nargin == 3
        L = a;
        R = length(arr);
        m = floor((L+R)/2);
    
        while R>L+1
            if arr(m)<=maxv
                L = m;
                m = ceil((L+R)/2);
            elseif arr(m)>maxv
                R = m;
                m = floor((L+R)/2);
            else
                break
            end
        end
    
    b=L;
    end
    
    if  any(isnan(minv)) || any(isnan(arr))
        a=nan;
        b=nan;
    end
   
end
