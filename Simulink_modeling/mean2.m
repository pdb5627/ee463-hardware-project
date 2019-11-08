% Computing mean numerically. For variable-time-step sequences,
% requires an approximation of integration rather than a simple sum.
function ans = mean2(s)
    dt = s.Time(end) - s.Time(1);
    t = s.Time;
    f = s.Data;
    ans = trapz(t, f)/dt;
end