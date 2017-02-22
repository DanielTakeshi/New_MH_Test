% Daniel Seita: I use this to call Yutian Chen's code for tabulating values.
% See the notes later for more high-level comments.
% 
% Input to set:
%   K: A positive number such that the \mu_std values will be in [-K,K].
%   D: The number of points within [-K,K] to use for \mu_std values.
%
% What it saves:
%
%   result(a,b,c) = (mu_std(a), err, mean_j)
%
%   where:
%       a = mu_std index
%       b = epsilon index (note: this is the value we pick for one
%           accept/decision trial, it is NOT the error of the overall test
%           (which is a _sequence_ of hypothesis tets))
%       c = minibatch size (starting *and* the increment amount)
%   (results is 4-D, the last index is 1, 2, or 3)
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
%
%   I'll be using their default discretization for bins.
%
%   CHECK THE OUTPUT FILE NAMES! Be careful to avoid over-writing stuff.

% number_total_data: use 100000 for MNIST8M, 13000 for MNIST. Change file name!!
number_total_data = 100000;
K = 10;
epsilons = [0.001, 0.005, 0.01, 0.05, 0.1, 0.2];
sizes = [100, 200, 300, 400, 500];

% If running for all mu_std values, set this to 0. Else, 1. This is mainly in
% case I want to try finer-grained sizes and/or epsilons for the single mu_std=0
% case. Otherwise with all the mu_std's, we can't afford to have too many
% epsilon and size options for computational reasons.
do_only_one = 0;

if do_only_one == 1
    D = 1;
    mu_std_values = [0];
    result = zeros(1, length(epsilons), length(sizes), 3);
else 
    D = 4000;
    mu_std_values = linspace(-K, K, D);
    result = zeros(D, length(epsilons), length(sizes), 3);
end

% CHANGE FILE NAME IF NEEDED!!
outfile_name = sprintf('mu_std_K%d_D%d_mnist8m.mat', K, D)

fprintf('\tRunning tabulate_values using K = %d, D = %d\n', K, D);
for e = 1:length(epsilons)
    eps = epsilons(e);

    for j = 1:length(sizes)
        m = sizes(j);

        ratio = m / number_total_data; 
        max_tests = ceil(1. / ratio);
        fprintf('ratio = %f, max_tests = %d, eps = %f, m = %d\n', ...
            ratio, max_tests, eps, m);

        for i = 1:length(mu_std_values)
            if mod(i,100) == 0
                fprintf('i = %d, mu_std = %f\n', i, mu_std_values(i));
            end
            [err, mean_j, p_pos, p_neg, p_j] = seq_test_dynprog(mu_std_values(i), ...
                ratio, max_tests, norminv(1 - eps));
            result(i, e, j, 1) = mu_std_values(i);
            result(i, e, j, 2) = err;
            result(i, e, j, 3) = mean_j;
        end
    end
end
save(outfile_name, 'result', '-v7.3');

fprintf('Done!\n');
