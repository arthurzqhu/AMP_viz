function y = wmean(A,w)

% y = wmean(A, w). A = random variable. w = weights.
if any(w<0)
   %error('weights cant be negative')
   % warning('some weights are negative. they are set to 0 but might need to be inspected')
   w(w<0)=0;
end

% make sure they are shaped correctly
if size(A, 1) == 1
   A = A';
end

if size(w, 1) == 1
   w = w';
end

w(isnan(A+w)) = 0;
A(isnan(A+w)) = 0;

if sum(w) ~= 1
   w = w/nansum(w);
end

y = A'*w;

if size(A, 1) ~= size(w, 1)
   error('weights must have the same dimension as the data')
end

end
