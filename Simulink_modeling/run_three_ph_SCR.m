%% Setup
% Define window of time for plotting since some (negative) simulation time
% is added for settling to steady state.
tstart = 0;
tstop = 0.020;

% Scenario list has description, alpha, and Ea for each of the scenarios
% to be simulated. Ea assumes operation at vd_nom.
scenarios = { ...
    'Starting', '87', '0';
    'No Load', '53', '171'; ...
    'Kettle Load', '50', '164'; ...
    'Rated Load', '36', '202'};
vd_nom = [0, 175, 175, 220];

VariableNames = {'Load', 'alpha', 'V_IN_RMS', 'I_IN_RMS', ...
    'P_IN', 'Q_IN', 'S_IN', 'PF', 'I_IN_THD_F'};
TIN = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string', 'string'}, repmat({'double'}, 1, length(VariableNames)-2)], ...
    'VariableNames', VariableNames);
TIN{:, 1:2} = scenarios(:, 1:2);

VariableNames = {'Load', 'alpha', 'V_OUT_AVG', 'V_O_Ripple', 'I_OUT_AVG', ...
    'I_O_Ripple', 'P_OUT', 'Efficiency'};
TOUT = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string', 'string'}, repmat({'double'}, 1, length(VariableNames)-2)], ...
    'VariableNames', VariableNames);
TOUT{:, 1:2} = scenarios(:, 1:2);

VariableNames = {'Load', 'alpha', 'I_AVG', 'I_RMS', 'V_MAX_REV', 'V_MAX_FWD', ...
    'P_LOSS'};
TTHY = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string', 'string'}, repmat({'double'}, 1, length(VariableNames)-2)], ...
    'VariableNames', VariableNames);
TTHY{:, 1:2} = scenarios(:, 1:2);


fig = figure(1);
clf('reset');

%% Open model. Same model for all cases
model = 'three_ph_SCR';
open(model);
% Save graphic of model
print(strcat('-s', model), strcat('figs/MODEL_', model, '.png'), '-dpng');


for n = 1:length(scenarios)
    %% Set up model
    set_param(strcat(model, '/alpha'), 'value', scenarios{n, 2});
    set_param(strcat(model, '/Ea'), 'Amplitude', scenarios{n, 3});

    %% Run the simulation and get the output into variables
    sim(model);
    
    % Get simulation output data
    Vs = logsout.get('Vs').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vs').Values(1), tstart, tstop));
    Vs.Data = Vs.Data(:, 1);
    Is = logsout.get('Is').Values(1).resample(tstart).append(getsampleusingtime(logsout.get('Is').Values(1), tstart, tstop));
    Is.Data = Is.Data(:, 1);
    Vd = logsout.get('Vd').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vd').Values, tstart, tstop));
    %Id = logsout.get('Id').Values.resample(tstart).append(getsampleusingtime(logsout.get('Id').Values, tstart, tstop));
    Vl = logsout.get('Vl').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vl').Values, tstart, tstop));
    Il = logsout.get('Il').Values.resample(tstart).append(getsampleusingtime(logsout.get('Il').Values, tstart, tstop));
    Vthy = logsout.get('S1').Values.Thyristor_voltage.resample(tstart).append(getsampleusingtime(logsout.get('S1').Values.Thyristor_voltage, tstart, tstop));
    Ithy = logsout.get('S1').Values.Thyristor_current.resample(tstart).append(getsampleusingtime(logsout.get('S1').Values.Thyristor_current, tstart, tstop));

    %% Calculate summary values
    TIN.V_IN_RMS(n) = RMS(Vs);
    TIN.I_IN_RMS(n) = RMS(Is);
    TIN.P_IN(n) = mean2(Vs*Is);
    TIN.S_IN(n) = TIN.V_IN_RMS(n)*TIN.I_IN_RMS(n);
    TIN.Q_IN(n) = sqrt(TIN.S_IN(n)^2 - TIN.P_IN(n)^2);
    TIN.PF(n) = TIN.P_IN(n) / TIN.S_IN(n);
    %TIN.phi(n) = rad2deg(acos(T.PF(n)));
    TIN.I_IN_THD_F(n) = THD(Is, 50)*100;
    
    TOUT.V_OUT_AVG(n) = mean2(Vl);
    TOUT.V_O_Ripple(n) = max(Vl) - min(Vl);
    TOUT.I_OUT_AVG(n) = mean2(Il);
    TOUT.I_O_Ripple(n) = max(Il) - min(Il);
    TOUT.P_OUT(n) = mean2(Vl*Il);
    TOUT.Efficiency(n) = TOUT.P_OUT(n) ./ (3*TIN.P_IN(n)) * 100;
    
    TTHY.I_AVG(n) = mean2(Ithy);
    TTHY.I_RMS(n) = RMS(Ithy);
    TTHY.V_MAX_REV(n) = -1*min(Vthy);
    TTHY.V_MAX_FWD(n) = max(Vthy);
    TTHY.P_LOSS(n) = mean2(Vthy*Ithy);
        
    display(n, 'Scenario');
    display(TOUT.V_OUT_AVG(n), 'Average output voltage');
    % Check output voltage. If it's too far off, the calcs won't be
    % accurate.
    if n > 1 && abs(TOUT.V_OUT_AVG(n) - vd_nom(n)) > 1
        disp('Check firing angle!!');
        
    end
    
    %% Load Voltage & Current Plot
    figure(1);
    plot_VI(Vl, Il, scenarios{n, 1});
    

end

figure(1);
save_figs('3ph_SCR_output_vi');

save_table(TIN, '3ph_SCR_summary_in', 'Simulation Summary (Input Side)');
save_table(TOUT, '3ph_SCR_summary_out', 'Simulation Summary (Output Side)');
save_table(TTHY, '3ph_SCR_Thyristor', 'Thyristor Key Values');