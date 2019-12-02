function plot_VI(V, I, label)


% Defaults for this plot
% https://dgleich.wordpress.com/2013/06/04/creating-high-quality-graphics-in-matlab-for-papers-and-presentations/
alw = 0.75;    % AxesLineWidth
fsz = 11;      % Fontsize
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize

width = 800;     % Width in pixels
height = width*2/3;    % Height in inches
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1), pos(2) - height + pos(4), width, height]); %<- Set size

ax = subplot(2, 1, 1);
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
set(gca, 'YGrid', 'on');
set(gca, 'XGrid', 'on');
hold on;

plot(V, 'LineWidth', lw, 'DisplayName', strcat('V_{', label, '}'));
sz = size(V.Data);
% Save existing legend data if any, and add to it
if isa(ax.Legend, 'matlab.graphics.GraphicsPlaceholder')
    ls = {};
else
    ls = ax.Legend.String;
    legend('off');
end
if sz(2) == 3
    l = legend(horzcat(ls, {strcat('V_{', label, ',a}'), strcat('V_{', label, ',b}'), strcat('V_{', label, ',c}')}), 'Location', 'bestoutside');
else
    l = legend('Location', 'bestoutside');
    %l = legend(horzcat(ls, {strcat('V_{', label, '}')}), 'Location', 'bestoutside');
end
xlabel('t (s)');
ylabel('Voltage (V)');
title('');

subplot(2, 1, 2);
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
set(gca, 'YGrid', 'on');
set(gca, 'XGrid', 'on');
hold on;

plot(I, 'LineWidth', lw, 'DisplayName', strcat('I_{', label, '}'));
sz = size(I.Data);
if sz(2) == 3
    l = legend({strcat('I_{', label, ',a}'), strcat('I_{', label, ',b}'), strcat('I_{', label, ',c}')}, 'Location', 'bestoutside');
else
    l = legend('Location', 'bestoutside');
    %l = legend({strcat('I_{', label, '}')}, 'Location', 'bestoutside');
end
xlabel('t (s)');
ylabel('Current (A)');
title('');

end