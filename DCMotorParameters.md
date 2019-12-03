# EE463 Lab Motor Parameters

The following parameters are given for the DC motor in the EE463 lab to be driven for the hardware project.

From the [nameplate](https://github.com/odtu/ee463/blob/master/Hardware-Project/motor-label.jpg):   

> Pmech = 5.5  
> RPM = 1500  
> VS = 220 V  
> IS = 23.4 A  

From the [hardware lab instructions](https://github.com/odtu/ee463/tree/master/Hardware-Project):  

>    Armature Winding: 0.8 Ω, 12.5 mH  
>    Shunt Winding: 210 Ω, 23 H  
>    Interpoles Winding: 0.27 Ω, 12 mH  
    
The parameters needed by the MATLAB Simulink Power Toolbox DC motor model are the following:

> Armature resistance and inductance Ra (ohms) and La (H)  
> Field resistance and inductance Rf (ohms) and Lf (H)  
> Field-armature mutual inductance Laf (H)  
> Total inertia J (kg.m^2)  
> Viscous friction coeffecient Bm (N.m.s)  
> Coulomb friction torque Tf (N.m)  
> Initial speed (rad/s)  
> Initial field current (A)  
    
Some parameters are given directly and can be simply entered into the Simulink model. Other parameters are available with some calculation.

Directly available parameters:

> Armature resistance and inductance Ra (Ω) and La (H) **= [0.8 0.0125]**  
> Field resistance and inductance Rf (Ω) and Lf (H) **= [210 23]**  

Calculable parameters:

*Assuming that the simulation starts with the motor operating at rated speed and voltage.*

> Field-armature mutual inductance Laf (H) **= 1.11 H**  
> Rated speed (rad/s) = 1500 RPM / (60 s/min) * 2*pi/rotation **= 157 rad/s**  
> Rated field current (A) = 220 V / 208 Ω **= 1.06 A**

Non-required parameters:

> Viscous friction coeffecient Bm (N.m.s) **= 0**  
> Coulomb friction torque Tf (N.m) **= 2.64**  

The equivalent circuit parameters for the DC motor are the following:
Vt = Ea + Ia*Ra
Ea = Laf * If * wm
T = Laf * If * Ia

Ra = 0.8 Ω.

## Startup

At startup, wm = 0, so Ea = 0.

## Rated Load

Prated = (5.5 HP)*(746 W/HP) = 4103 W. This is at the mechanical output.  
At rated speed of 157 rad/s, rated mechanical torque is  
(4103 W)/(157 rad/s) = 26.12 N-m.

Rated electrical input is (220 V)*(23.4 A) = 5148 W. So rated efficiency is
approximately 0.80.  
Resistive losses = (23.4 A)^2 * (0.8 Ω) = 438 W.  
Remaining losses are in the field resistance and friction.

At full load Vt = 220 V and Ea = Vt - Ia * Ra = 220 V - (0.8 Ω)*(22.4 A)  
= 202 V.

Since the motor is rated for a shunt configuration,  
If = 220 V / 210 Ω = 1.05 A

Laf = Ea / (If * wm) = (202 V)/(1.05 A * 157 rad/s) = 1.23 H  
Laf*If = 1.05 A * 1.23 H = 1.29

The electrical torque can be calculated as  
Ea * Ia / wm = (202 V) * (22.4 A) / (157 rad/s) = 28.76 N-m.

Since the rated output mechanical torque is 26.1 N-m, apparently there
are additional mechanical torque losses. The simplest is to model them as
Coulomb friction losses (i.e. constant torque):
Te - T = 28.76 N-m - 26.12 N-m = 2.64 N-m

At rated speed, this works out to friction loss of  
2.64 N-m * 157 rad/s = 415 W.

## No Load, Vt = 175 V

At no-load, this friction loss will have the following circuit values:  
Vt = 175 V  

Neglecting voltage drop on the armature winding such that Ea = Vt,
speed can be estimated as  
Ea / (Laf * wm) = 175 V / 1.29 = 136 rad/s

Friction losses can be estimated as  
2.65 N-m * 136 rad/s = 360 W.

Estimating additionally that the connected synchronous maching has a similar
amount of friction, the total "no load" load is estimated as 700 W.
Ia*Ea = 700 W  
Ea = (700 W)/Ia  
(700 W)/Ia = 175 V - Ia*(0.8 Ω)  
700 W = (175 V/Ia - Ia^2 * (0.8 Ω)  
0 = 0.8*Ia^2 - 175*Ia + 700  
Ia = (175 - sqrt(175^2 - 4*0.8*700)) / (2*0.8) = 4.1 A.  
Ea = (700 W)/(4.1 A) = 171 V.

No-load speed can be calculated as
wm = Ea / (Laf*If) = (171 V)/1.29 = 133 rad/s.  
This is 133/157 = 85% of rated speed.

## Kettle Load, Vt = 175 V

Based on these numbers, using the motor to drive the AC generator with
a 1600 W resistive load (water kettle), the DC input will be approximately  
Vt = 175 V  
Ia*Ea = 1600 W + 700 W = 2300 W estimated on mechanical side  
Ea = (2300 W)/Ia  
(2300 W)/Ia = 175 V - Ia*(0.8 Ω)  
2300 W = (175 V)*Ia - Ia^2 * (0.8 Ω)  
0 = 0.8*Ia^2 - 175*Ia + 2300  
Ia = (175 - sqrt(175**2 - 4(0.8)(2300))) / (2*0.8) = 14.0 A.  
Ea = (2300 W)/(14.0 A) = 164 V.

wm = Ea / (Laf*If) = (164 V)/1.29 = 127 rad/s.  
This is 127/157 = 81% of rated speed.

At wm = 127 rad/s, the estimated 1950 W external mechanical load will have a torque
of T = P/wm = (1950 W) / (127 rad/s) = 15.4 N-m.
