function save_table(T, name, caption)
% Save table data as csv.

% Iterate through columns to clean up numeric data
for n = 1:size(T, 2)
    tmp = T{:, n};
    if class(tmp) == 'double'
        % Round very small numbers to zero
        tmp(abs(tmp) < 1e-2) = 0;
        T{:, n} = tmp;
        % Round for limited number of significant digits
        T{:, n} = round(T{:, n}, 4, 'significant');
    end
end



display(T, caption);
writetable(T, strcat('tables/', name, '.csv'), 'WriteVariableNames', true, ...
    'WriteRowNames', true);

end