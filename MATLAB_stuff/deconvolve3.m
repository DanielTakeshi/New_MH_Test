% OK a bunch of the usual parameters ...
n = 1000;
dist = 10;
ascale = 2;
iclip = 20;
x = [(0:n), ((-n):-1)]/n*dist;
%x = [(-n:n)]/n * dist; % So now it goes from, e.g., -10 to 10 by 0.01.
ldist = ascale./(2+exp(ascale*x)+exp(-ascale*x));
ndist = normpdf(x, 0, 1/ascale);
figure(1);plot(1:length(x), ldist, 1:length(x), ndist, 'LineWidth', 3);legend('ldist','ndist');xlim([0,2000]);

ff = real(fft(ldist));
nff = real(fft(ndist));
figure(2);plot(1:length(x),abs(ff),1:length(x),abs(nff), 'LineWidth', 2); legend('abs(ff)','abs(nff)');xlim([0,2000]);
figure(3);semilogy(1:length(x),abs(ff),1:length(x),abs(nff), 'LineWidth', 2); legend('abs(ff)','abs(nff)');xlim([0,2000]);

fdiv = ff./nff;
fdiv(iclip:(length(fdiv)-iclip+2)) = 0;
u = ifft(fdiv);
figure(4);plot(u, 'Linewidth', 2); legend('u');xlim([0,2000]);
v = ifft(fdiv.*nff);
figure(5);semilogy(1:length(x), ldist, 1:length(x), v, 'Linewidth', 2);legend('ldist', 'v');xlim([0,2000]);
figure(6);plot(1:length(x), ldist, 1:length(x), v, 'Linewidth', 2);legend('ldist', 'v');xlim([0,2000]);