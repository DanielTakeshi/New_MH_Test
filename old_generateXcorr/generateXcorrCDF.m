% Compute the pdf of the X_Corr variable such that X_norm + X_corr ~ X_logistic
% This version minimizes the CDF error.

n = 100;                                             % resolution of discrete X_norm and X_logistic (actually 2n)
dist = 20;                                           % real x range encoded over these 2n values (-dist, dist)
nn = 1;                                              % multiplier for additional values outside the central range
sigma = 1.1;                                         % std deviation of the normal distribution

x = ((-n):n)/n*dist;                                            % x values

lcdfm =  1./(1+exp(-x));                                        % logistic cdf at the central values
lcdf = [zeros(1, nn*n), lcdfm, ones(1, nn*n-1)];                % logistic cdf over the full range

ncdfm =  normcdf(x, 0, sigma);                                  % normal cdf at the central values
ncdf = [zeros(1, (nn+1)*n), ncdfm, ones(1, (nn+1)*n-1)];        % normal cdf over the full range

ndr = 2*nn+2;                                                   % convenient constant
convmat = zeros(ndr*n, 2*n);                                    % convolution matrix
for i = 1:(2*n)
  convmat(:, i) = (ncdf(i:(i+ndr*n-1)))';
end

% variables [xcorr, eps];

tail = lcdf'+ 2.0e-3;                                           % epsilon multiplier for relative error minimization
tail = ones(ndr*n,1);                                           % epsilon multiplier absolute error minimization

A = [[convmat ; -convmat] , [-tail ; -tail]];                   % A and b inequality constraints, Ay <= b. Equivalent to
b = [lcdf'; -lcdf'];                                            % convmat * y - lcdf <= eps and
                                                                % convmat * y - lcdf >= -eps

Aeq = [ones(1, 2*n), 0];                                        % equality constraints specify sum(y) = 1
beq = 1;                                                        % but they dont seem to help

f = [zeros(2*n,1); 1];                                          % objective to minimize = eps
lb = zeros(2*n+1,1);                                            % lower bound all zeros;

% y=linprog(f,A,b,Aeq,beq,lb);

options = optimoptions('linprog');
% options = optimoptions(@linprog,'Algorithm','active-set')
% options.Algorithm='interior-point';
% options.OptimalityTolerance=1.0e-20;
% options.MaxIterations= 200;

[y, obj]=linprog(f,A,b,[],[],lb,[],[],options);                  % run the program to get y and the objective

z = convmat * y(1:(2*n));                                        % get the reconstructed logistic function
zs = z((nn*n+1):((nn+2)*n+1))';                                  % and its central part
yy = y(1:(2*n));

figure(1)
plot(x,y);                                                        % Plot Xcorr pdf

figure(2)
plot(x, lcdfm, x, zs);                                            % plot the actual and reconstructed logistic cdf 

figure(3)
semilogy(x, lcdfm, x, zs);                                        % plot the actual and reconstructed logistic cdf on a log y scale

max(abs(lcdfm - zs))                                              % max absolute error
max(abs((lcdfm - zs)./(lcdfm + 1.0e-3)))                          % max relative error

%figure(3);plot(x,zs./lcdf,x,10*lcdf)