run_sim = [false, true];


% Circuit calculations
%  Steady-State AC calculations to determine relative resistive & capacitive values
%  Note that once the DIAC starts firing, the capacitor voltages rise
%  somewhat, so it sustains firing at a higher potentiometer resistance
%  than what it starts firing at.
C1 = 0.1e-6;
C2 = 0.1e-6;
R1 = 1e3;
R2 = 250e3*0.45;
R3 = 15e3;
Vs = 220; % RMS phase-to-ground
fs = 50;

Xc1 = -1i/(2*pi*fs*C1);
Xc2 = -1i/(2*pi*fs*C2);

Ir1 = Vs / (R1 + R2 + (Xc1*(R3 + Xc2)) / (Xc1 + R3 + Xc2));
V1 = Vs - Ir1*(R1 + R2);
Ic1 = V1 / Xc1;
Ic2 = V1 / (R3 + Xc2);
V2 = V1 - R3*Ic2;
V = [Vs V1 V2]';
display([abs(V)*sqrt(2) rad2deg(angle(V))], 'Control voltages (mag, angle)');

% Setup
% Define window of time for plotting since some (negative) simulation time
% is added for settling to steady state.
tstart = 0;
tstop = 0.040;

% Scenario list has description, alpha, and Ea for each of the scenarios
% to be simulated. Ea assumes operation at vd_nom.
scenarios = { ...
    'Starting', '137e3', '0';
    'No Load', '21e3', '171'; ...
    'Kettle Load', '17e3', '164'};
vd_nom = [0, 175, 175];

% Open model. Same model for all cases
model = 'triac_diac';
open(model);
% Save graphic of model
print(strcat('-s', model), strcat('figs/MODEL_', model, '.png'), '-dpng');

if run_sim(1)
    %% Simulation Run #1: Small R Load
    %  First run some cases with a small load, varying the potentiometer to see what range of output is possible.
    fig = figure(1);
    clf('reset');
    r_var = 240e3 * [0.001 0.2 0.4 0.6 0.8 1.0];
    for n = 1:length(r_var)
        set_param(strcat(model, '/R1'), 'Resistance', num2str(r_var(n)));
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

VariableNames = {'Load', 'R2', 'V_IN_RMS', 'I_IN_RMS', ...
    'P_IN', 'Q_IN', 'S_IN', 'PF', 'I_IN_THD_F'};
TIN = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string', 'string'}, repmat({'double'}, 1, length(VariableNames)-2)], ...
    'VariableNames', VariableNames);
TIN{:, 1:2} = scenarios(:, 1:2);

VariableNames = {'Load', 'V_OUT_AVG', 'V_O_Ripple', 'I_OUT_AVG', ...
    'I_O_Ripple', 'P_OUT', 'Efficiency'};
TOUT = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string'}, repmat({'double'}, 1, length(VariableNames)-1)], ...
    'VariableNames', VariableNames);
TOUT{:, 1} = scenarios(:, 1);

VariableNames = {'Load', 'I_AVG', 'I_RMS', 'V_MAX', 'P_LOSS'};
Tdiode = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string'}, repmat({'double'}, 1, length(VariableNames)-1)], ...
    'VariableNames', VariableNames);
Tdiode{:, 1} = scenarios(:, 1);

VariableNames = {'Load', 'I_AVG', 'I_RMS', 'V_MAX', 'P_LOSS'};
Ttriac = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string'}, repmat({'double'}, 1, length(VariableNames)-1)], ...
    'VariableNames', VariableNames);
Ttriac{:, 1} = scenarios(:, 1);

VariableNames = {'Load', 'C1_I_RMS', 'C1_V_MAX', 'C2_I_RMS', 'C2_V_MAX'};
Tc = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string'}, repmat({'double'}, 1, length(VariableNames)-1)], ...
    'VariableNames', VariableNames);
Tc{:, 1} = scenarios(:, 1);

VariableNames = {'Load', 'R1_I_RMS', 'R1_P', 'R2_I_RMS', 'R2_P', 'R3_I_RMS', 'R3_P'};
Tr = table('Size', [length(scenarios), length(VariableNames)], ...
    'VariableTypes', [{'string'}, repmat({'double'}, 1, length(VariableNames)-1)], ...
    'VariableNames', VariableNames);
Tr{:, 1} = scenarios(:, 1);


if run_sim(2)
    %% Simulation Run #2: Motor at no load
    fig = figure(1);
    clf('reset');
    r_var = [];
    for n = 1:length(scenarios)
        set_param(strcat(model, '/R1'), 'Resistance', scenarios{n, 2});
        set_param(strcat(model, '/Ea'), 'Amplitude', scenarios{n, 3});
        set_param(strcat(model, '/Za'), 'BranchType', 'RL');
        set_param(strcat(model, '/Za'), 'Resistance', '0.8');
        % Run the simulation and get the output into variables
        sim(model);

        % Get simulation output data
        Vs = logsout.get('Vs').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vs').Values(1), tstart, tstop));
        Vs.Data = Vs.Data(:, 1);
        Is = logsout.get('Is').Values(1).resample(tstart).append(getsampleusingtime(logsout.get('Is').Values(1), tstart, tstop));
        Is.Data = Is.Data(:, 1);
        Vl = logsout.get('Vl').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vl').Values, tstart, tstop));
        Il = logsout.get('Il').Values.resample(tstart).append(getsampleusingtime(logsout.get('Il').Values, tstart, tstop));
        Vdiode = logsout.get('D1').Values.Diode_voltage.resample(tstart).append(getsampleusingtime(logsout.get('D1').Values.Diode_voltage, tstart, tstop));
        Idiode = logsout.get('D1').Values.Diode_current.resample(tstart).append(getsampleusingtime(logsout.get('D1').Values.Diode_current, tstart, tstop));
        Vtriac = logsout.get('Vtriac').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vtriac').Values, tstart, tstop));
        Itriac = logsout.get('Itriac').Values.resample(tstart).append(getsampleusingtime(logsout.get('Itriac').Values, tstart, tstop));
        Vdiac = logsout.get('Vdiac').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vdiac').Values, tstart, tstop));
        Idiac = logsout.get('Idiac').Values.resample(tstart).append(getsampleusingtime(logsout.get('Idiac').Values, tstart, tstop));
        Vc1 = logsout.get('Vc1').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vc1').Values, tstart, tstop));
        Ic1 = logsout.get('Ic1').Values.resample(tstart).append(getsampleusingtime(logsout.get('Ic1').Values, tstart, tstop));
        Vc2 = logsout.get('Vc2').Values.resample(tstart).append(getsampleusingtime(logsout.get('Vc2').Values, tstart, tstop));
        Ic2 = logsout.get('Ic2').Values.resample(tstart).append(getsampleusingtime(logsout.get('Ic2').Values, tstart, tstop));
        Ir1 = logsout.get('Ic2').Values.resample(tstart).append(getsampleusingtime(logsout.get('Ir1').Values, tstart, tstop));
        Ir2 = Ir1;
        Ir3 = (Vc1 - Vc2) / R3;
        
        
        display(scenarios{n, 2}, 'R2');
        display(mean2(Vl), 'Average Vl');
        
        %% Calculate summary values
        TIN.V_IN_RMS(n) = RMS(Vs);
        TIN.I_IN_RMS(n) = RMS(Is);
        TIN.P_IN(n) = mean2(Vs*Is);
        TIN.S_IN(n) = TIN.V_IN_RMS(n)*TIN.I_IN_RMS(n);
        TIN.Q_IN(n) = sqrt(TIN.S_IN(n)^2 - TIN.P_IN(n)^2);
        TIN.PF(n) = TIN.P_IN(n) / TIN.S_IN(n);
        TIN.I_IN_THD_F(n) = THD(Is, 50)*100;

        TOUT.V_OUT_AVG(n) = mean2(Vl);
        TOUT.V_O_Ripple(n) = max(Vl) - min(Vl);
        TOUT.I_OUT_AVG(n) = mean2(Il);
        TOUT.I_O_Ripple(n) = max(Il) - min(Il);
        TOUT.P_OUT(n) = mean2(Vl*Il);
        TOUT.Efficiency(n) = TOUT.P_OUT(n) ./ TIN.P_IN(n) * 100;
        
        Tdiode.I_AVG(n) = mean2(Idiode);
        Tdiode.I_RMS(n) = RMS(Idiode);
        Tdiode.V_MAX(n) = max(abs(Vdiode.Data));
        Tdiode.P_LOSS(n) = mean2(Vdiode*Idiode);
        
        triac_abs_I = Itriac;
        triac_abs_I.Data = abs(triac_abs_I.Data);
        Ttriac.I_AVG(n) = mean2(triac_abs_I);
        Ttriac.I_RMS(n) = RMS(Itriac);
        Ttriac.V_MAX(n) = max(abs(Vtriac.Data));
        Ttriac.P_LOSS(n) = mean2(Vtriac*Itriac);
        
        Tc.C1_I_RMS(n) = RMS(Ic1)*1000;
        Tc.C1_V_MAX(n) = max(abs(Vc1.Data));
        Tc.C2_I_RMS(n) = RMS(Ic2)*1000;
        Tc.C2_V_MAX(n) = max(abs(Vc2.Data));
        
        % Resistor current and power values are so small that scaling them
        % by 1000 to mA and mW makes sense.
        Tr.R1_I_RMS(n) = RMS(Ir1)*1000;
        Tr.R2_I_RMS(n) = RMS(Ir2)*1000;
        Tr.R3_I_RMS(n) = RMS(Ir3)*1000;
        Tr.R1_P(n) = Tr.R1_I_RMS(n)^2*R1/1000;
        Tr.R2_P(n) = Tr.R2_I_RMS(n)^2*eval(scenarios{n, 2})/1000;
        Tr.R3_P(n) = Tr.R3_I_RMS(n)^2*R3/1000; 


        figure(1);
        hold on;
        plot_VI(Vl, Il, scenarios{n, 1});
        
        if n == 3
           figure(2);
           clf('reset');
           plot_VI(Vdiac, Idiac, 'diac');
           save_figs('triac_diac_control_v');
           
        end

    end
    figure(1);
    save_figs('triac_diac_output_vi');
    
    save_table(TIN, 'triac_diac_summary_in', 'Simulation Summary (Input Side)');
    save_table(TOUT, 'triac_diac_summary_out', 'Simulation Summary (Output Side)');
    save_table(Tdiode, 'triac_diac_diode_values', 'Rectifier Diode Key Values');
    save_table(Ttriac, 'triac_diac_triac_values', 'Triac Key Values');
    save_table(Tc, 'triac_diac_capacitor_values', 'Capacitors Key Values');
    save_table(Tr, 'triac_diac_resistor_values', 'Resistors Key Values');
end
