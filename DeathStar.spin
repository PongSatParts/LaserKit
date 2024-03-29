{{
''***********************************************************************************
''*  Title:                                                                         *
''*  DeathStar.spin                                                                 *
''*  A fun control Object for 12mA & 1.5mW OPV300 laser diodes                      *
''*  Author: Blaze Sanders                                                          *
''*  Copyright (c) 2011 Solar System Express (Sol-X) LLC                            *
''*  See end of file for terms of use.                                              *
''***********************************************************************************
''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: 1 out of 8                                          *
''*                                                                                 *   
''*  This code controls OPV300 laser diodes, by controlling the amount of current   *
''*  sourced to the laser diodes; from a varying number on 40 mA I/O pins with      *
''*  current limiting resistors, for a set duration of time.                         *
''***********************************************************************************
''*  Circuit Diagram can be found at solarsystemexpress.com/death-star-in-leo.html  *                                                                *
''***********************************************************************************
''*  Detailed Description:                                                          *
''*  Software IDE's, datasheets, getting start guides and demo code can be found at *
''*  www.solarsystemexpress.com/software.html                                       * 
''***********************************************************************************
''*  Theory of Operation:                                                           *
''*  See YourProject.spin and GDB Hello World.spin for demos using the Pong Sat API *
''***********************************************************************************                                                        

                                        Suggested Circuit (Sol-X)
                            
  ┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬ (anade) LASER DIODE (cathode) ─┬       
  │   │   │   │   │   │   │   │   │   │   │   │                                │
                                     (Twelve 1300 Ohm resistors)   │                                                                                             
  │   │   │   │   │   │   │   │   │   │   │   │                                │                                                                           
  ┻   ┻   ┻   ┻   ┻   ┻   ┻   ┻   ┻   ┻   ┻   ┻                                 
  P0  P1  P2  P3  P4  P5  P6  P7  P8  P9  P10 P11                             0v                                              

}}

          

CON 'Global Constants 

'---Useful constants--- 
HIGH = 1
LOW = 0

OUTPUT = 1
INPUT = 0

VAR

'Boolean variable holding the state of the self destruct button
byte SELF_DESTRUCT

'Boolean variable monitoring the location of Luke SkyWalker   
byte LUKE_SKYWALKER

OBJ

'Used to control CPU clock timing functions
'Source URL - http://obex.parallax.com/object/173
TIMING          : "Clock"

PUB Initialize | OK 'Initializes all the laser diodes

SELF_DESTRUCT := false
LUKE_SKYWALKER := false    

PUB FireLaser(Duration, Pin) : MoonDestoryed | NumOfPowerLevels, i 'Turns on a 1.5 mW OPV300 laser diode

''     Action: Turns on a 1.5 mW OPV300 laser diode      
'' Parameters: Duration - Time is seconds the laser should stay on
''             Pin - Pin connected to the laser diode Anode                             
''    Results: Moons get destoryed                      
''+Reads/Uses: None                                               
''    +Writes: None
'' Local Vars: None                                     
''      Calls: None
''        URL: http://www.solarsystemexpress.com/death-star-in-leo.html

If (SELF_DESTRUCT == true OR LUKE_SKYWALKER == true )
  MoonDestoryed := false

Else
  MoonDestoryed := true

  'Power UP
  DIRA[Pin] := OUTPUT
  OUTA[Pin] := HIGH

  TIMING.PauseSec(Duration)

  'Power DOWN
  DIRA[Pin] := OUTPUT
  OUTA[Pin] := LOW


return MoonDestoryed 

PUB FireLasers(PercentPower, Duration, NumberOfPins) : MoonDestoryed | NumOfPowerLevels, i 'Turns on a 1.5 mW OPV300 laser diode

''     Action: Turns on a 1.5 mW OPV300 laser diode      
'' Parameters: PercentPower -  Percent of 12 mA current input into laser 
''             Duration - Time is seconds the laser should stay on
''             NumberOfPins - Number of (12 / NumberOfPins) mA I/O pins connected to laser diode (1 to 12)                             
''    Results: Moons get destoryed                      
''+Reads/Uses: None                                               
''    +Writes: None
'' Local Vars: None                                     
''      Calls: None
''        URL: http://www.solarsystemexpress.com/death-star-in-leo.html

NumOfPowerLevels :=  (PercentPower * NumberOfPins) / 100

If (SELF_DESTRUCT == true OR LUKE_SKYWALKER == true )
  MoonDestoryed := false

Else
  MoonDestoryed := true

  'Power UP
  Repeat i from 1 to NumOfPowerLevels
    DIRA[i] := OUTPUT
    OUTA[i] := HIGH

  TIMING.PauseSec(Duration)

  'Power DOWN
  Repeat i from 1 to NumOfPowerLevels
    DIRA[i] := OUTPUT
    OUTA[i] := LOW


return MoonDestoryed
