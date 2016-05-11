% Some parameters ...
n = 1000;
dist = 10;
ascale = 2;

% Creates x = [-10.00, -9.99, -9.98, ... , 9.98, 9.99, 10.00] with n=1000, dist=10.
x = ((-n):n)/n*dist;

% Creates ldist = [0, ..., 0.25 , ..., 0] w/a distribution that seems Gaussian.
ldist = 1./(2+exp(ascale*x)+exp(-ascale*x));

% Almost the same as ldist but the middle values seem to have a higher peak (0.6-ish).
ndist = normpdf(x, 0, 1.4/ascale);

% The same as ldist except with about 500 zeros padded on each side.
ldistfull = [zeros(1, n/2) , ldist, zeros(1, n/2-1)];

% For each column, we set a different 2000 block slice (out of 3000) to be ldist.
convmat = zeros(3*n, n);
for i = 1:n
  convmat(i:(i+2*n), i) = ndist';
end

% Making everything nonzero ...
tail = ldistfull' + 3e-3;

% A (6000 x 1001) matrix but IDK why we need this.
A = [[convmat ; -convmat] , -[tail ; tail]];

% A (6000 x 1) vector, w/normal-like distributions on top/bottom (bottom is negated).
b = [ldistfull'; -ldistfull'];

% OK ... why on earth are we using a linear programming solver? I'm missing the context.
f = [zeros(n,1); 1];    % A (1001 x 1) vector, IDK why.
lb = zeros(n+1,1);      % A (1001 x 1) vector, perhaps A*(lb) = b?

% Returns y that minimizes f^Ty s.t. Ay <= b; 'lb' is a component-wise lower_bound on y.
y=linprog(f,A,b,[],[],lb);

% This is interesting, we convolve it ... I guess this is a nice way of doing a convolution?
z = convmat * y(1:n);
zs = z((n/2):(5*n/2))';

% The "semilogy" plots data with log scale for y-axis, but IDK what this means.
figure(1)
semilogy(x, ldist, x, zs);

% Easiest figure to understand. Looks like y is sharp in a few places, zero in most of them.
figure(2)
plot(y);

% relerr reported as 0.0101
relerr = y(n+1)

% Third figure does ... something, IDK what.
figure(3);plot(x,zs./ldist,x,10*ldist)
