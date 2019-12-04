run_sim = [false, true];


%% Circuit calculations
%% Steady-State AC calculations to determine relative resistive & capacitive values
%  Note that once the DIAC starts firing, the capacitor voltages rise
%  somewhat, so it sustains firing at a higher potentiometer resistance
%  than what it starts firing at.
C1 = 0.1e-6;
C2 = 0.1e-6;
R1 = 3.3e3 + 250e3*0.45;
R2 = 15e3;
Vs = 220; % RMS phase-to-ground
fs = 50;

Xc1 = -1i/(2*pi*fs*C1);
Xc2 = -1i/(2*pi*fs*C2);

Ir1 = Vs / (R1 + (Xc1*(R2 + Xc2)) / (Xc1 + R2 + Xc2));
V1 = Vs - Ir1*R1;
Ic1 = V1 / Xc1;
Ic2 = V1 / (R2 + Xc2);
V2 = V1 - R2*Ic2;
V = [Vs V1 V2]';
display([abs(V)*sqrt(2) rad2deg(angle(V))], 'Control voltages (mag, angle)');

%% Setup
% Define window of time for plotting since some (negative) simulation time
% is added for settling to steady state.
tstart = 0;
tstop = 0.020;

% Scenario list has description, alpha, and Ea for each of the scenarios
% to be simulated. Ea assumes operation at vd_nom.
scenarios = { ...
    'Starting', '350e3', '0';
    'No Load', '50e3', '171'; ...
    'Kettle Load', '47.5e3', '164'};
vd_nom = [0, 175, 175];

%% Open model. Same model for all cases
model = 'triac_diac';
open(model);
% Save graphic of model
print(strcat('-s', model), strcat('figs/MODEL_', model, '.png'), '-dpng');

if run_sim(1)
    %% Simulation Run #1: Small R Load
    %  First run some cases with a small load, varying the potentiometer to see what range of output is possible.
    fig = figure(1);
    clf('reset');
    r_var = 250e3 * [0.001 0.2 0.4 0.6 0.8 1.0 1.2 1.4];
    for n = 1:length(r_var)
        set_param(strcat(model, '/R2'), 'Resistance', num2str(r_var(n)));
        set_param(strcat(model, '/Ea'), 'Amplitude', '0');
        set_param(strcat(model, '/Za'), 'BranchType', 'R');
        set_param(strcat(model, '/Za'), 'Resistance', '100');
        % Run the simulation and get the output into variables
        sim(model);

        % Get simulation output data
        Vl = logsout.get('Vl').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vl').Values, tstart, tstop));
        Il = logsout.get('Il').Values.resample(tstart).append(getsampleusingtime(logsout.get('Il').Values, tstart, tstop));
        
        display(r_var(n), 'R2');
        display(mean2(Vl), 'Average Vl');

        figure(1);
        plot_VI(Vl, Il, strcat('load}, R_2=', num2str(r_var(n)/1e3), ' kΩ{'));

    end
    save_figs('triac_diac_small_Rload');
end

if run_sim(2)
    %% Simulation Run #2: Motor at no load
    fig = figure(1);
    clf('reset');
    r_var = [];
    for n = 1:length(scenarios)
        set_param(strcat(model, '/R2'), 'Resistance', scenarios{n, 2});
        set_param(strcat(model, '/Ea'), 'Amplitude', scenarios{n, 3});
        set_param(strcat(model, '/Za'), 'BranchType', 'RL');
        set_param(strcat(model, '/Za'), 'Resistance', '0.8');
        % Run the simulation and get the output into variables
        sim(model);

        % Get simulation output data
        Vl = logsout.get('Vl').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vl').Values, tstart, tstop));
        Il = logsout.get('Il').Values.resample(tstart).append(getsampleusingtime(logsout.get('Il').Values, tstart, tstop));
        
        display(scenarios{n, 2}, 'R2');
        display(mean2(Vl), 'Average Vl');

        figure(1);
        plot_VI(Vl, Il, scenarios{n, 1});

    end
    save_figs('triac_diac_output_vi');
end
