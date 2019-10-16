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
> Initial speed (rad/s) = 1500 RPM / (60 s/min) * 2*pi/rotation **= 157 rad/s**  
> Initial field current (A) = 220 V / 208 ohms **= 1.06 A**

Unknown but required parameters:

> Viscous friction coeffecient Bm (N.m.s)  


Non-required parameters:

> Viscous friction coeffecient Bm (N.m.s) **= 0**  
> Coulomb friction torque Tf (N.m) **= 0**  
 
