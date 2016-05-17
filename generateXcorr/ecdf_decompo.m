function [x, ecdf] = ecdf_decompo(sd, isdraw)

if ~exist('isdraw'), isdraw = 1; end
if ~exist('ratio'), ratio = 0.995; end

n = 2000;
iclip = 10;
alpha = sd;
beta = 1.0;
dist = 10;

g = @(x, beta) beta*exp(-beta*x)./(1+exp(-beta*x)).^2;

x = [(0:n), ((-n):-1)]/n*dist;

ldist = g(x, beta);
ldist = ldist * abs(x(2)-x(1));

ndist = normpdf(x, 0, alpha);
ndist = ndist * abs(x(2)-x(1));
if (isdraw)
    figure(2); plot(x, ldist, x , ndist,'r');
    legend('logistic', 'noisy')
end
ff = (fft(ldist));

nff = (fft(ndist));

fdiv = ff./nff;
fdiv(iclip:(length(fdiv)-iclip+2)) = 0;

u = ifft(fdiv);
u(u<0) = 0;
% show the x_corr
u= u/ trapz(x,u);
n_de = 2000;
x_new = ((1:(2*n_de))/n_de - 1)* dist;
u_new = interp1(x, u, x_new, 'linear');
% linear iterplot
Ecdf = zeros(length(u_new)-1,1);
for i = 1:1:(length(u_new)-1)
    Ecdf(i) = trapz(x_new(1:(i+1)), u_new(1:(i+1)));
end
Ecdf = Ecdf' + (1:length(Ecdf))/length(Ecdf)*0.000001*max(Ecdf);
Ecdf = Ecdf / max(Ecdf);

if (isdraw)
    figure(1); plot(x, u, 'b'); 
end
x = x_new(2:length(x_new));
ecdf = Ecdf;
ecdf = ecdf / max(ecdf);
end