function ans = PF(V, I)

ans = mean2(mtimes(V, I)) / (RMS(V)*RMS(I));

end