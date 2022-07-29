function Y = abslog(X)

% X: an array of ratios
% Y: = x if > 1, = 1/x if < 1

Y = exp(abs(log(X)));

end
