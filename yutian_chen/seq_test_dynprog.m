function [err, mean_j, p_pos, p_neg, p_j] = seq_test_dynprog(mu_std, r, J, G, Nbins)
% Sequential test. Assume the joint distribution of all the data items is a
% Gaussian distribution.
%
% Use the default value of an input argument by omitting it if no
% nondefault arguments are used after it, or by providing an empty vector
% [].
%
% Input:
%   mu_std: standardized mean (delta), (mu - mu_0) / sigma * sqrt(N - 1).
%           Default 0.
%   r: scalar, or a vector. Ratio of the first mini-batch to the population
%      in a linear schedule if it's a scalar, i.e. \pi_1 = m / N.
%      Otherwise, r_j is the ratio of the total observed data upto test j.
%      Default 0.1.
%   J: scalar, maximum number of tests in one trial. Default lenght of r if
%      r is a vector, otherwise the minimal number of tests to observe all
%      the data.
%   G: The thersholds. Scalar or a vector of length J. Default
%      norminv(1-0.05).
%   Nbins: number of bins in discretization. Scalar or a vector of length
%          J. Default 100.
%
% Output:
%   err: Error.
%   mean_j: expected value of j.
%   p_pos: P(z_j' > G). Type II error when mu0 < 0.
%   p_neg: P(z_j' < -G). Type I error when mu0 > 0.
%   p_j: 2 x J matrix.
%        p_j(1, j) = P(j' = j and z_j' < -G)
%        p_j(2, j) = P(j' = j and z_j' > G)
%
% Example:
%   Use a linear schedule with an initial 10% mini-batch, and confidence
%   level 0.05 for a single test. Assume the mean is 0 which is the worst 
%   case.
%   [err, mean_j, p_pos, p_neg, p_j] = seq_test_dynprog(0, 0.1, [], norminv(1-0.05))
%
%   Use a doubling schedule with an initial 10% mini-batch. Assume the
%   standardardized mean is 0.1.
%   [err, mean_j, p_pos, p_neg, p_j] = seq_test_dynprog(0.1, [0.1, 0.2, 0.4, 0.8, 1.0])
%
%   Set the maximum number of tests to be 4. Make a hard decision according
%   to the mean after observing r[4]=80% of the data.
%   [err, mean_j, p_pos, p_neg, p_j] = seq_test_dynprog(0.1, [0.1, 0.2, 0.4, 0.8, 1.0], 4)

setdefault('mu_std', 0);
setdefault('r', .1);
setdefault('G', norminv(1 - 0.05));
setdefault('Nbins', 100);

if isscalar(r)
  r = r : r : 1;
  if r(end) < 1
    r(end + 1) = 1;
  end
end

setdefault('J', length(r));
assert(J <= length(r))

if isscalar(G)
  G = G * ones(J, 1);
end
G = G(:);
assert(length(G) == J);

if isscalar(Nbins)
  Nbins = Nbins * ones(J, 1);
end
Nbins = Nbins(:);
assert(length(Nbins) == J);

% % Number of bins.
% L = Nbins;
% width_bin = 2 * G / L;
% 
% % Bin centers, L x 1 vector.
% C = linspace(-G, G - width_bin, L)' + width_bin / 2;

% Initialize the discrete distribution with C and P.
% At j'th iteration:
%   C(i), 1 <= i <= Nbins(j), is i'th bin's center at j'th iteration.
%   P(i) = P(z_j = C(i)), 1 <= i <= Nbins(j).
C = 0;
P = 1;
sum_p_j = 0;

% Initialize p_j.
p_j = zeros(2, J);

for j = 1 : J
  if j == 1
    pi_j_1 = 0;
  else
    pi_j_1 = r(j - 1);
  end
  pi_j = r(j);
  
  % Number of bins.
  L = Nbins(j);
  width_bin = 2 * G(j) / L;

  % Bin centers, L x 1 vector.
  C_j_1 = C;  % C at (j-1)'th iteration.
  % C = linspace(-G(j), G(j) - width_bin, L)' + width_bin / 2;
  C = -G(j) + width_bin / 2 + (0 : L-1)' * (2*G(j)-width_bin) / (L-1);

  if j < J || pi_j < 1
    % If it is not the last iteration or it will not use all the data, do
    % a regular update.
  
    % Conditional mean: mu_j = a_j * mu + b_j * z_{j-1}.
    % a_j = 1 / (1 - pi_j_1) * sqrt(r / (j * (1 - pi_j)));
    % b_j = sqrt((j - 1) / j * (1 - pi_j) / (1 - pi_j_1));
    a_j = (pi_j - pi_j_1) / (1 - pi_j_1) * sqrt(1 / (pi_j * (1 - pi_j)));
    b_j = sqrt(pi_j_1 / pi_j * (1 - pi_j) / (1 - pi_j_1));
    mu_j = a_j * mu_std + b_j * C_j_1;
    
    % Conditional standard deviation.
    % sig_j = sqrt(1 / j / (1 - pi_j_1));
    sig_j = sqrt((pi_j - pi_j_1) / pi_j / (1 - pi_j_1));
    
    % p_j(1, j) = sum(normcdf(-G(j), mu_j, sig_j)' * P);
    p_j(1, j) = 0.5 * erfc(-((-G(j) - mu_j) / sig_j) ./ sqrt(2))' * P;

    % p_j(2, j) = sum(1 - normcdf(G, mu_j, sig_j));
    p_j(2, j) = (1 - 0.5 * erfc(-((G(j) - mu_j) / sig_j) ./ sqrt(2))') * P;

    % Update P for next iteration.
    %
    % Most readable form:
    % P = width_bin / (sqrt(2 * pi) * sig_j) * ...
    %     exp(-0.5 * (bsxfun(@minus, C, mu_j') / sig_j).^2) * P;
    %
    % A little bit faster implementation
    P = width_bin / (sqrt(2 * pi) * sig_j) * ...
        sum(exp(bsxfun(@plus, -0.5/sig_j^2 * C.^2, ...
                bsxfun(@plus, 1/sig_j^2 * C * mu_j', (-0.5/sig_j^2 * mu_j.^2 + log(P))'))), 2);

    % Even faster but unstable due to overflow.
    % P = width_bin / (sqrt(2 * pi) * sig_j) * ...
    %     exp(-0.5/sig_j^2 * C.^2) .* ...
    %     (exp(1/sig_j^2 * C * mu_j') * (exp(-0.5/sig_j^2 * mu_j.^2) .* P));

    % Normalization to reduce the numeric error that causes the total
    % probability to exceed 1.
    if sum_p_j + sum(p_j(:, j)) >= 1
      if sum_p_j < 1
        p_j(:, j) = p_j(:, j) / sum(p_j(:, j)) * (1 - sum_p_j);
      else
        p_j(:, j) = 0;
      end
      sum_p_j = 1;
      P(:) = 0;
    else
      sum_p_j = sum_p_j + sum(p_j(:, j));
      P = P / sum(P) * (1 - sum_p_j);
    end
    
  else
    
    % At the last step, if J * r >= 1, make a correct decision at J'th
    % step. If mu == 0, assign all the probability to the positive side.
    if mu_std < 0
      p_j(1, j) = sum(P);
      p_j(2, j) = 0;
    else
      p_j(1, j) = 0;
      p_j(2, j) = sum(P);
    end
    P = zeros(L, 1);
    
  end

end

% if J * r < 1
if r(J) < 1
  % Terminates when J * r < 1, make a hard decision for the remaining
  % probability mass according to z_J.
  p_j(1, J) = p_j(1, J) + sum(P(C < 0)) + sum(P(C == 0)) / 2;
  p_j(2, J) = p_j(2, J) + sum(P(C > 0)) + sum(P(C == 0)) / 2;
end

assert(abs(sum(p_j(:)) - 1) < 1e-10);

% P(z_j' < -G(j')).
p_neg = sum(p_j(1, :));

% P(z_j' > G(j')).
p_pos = sum(p_j(2, :));

if mu_std < 0
  err = p_pos;
else
  err = p_neg;
end

mean_j = (1 : J) * sum(p_j, 1)';

end
