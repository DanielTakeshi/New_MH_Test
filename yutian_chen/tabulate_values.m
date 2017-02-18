% Daniel Seita: I use this to call Yutian Chen's code for tabulating values. 
% 
% Input to set:
%   K: A positive number such that the \mu_std values will be in [-K,K].
%   N: The number of points within [-K,K] to use for \mu_std values.
%
% What it saves:
%   For now I will only be saving the `err` and `mean_j` terms. The `mean_j`
%   value will be useful to compute \bar{\pi} estimates given the initial batch
%   of, say, 100 elements. We can simply do 100 * mean_j. As for the error term,
%   we'll figure something out with the optimization problem.
%
% Usage: 
%   I just run it on my command line:
%
%     matlab -r tabulate_values
%
%   Note: I set my `matlab` command to use -nodesktop and -nodisplay. Also,
%   watch out for the outfile_name! Set it to be something informative.
% 
% Notes:
%   For logistic regression with MNIST(8M), we use a fixed minibatch size (and
%   increment value) of 100. For regular MNIST, the training data has size 13000
%   and for MNIST8M, we'll use 100k; otherwise anything larger means the
%   competing methods will take absurdly long.
%
%   I'll also be using their default discretization for bins.
%
% 

outfile_name = 'mu_std_K30_N20000_eps005.mat'
K = 30;
N = 20000;
ratio = 100 / 13000;  % use 100/100000 for MNIST8M
max_tests = 13000 / 100;  % use 100000/100 for MNIST8M
eps = 0.05;  % I use 0.05 ... but then we have to fix this??
fprintf('Running tabulate_values using K = %d, N = %d\n', K,N);
fprintf('\tratio = %f, max_tests = %d, eps = %f\n', ratio, max_tests, eps);

assert(K > 0);
mu_std_values = linspace(-K, K, N);
result = zeros(N, 3);

for i = 1:length(mu_std_values)
    if mod(i,100) == 0
        fprintf('i = %d, mu_std = %f\n', i, mu_std_values(i));
    end
    [err, mean_j, p_pos, p_neg, p_j] = seq_test_dynprog(mu_std_values(i), ...
        ratio, max_tests, norminv(1 - eps));
     result(i, 1) = mu_std_values(i);
     result(i, 2) = err;
     result(i, 3) = mean_j;
end

save(outfile_name, 'result');
fprintf('Done!\n');
