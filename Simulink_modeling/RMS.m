% Computing RMS current numerically. For variable-time-step sequences,
% requires an approximation of integration rather than a simple sum.
function ans = RMS(s)
    dt = s.Time(end) - s.Time(1);
    t = s.Time;
    f = s.Data;
    ans = sqrt(trapz(t, f.^2)/dt);
end