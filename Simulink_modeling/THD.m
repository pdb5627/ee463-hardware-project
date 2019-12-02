% Calculate THD of a signal using custom fourier function.
function v = THD(s, f1, nmax)
    [a, b] = fourier(s, f1, 1);
    s1 = sqrt(a(2, 1)^2 + b(2, 1)^2)/sqrt(2); % Fundamental magnitude
    v = sqrt(RMS(s)^2 - s1^2)/s1;
end