open('three_ph_SCR');

% Look up parameter names using the following command in MATLAB:
%   get_param('three_ph_SCR/V.S', 'ObjectParameters')
% For example, to set the source impedance using short-circuit level:
%   set_param('three_ph_SCR/V.S', 'Voltage', '220*sqrt(3)')
%   set_param('three_ph_SCR/V.S', 'SpecifyImpedance', 'on');
%   set_param('three_ph_SCR/V.S', 'ShortCircuitLevel', 'sqrt(3)*220*2000');
%   set_param('three_ph_SCR/V.S', 'BaseVoltage', '220*sqrt(3)');
%   set_param('three_ph_SCR/V.S', 'XRratio', '1');
% Or using resistance and reactance:
%   set_param('three_ph_SCR/V.S', 'SpecifyImpedance', 'off');
%   set_param('three_ph_SCR/V.S', 'Resistance', '0.1');
%   set_param('three_ph_SCR/V.S', 'Reactance', '0.1');
% Set the firing angle
%   set_param('three_ph_SCR/alpha', 'value', '60');

% Save graphic of model
print('-sthree_ph_SCR', 'figs/MODEL_three_ph_SCR.svg', '-dsvg');

% Define window of time for plotting since some (negative) simulation time
% is added for settling to steady state.
tstart = 0;
tstop = 0.02;

%% Run the simulation and get the output into variables
t = sim('three_ph_SCR');
get_three_ph_SCR_data;

%% Generate Thyristor Voltage & Current Plot
fig = figure(1);
clf('reset');
plot_VI(S_volts{1, 1}, S_amps{1, 1}, 'S1');
sgtitle('Thyristor Voltage and Current');

save_figs('Figure_S1_V_I');

%% Generate Source Voltage & Current Plot
fig = figure(2);
clf('reset');
plot_VI(Vs, Is, 's');
sgtitle('Source Voltage and Current');

save_figs('Figure_Src_V_I');


% Calculate and print various quantities
display(mean2(Vd), 'Average Vd');
display(mean2(Id), 'Average Id');
Pout = mean2(Vd*Id);
display(Pout, 'Avg output power');
display((max(Vd) - min(Vd))*2 / (max(Vd) + min(Vd))*100, 'Output voltage ripple (%)');
display((max(Id) - min(Id))*2 / (max(Id) + min(Id))*100, 'Output current ripple (%)');

Pin = mean2(Vs_a*Is_a + Vs_b*Is_b + Vs_c*Is_c);
display(Pin, 'Avg input power');
display(PF(Vs_a, Is_a), 'Input power factor (ph A)');
display(PF(Vs_b, Is_b), 'Input power factor (ph B)');
display(PF(Vs_c, Is_c), 'Input power factor (ph C)');

display(max(abs(S_volts{1, 1}.Data)), 'Max thyristor voltage');
display(mean2(S_amps{1, 1}), 'Avg thyristor current');
display(RMS(S_amps{1, 1}), 'RMS thyristor current');
display(mean2(S_volts{1, 1}*S_amps{1, 1}), 'Avg thyristor power (W / thyristor)');
display(Pin - Pout, 'Total losses (Pout - Pin)');
Ploss_thryistors = 0;
for n = 1:6
   Ploss_thryistors = Ploss_thryistors + mean2(S_volts{n, 1}*S_amps{n, 1});
end
display(Ploss_thryistors, 'Total losses (sum of thyristors)');
display(Pout/Pin * 100, 'Converter efficiency (%)');