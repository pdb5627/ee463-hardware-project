% Calculate THD of a signal using custom fourier function.
function v = THD(s, f1, nmax)
    [a, b] = fourier(s, f1, nmax);
    h = sqrt(a.^2 + b.^2);
    v = sqrt(sum(h(2:end).^2))/h(1);
end