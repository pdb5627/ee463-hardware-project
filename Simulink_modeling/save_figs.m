function save_figs(name)
%print(strcat('figs/Figure_', name, '.png'), '-dpng', '-r75');
print(strcat('figs/Figure_', name, '.png'), '-dpng', '-r300');
%print(strcat('figs/Figure_', name, '.svg'), '-dsvg');
savefig(strcat('figs/Figure_', name, '.fig'));
end