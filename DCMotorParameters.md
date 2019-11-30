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

> Armature resistance and inductance Ra (ohms) and La (H) **= [0.8 0.0125]**  
> Field resistance and inductance Rf (ohms) and Lf (H) **= [210 23]**  

Calculable parameters:

*Assuming that the simulation starts with the motor operating at rated speed and voltage.*

> Field-armature mutual inductance Laf (H)  
> Rated speed (rad/s) = 1500 RPM / (60 s/min) * 2*pi/rotation **= 157 rad/s**  
> Rated field current (A) = 220 V / 208 ohms **= 1.06 A**

Unknown but required parameters:

> Viscous friction coeffecient Bm (N.m.s)  


Non-required parameters:

> Viscous friction coeffecient Bm (N.m.s) **= 0**  
> Coulomb friction torque Tf (N.m) **= 0**  

The equivalent circuit parameters for the DC motor are the following:
Vt = Ea + Ia*Ra
Ea = Ka * phi * wm
T = Ka * phi * Ia

Ra = 0.8 Ohms.

At startup, wm = 0, so Ea = 0.

Prated = (5.5 HP)*(746 W/HP) = 4103 W. This is at the mechanical output.  
At rated speed of 157 rad/s, rated torque is (4103 W)/(157 rad/s) = 26.1 N-m.  

Rated electrical input is (220 V)*(23.4 A) = 5148 W. So rated efficiency is
approximately 0.80.
Resistive losses = (23.4 A)^2 * (0.8 Ohms) = 438 W.

At full load Vt = 220 V and Ea = Vt - Ia*Ra = 220 V - (0.8 Ohms)*(22.4 A)  
= 202 V.

Ka * phi = T/Ia = (26.1 N-m)/(22.4 A) = 1.17  
Ka * phi = Ea/wm = (202 V)/(157 rad/s) = 1.29

Since the two values for Ka*phi are not exactly the same, my way of using the
DC motor equations for rated load must not be quite right, but since the
difference is relatively small, it is at least approximate. In any case, we
don't really need to use that constant, we can just use Pmech = Ea*Ia.

This assumes rated field current of 1.06 A is applied.

Based on these numbers, using the motor to drive the AC generator with
a 1600 W resistive load (water kettle), the DC input will be approximately  
Vt = 220 V  
Ia*Ea = 1600 W / 0.8 efficiency = 2000 W estimated on mechanical side  
Ea = (2000 W)/Ia  
(2000 W)/Ia = 220 V - Ia*(0.8 Ohms)  
2000 W = (220 V)*Ia - Ia^2 * (0.8 Ohms)  
0 = 0.8*Ia^2 - 220*Ia + 2000  
Ia = (220 + sqrt(220**2 - 4(0.8)(2000))) / (2*0.8) = 9.4 A or 266 A.  
The logical solution is 9.4 A.  
Ea = (2000 W)/(9.4 A) = 213 V.

Since the kettle is less than full load, the motor will operate at higher
than rated speed if the rated voltage is applied.

wm = Ea / (Ka*phi) = (213 V)/1.29 = 165 rad/s. This is 165/157 = 105% of
rated speed.


