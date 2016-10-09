% OK a bunch of the usual parameters ...
n = 1000;
dist = 10;
ascale = 2;
iclip = 20;

% Again, produce some x-coordinates, but it's odd, we go 0, ..., n, but then -n, ..., 0. ???
x = [(0:n), ((-n):-1)]/n*dist;

% So ... [0.5, ..., 0, ..., 0.5], goes down to zero, stays at zero, then goes back up. ???
ldist = ascale./(2+exp(ascale*x)+exp(-ascale*x));

% As expected, is [0.8, ..., 0, ..., 0.8] due to how values closer to zero are at the ends of "x".
ndist = normpdf(x, 0, 1/ascale);

% r0 = 1001 random nubers, in a row-vector, then rr has a symmetric version of r0 in second half.
% But we never use these?
r0 = rand(1,n+1);
rr = [r0, r0(end:-1:2)];

% Plots ldist and ndist, very straightforward. Note: greener/lighter curve is ndist, the second item.
figure(1);plot(1:length(x), ldist, 1:length(x), ndist, 'LineWidth', 3);legend('ldist','ndist');

% Now we're doing a Fast Fourier Transform of ldist and ndist, why?
ff = real(fft(ldist));
nff = real(fft(ndist));

% At least we can see the (absolute value) of the FFT, but the plot isn't that informative. The LOG
% plot is MUCH better and we see some weird stuff at the bottom.
figure(2);plot(1:length(x),abs(ff),1:length(x),abs(nff), 'LineWidth', 2); legend('abs(ff)','abs(nff)');
figure(3);semilogy(1:length(x),abs(ff),1:length(x),abs(nff), 'LineWidth', 2); legend('abs(ff)','abs(nff)');

% Then we form u (component-wise division, then zero out elements, then do _inverse_ fft ...). ???
fdiv = ff./nff;
fdiv(iclip:(length(fdiv)-iclip+2)) = 0;
u = ifft(fdiv);
figure(4);plot(u, 'Linewidth', 2); legend('u');

% Then we do something to form v and plot it. We plot it with ldist, which is interesting. ???
v = ifft(fdiv.*nff);
figure(5);semilogy(1:length(x), ldist, 1:length(x), v, 'Linewidth', 2);
legend('v');

figure(6); plot(x, u, 'Linewidth', 2); legend('plot(x,u)');
