function save_figs(name)
%print(strcat('figs/', name, '.png'), '-dpng', '-r75');
print(strcat('figs/', name, '-pr.png'), '-dpng', '-r300');
%print(strcat('figs/Figure_', name, '.svg'), '-dsvg');
savefig(strcat('figs/Figure_', name, '.fig'));
end