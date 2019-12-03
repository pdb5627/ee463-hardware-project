%% Setup
% Define window of time for plotting since some (negative) simulation time
% is added for settling to steady state.
tstart = 0;
tstop = 0.020;

% Scenario list has description, alpha, and Ea for each of the scenarios
% to be simulated. Ea assumes operation at vd_nom.
scenarios = { ...
    'Starting', '4', '0';
    'No Load', '25', '171'; ...
    'Kettle Load', '41', '164'; ...
    'Rated Load', '75', '202'};
vd_nom = [0, 175, 175, 220];

VariableNames = {'Load', 'D', 'V_IN_RMS', 'I_IN_RMS', ...
    'P_IN', 'Q_IN', 'S_IN', 'PF', 'I_IN_THD_F'};
TIN = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string', 'string'}, repmat({'double'}, 1, length(VariableNames)-2)], ...
    'VariableNames', VariableNames);
TIN{:, 1:2} = scenarios(:, 1:2);

VariableNames = {'Load', 'D', 'VD_AVG', 'VD_Ripple', 'ID_OUT_AVG', ...
    'ID_O_Ripple', 'PD_OUT'};
TDC = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string', 'string'}, repmat({'double'}, 1, length(VariableNames)-2)], ...
    'VariableNames', VariableNames);
TDC{:, 1:2} = scenarios(:, 1:2);

VariableNames = {'Load', 'D', 'V_OUT_AVG', 'V_O_Ripple', 'I_OUT_AVG', ...
    'I_O_Ripple', 'P_OUT', 'Efficiency'};
TOUT = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string', 'string'}, repmat({'double'}, 1, length(VariableNames)-2)], ...
    'VariableNames', VariableNames);
TOUT{:, 1:2} = scenarios(:, 1:2);

VariableNames = {'Load', 'D', 'I_AVG', 'I_RMS', 'V_MAX_REV', 'P_LOSS'};
Tdiode = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string', 'string'}, repmat({'double'}, 1, length(VariableNames)-2)], ...
    'VariableNames', VariableNames);
Tdiode{:, 1:2} = scenarios(:, 1:2);

VariableNames = {'Load', 'D', 'I_AVG', 'I_RMS', 'V_MAX', 'P_LOSS'};
Tmosfet = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string', 'string'}, repmat({'double'}, 1, length(VariableNames)-2)], ...
    'VariableNames', VariableNames);
Tmosfet{:, 1:2} = scenarios(:, 1:2);

VariableNames = {'Load', 'D', 'I_AVG', 'I_RMS', 'V_MAX_REV', 'P_LOSS'};
Tdiode2 = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string', 'string'}, repmat({'double'}, 1, length(VariableNames)-2)], ...
    'VariableNames', VariableNames);
Tdiode2{:, 1:2} = scenarios(:, 1:2);


fig = figure(1);
clf('reset');

%% Open model. Same model for all cases
model = 'three_ph_rect_buck';
open(model);
% Save graphic of model
print(strcat('-s', model), strcat('figs/MODEL_', model, '.png'), '-dpng');


for n = 1:length(scenarios)
    %% Set up model
    set_param(strcat(model, '/PWM'), 'PulseWidth', scenarios{n, 2});
    set_param(strcat(model, '/Ea'), 'Amplitude', scenarios{n, 3});
    switch n
        case 1
            set_param(strcat(model, '/C2'), 'InitialVoltage', '10.8');
            set_param(strcat(model, '/Za'), 'InitialCurrent', '13.5');
        case 2
            set_param(strcat(model, '/C2'), 'InitialVoltage', '175');
            set_param(strcat(model, '/Za'), 'InitialCurrent', '5.7');
        case 3
            set_param(strcat(model, '/C2'), 'InitialVoltage', '175');
            set_param(strcat(model, '/Za'), 'InitialCurrent', '16');
        case 4
            set_param(strcat(model, '/C2'), 'InitialVoltage', '220');
            set_param(strcat(model, '/Za'), 'InitialCurrent', '16');
    end

    %% Run the simulation and get the output into variables
    sim(model);
    
    % Get simulation output data
    Vs = logsout.get('Vs').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vs').Values(1), tstart, tstop));
    Vs.Data = Vs.Data(:, 1);
    Is = logsout.get('Is').Values(1).resample(tstart).append(getsampleusingtime(logsout.get('Is').Values(1), tstart, tstop));
    Is.Data = Is.Data(:, 1);
    Vd = logsout.get('Vd').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vd').Values, tstart, tstop));
    Id = logsout.get('Id').Values.resample(tstart).append(getsampleusingtime(logsout.get('Id').Values, tstart, tstop));
    Vl = logsout.get('Vl').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vl').Values, tstart, tstop));
    Il = logsout.get('Il').Values.resample(tstart).append(getsampleusingtime(logsout.get('Il').Values, tstart, tstop));
    Vdiode = logsout.get('S1').Values.Diode_voltage.resample(tstart).append(getsampleusingtime(logsout.get('S1').Values.Diode_voltage, tstart, tstop));
    Idiode = logsout.get('S1').Values.Diode_current.resample(tstart).append(getsampleusingtime(logsout.get('S1').Values.Diode_current, tstart, tstop));
    Vmosfet = logsout.get('Mosfet').Values.MOSFET_voltage.resample(tstart).append(getsampleusingtime(logsout.get('Mosfet').Values.MOSFET_voltage, tstart, tstop));
    Imosfet = logsout.get('Mosfet').Values.MOSFET_current.resample(tstart).append(getsampleusingtime(logsout.get('Mosfet').Values.MOSFET_current, tstart, tstop));
    Vdiode2 = logsout.get('D2').Values.Diode_voltage.resample(tstart).append(getsampleusingtime(logsout.get('D2').Values.Diode_voltage, tstart, tstop));
    Idiode2 = logsout.get('D2').Values.Diode_current.resample(tstart).append(getsampleusingtime(logsout.get('D2').Values.Diode_current, tstart, tstop));
    

    %% Calculate summary values
    TIN.V_IN_RMS(n) = RMS(Vs);
    TIN.I_IN_RMS(n) = RMS(Is);
    TIN.P_IN(n) = mean2(Vs*Is);
    TIN.S_IN(n) = TIN.V_IN_RMS(n)*TIN.I_IN_RMS(n);
    TIN.Q_IN(n) = sqrt(TIN.S_IN(n)^2 - TIN.P_IN(n)^2);
    TIN.PF(n) = TIN.P_IN(n) / TIN.S_IN(n);
    %TIN.phi(n) = rad2deg(acos(T.PF(n)));
    TIN.I_IN_THD_F(n) = THD(Is, 50)*100;
    
    TDC.VD_AVG(n) = mean2(Vd);
    TDC.VD_Ripple(n) = max(Vd) - min(Vd);
    TDC.ID_OUT_AVG(n) = mean2(Id);
    TDC.ID_O_Ripple(n) = max(Id) - min(Id);
    TDC.PD_OUT(n) = mean2(Vd*Id);
    
    TOUT.V_OUT_AVG(n) = mean2(Vl);
    TOUT.V_O_Ripple(n) = max(Vl) - min(Vl);
    TOUT.I_OUT_AVG(n) = mean2(Il);
    TOUT.I_O_Ripple(n) = max(Il) - min(Il);
    TOUT.P_OUT(n) = mean2(Vl*Il);
    TOUT.Efficiency(n) = TOUT.P_OUT(n) ./ (3*TIN.P_IN(n)) * 100;
    
    Tdiode.I_AVG(n) = mean2(Idiode);
    Tdiode.I_RMS(n) = RMS(Idiode);
    Tdiode.V_MAX_REV(n) = -1*min(Vdiode);
    Tdiode.P_LOSS(n) = mean2(Vdiode*Idiode);
    
    Tmosfet.I_AVG(n) = mean2(Imosfet);
    Tmosfet.I_RMS(n) = RMS(Imosfet);
    Tmosfet.V_MAX(n) = max(max(Vmosfet), -1*min(Vmosfet));
    Tmosfet.P_LOSS(n) = mean2(Vmosfet*Imosfet);
    
    Tdiode2.I_AVG(n) = mean2(Idiode2);
    Tdiode2.I_RMS(n) = RMS(Idiode2);
    Tdiode2.V_MAX_REV(n) = -1*min(Vdiode2);
    Tdiode2.P_LOSS(n) = mean2(Vdiode2*Idiode2);
        
    display(n, 'Scenario');
    display(TOUT.V_OUT_AVG(n), 'Average output voltage');
    % Check output voltage. If it's too far off, the calcs won't be
    % accurate.
    if n > 1 && abs(TOUT.V_OUT_AVG(n) - vd_nom(n)) > 1
        disp('Check duty cycle!!');
        
    end
    
    %% Load Voltage & Current Plot
    figure(1);
    plot_VI(Vl, Il, scenarios{n, 1});
    

end

figure(1);
save_figs('3ph_buck_output_vi');

save_table(TIN, '3ph_buck_summary_in', 'Simulation Summary (Input Side)');
save_table(TDC, '3ph_buck_summary_dc', 'Simulation Summary (DC Bus)');
save_table(TOUT, '3ph_buck_summary_out', 'Simulation Summary (Output Side)');
save_table(Tdiode, '3ph_buck_rect_diode', 'Rectifier Diode Key Values');
save_table(Tmosfet, '3ph_buck_mosfet', 'MOSFET Key Values');
save_table(Tdiode2, '3ph_buck_diode2', 'Buck Section Diode Key Values');