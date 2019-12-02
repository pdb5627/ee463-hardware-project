% Computing Fourier coefficients numerically
% a_n = 2/T * \int cos(n wt)*f(wt) d(wt)
% b_n = 2/T * \int sin(n wt)*f(wt) d(wt)
% Limits of integration should be an integer number of cycles
% T = 2*pi*(number of cycles)
%
% Since variable time step simulation may be used, use trapz
% for the numerical integration.
function [a, b] = fourier(s, f1, nmax)
    num_cycles = (s.Time(end) - s.Time(1))*f1;
    if abs(num_cycles - round(num_cycles)) > 0.1/nmax
        error('Signal should be integer number of cycles');
    end
    T = 2*pi*num_cycles;
    w = 2*pi*f1;
    wt = w*s.Time;
    f = s.Data;
    a = zeros(nmax+1, 1);
    b = zeros(nmax+1, 1);
    for n = 0:nmax
        a(n+1) = 2/T*trapz(wt, cos(n*wt).*f);
        b(n+1) = 2/T*trapz(wt, sin(n*wt).*f);
    end

end