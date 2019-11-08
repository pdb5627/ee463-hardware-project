% Set source impedance values just in case they get messed from prev.
% script run.
open('three_ph_SCR')
set_param('three_ph_SCR/Zs_a', 'BranchType', 'R')
set_param('three_ph_SCR/Zs_a', 'Resistance', '1e-6');
set_param('three_ph_SCR/Zs_b', 'BranchType', 'R')
set_param('three_ph_SCR/Zs_b', 'Resistance', '1e-6');
set_param('three_ph_SCR/Zs_c', 'BranchType', 'R')
set_param('three_ph_SCR/Zs_c', 'Resistance', '1e-6');
% Define window of time for plotting since some time is added for settling
% to steady state.
tstart = 0;
tstop = 0.02;

% Run the simulation and get the output into variables
t = sim('Problem3');
Vout = getsampleusingtime(logsout.get('Vout').Values, tstart, tstop);
Is_a = getsampleusingtime(logsout.get('Is_a').Values, tstart, tstop);

% Defaults for this plot
% https://dgleich.wordpress.com/2013/06/04/creating-high-quality-graphics-in-matlab-for-papers-and-presentations/
width = 8;     % Width in inches
height = width*9/16;    % Height in inches
alw = 0.75;    % AxesLineWidth
fsz = 11;      % Fontsize
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize

% Generate plot for part a
figure(1);
clf('reset');
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
set(gca, 'YGrid', 'on');
set(gca, 'XGrid', 'on');

hold on;
yyaxis left;
plot(Vout, 'LineWidth', lw);
yyaxis right;
plot(Is_a, 'LineWidth', lw);

l = legend({'V_{out}', 'I_{in,a}'});
xlabel('t (s)');
yyaxis left;
ylabel('Voltage (V)');
yyaxis right;
ylabel('Current (A)');
title('Figure 3.1: Simulation Waveforms without Source Inductance');

print('figs/Figure3.1.png', '-dpng', '-r75');
print('figs/Figure3.1-pr.png', '-dpng', '-r300');
print('figs/Figure3.1.svg', '-dsvg');
savefig('figs/Figure3.1.fig');



% Calculate average output voltage
display(mean2(Vout), 'Average Vout');

% Harmonic Analysis
hmax = 30;
[a, b] = fourier(Is_a, 50, hmax);
I_h = sqrt(a.^2 + b.^2);
THD_I = sqrt(sum(I_h(2:end).^2))/I_h(1);
[a, b] = fourier(Vout, 300, hmax);         % Should this be 50Hz or 300 Hz??
Vout_h = sqrt(a.^2 + b.^2);
THD_Vout = sqrt(sum(Vout_h(2:end).^2))/Vout_h(1);
disp('Simulation Harmonic Calculation Results');
I_h_0mH = I_h;

disp(' ');
disp('|Harmonic Number |  Is Mag. (A)  | Vout Mag. (V)** |');
disp('|----------------|---------------|-----------------|');
for n = 1:hmax
    fprintf('| %8d       | %12g  | %12g    |\n', n, I_h(n), Vout_h(n));
end
fprintf('|      THD       | %12g  | %12g    |\n', THD_I, THD_Vout);
disp('**Vout fundamental frequency set to 300 Hz');


% Now set source inductance for part d
disp('Now setting source inductance for part d');
set_param('Problem3/Zs_a', 'BranchType', 'RL')
set_param('Problem3/Zs_a', 'Inductance', '1e-3');
set_param('Problem3/Zs_b', 'BranchType', 'RL')
set_param('Problem3/Zs_b', 'Inductance', '1e-3');
set_param('Problem3/Zs_c', 'BranchType', 'RL')
set_param('Problem3/Zs_c', 'Inductance', '1e-3');

% Run the simulation and get the output into variables
t = sim('Problem3');
Vout = getsampleusingtime(logsout.get('Vout').Values, tstart, tstop);
Is_a = getsampleusingtime(logsout.get('Is_a').Values, tstart, tstop);

% Generate plot for part a
figure(2);
clf('reset');
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
set(gca, 'YGrid', 'on');
set(gca, 'XGrid', 'on');

hold on;
yyaxis left;
plot(Vout, 'LineWidth', lw);
yyaxis right;
plot(Is_a, 'LineWidth', lw);

l = legend({'V_{out}', 'I_{in,a}'});
xlabel('t (s)');
yyaxis left;
ylabel('Voltage (V)');
yyaxis right;
ylabel('Current (A)');
title('Figure 3.2: Simulation Waveforms with Source Inductance');

print('figs/Figure3.2.png', '-dpng', '-r75');
print('figs/Figure3.2-pr.png', '-dpng', '-r300');
print('figs/Figure3.2.svg', '-dsvg');
savefig('figs/Figure3.2.fig');

% Calculate average output voltage
display(mean2(Vout), 'Average Vout');

% Harmonic Analysis
hmax = 30;
[a, b] = fourier(Is_a, 50, hmax);
I_h = sqrt(a.^2 + b.^2);
THD_I = sqrt(sum(I_h(2:end).^2))/I_h(1);
[a, b] = fourier(Vout, 300, hmax);         % Should this be 50Hz or 300 Hz??
Vout_h = sqrt(a.^2 + b.^2);
THD_Vout = sqrt(sum(Vout_h(2:end).^2))/Vout_h(1);
disp('Simulation Harmonic Calculation Results');
I_h_1mH = I_h;

disp(' ');
disp('|Harmonic Number |  Is Mag. (A)  | Vout Mag. (V)** |');
disp('|----------------|---------------|-----------------|');
for n = 1:hmax
    fprintf('| %8d       | %12g  | %12g    |\n', n, I_h(n), Vout_h(n));
end
fprintf('|      THD       | %12g  | %12g    |\n', THD_I, THD_Vout);
disp('**Vout nominal frequency set to 300 Hz');

% Third simulation run for Ls = 10 mH
disp('Now setting source inductance for part f');
set_param('Problem3/Zs_a', 'BranchType', 'RL');
set_param('Problem3/Zs_a', 'Inductance', '10e-3');
set_param('Problem3/Zs_b', 'BranchType', 'RL');
set_param('Problem3/Zs_b', 'Inductance', '10e-3');
set_param('Problem3/Zs_c', 'BranchType', 'RL');
set_param('Problem3/Zs_c', 'Inductance', '10e-3');

% Run the simulation and get the output into variables
t = sim('Problem3');
Vout = getsampleusingtime(logsout.get('Vout').Values, tstart, tstop);
Is_a = getsampleusingtime(logsout.get('Is_a').Values, tstart, tstop);

% Harmonic Analysis
hmax = 30;
[a, b] = fourier(Is_a, 50, hmax);
I_h = sqrt(a.^2 + b.^2);
THD_I = sqrt(sum(I_h(2:end).^2))/I_h(1);
I_h_10mH = I_h;

% Comparison of input current harmonics for various input inductances
figure(3);
clf('reset');
hold on;
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
set(gca, 'YGrid', 'on');

bar([I_h_0mH, I_h_1mH, I_h_10mH], 1.0);
xticks(1:hmax);
xlim([0.5 19.5]); % Zoom in on x-axis to see better.
xlabel('Harmonic Number (f1 = 50 Hz)');
ylabel('Harmonic Current (A)');
legend({'L_s = 0 mH', 'L_s = 1 mH', 'L_s = 10 mH'});
title('Figure 3.3: Comparison of Input Harmonic Current');

print('figs/Figure3.3.png', '-dpng', '-r75');
print('figs/Figure3.3-pr.png', '-dpng', '-r300');
print('figs/Figure3.3.svg', '-dsvg');
savefig('figs/Figure3.3.fig');


% Put source impedance parameters back.
set_param('Problem3/Zs_a', 'BranchType', 'R')
set_param('Problem3/Zs_a', 'Resistance', '1e-6');
set_param('Problem3/Zs_b', 'BranchType', 'R')
set_param('Problem3/Zs_b', 'Resistance', '1e-6');
set_param('Problem3/Zs_c', 'BranchType', 'R')
set_param('Problem3/Zs_c', 'Resistance', '1e-6');