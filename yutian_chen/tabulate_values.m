% Daniel Seita: I use this to call Yutian Chen's code for tabulating values.
% See the notes later for more high-level comments.
% 
% Input to set:
%   K: A positive number such that the \mu_std values will be in [-K,K].
%   D: The number of points within [-K,K] to use for \mu_std values.
%
% What it saves:
%   For now I will only be saving the `err` and `mean_j` terms. The `mean_j`
%   value will be useful to compute \bar{\pi} estimates given the initial batch
%   of, say, 100 elements. We can simply do 100 * mean_j. As for the error term,
%   we'll figure out a good value to use empirically.
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
%   We have to fix an epsilon here (upper bound on error for each individual
%   test). I will run with {0.001, 0.005, 0.01, 0.05, 0.1, 0.2} which roughly
%   mirrors the values that were used in their paper. I'll run all of these
%   together here.
%
%   I'll also be using their default discretization for bins.

K = 30;
D = 20000;
ratio = 100 / 13000;  % ratio: use 100/100000 for MNIST8M
max_tests = 1. / ratio;  % inverse of the ratio
assert(K > 0);
epsilons = [0.001, 0.005, 0.01, 0.05, 0.1, 0.2];
mu_std_values = linspace(-K, K, D);

for e = 1:length(epsilons)
    result = zeros(D, 3);
    eps = epsilons(e);
    outfile_name = sprintf('mu_std_K30_D20000_eps%.4f_mnist.mat', eps)
    fprintf('\tRunning tabulate_values using K = %d, D = %d\n', K, D);
    fprintf('\tratio = %f, max_tests = %d, eps = %f\n', ratio, max_tests, eps);

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
end

fprintf('Done!\n');
