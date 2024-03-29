{{
''***********************************************************************************
''*  Title:                                                                         *
''*  GDB Hello World.spin                                                           *
''*  The first program you should run to get started with the Sol-X GDB             *
''*  Author: Blaze Sanders                                                          *
''*  Copyright (c) 2014 Solar System Express (Sol-X) LLC                            *
''*  See end of file for terms of use.                                              *
''***********************************************************************************
''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: ? out of 8                                          *
''*                                                                                 *   
''*  This code controls the GDB open source hardware:                               *
''*  After to run this program, your GDB will be fully up and running. It will be   *
''*  flashing LEDs and outputting text via the Parallax Series Terminal window.     *
''*  FULL GDB CODE CAN BE FOUND AT https://github.com/solx/GDB                      *
'************************************************************************************
''*  Circuit Diagram can be found at www.solarsystemexpress.com/hardware.html       *                                                                *
''*********************************************************************************** 
}}
CON 'Global Constants 

'Standard clock mode * crystal frequency = 16 * 5 MHz = 80 MHz
_clkmode = xtal1 + pll16x                                               
_xinfreq = 5_000_000

'---Useful constants--- 
HIGH = 1
LOW = 0
OUTPUT = 1
INPUT = 0
AVERAGE = 1
CURRENT = 0
FORWARD = 1
REVERSE = 0
INFINITY = 1
ENABLE = 1
DISABLE = 0

VAR  'Global variables

long  ExampleVariable
   
OBJ  'Additional files you would like imported / included  

'Sol-X API that controls all the GDB hardware function
GDB      : "GDB-API-V0.1.0"

'Sol-X API that controls all the hardware functions of the PongSat kits  
PongSat  : "PongSat-API-V0.1.0"   

'Used to control CPU clock timing functions
'Source URL - http://obex.parallax.com/object/173
TIMING   : "Clock"

'Used to output debugging statments to the Serial Terminal
'Custom Sol-X file updating http://obex.parallax.com/object/521 
DEBUG           : "GDB-SerialMirror"


''Time parameter in Full H-Bridge is not implemented 

PUB Main | i'First method called, like in JAVA 

''     Action: Initializes all the GDB hardware and firmware  
'' Parameters: None                                 
''    Results: Prepares the GDB for user interaction                   
''+Reads/Uses: None                                               
''    +Writes: None
'' Local Vars: i - looping index variable                                  
''      Calls: GDB.LEDControl( ), TIMING.PauseSec( ),
''             TIMING.PauseMSec( ), and GDB.SendText( ) functions
''        URL: http://www.solarsystemexpress.com/store.html

PongSat.Initialize

TIMING.PauseSec(2) ' Pause two seconds

GDB.SendText(STRING("Welcome to the 2014 Space Start Up Weekend!", DEBUG#CR))
GDB.SendText(STRING("Lets keep the New Space revolution going.", DEBUG#CR))
TIMING.PauseSec(2) ' Pause two seconds

'First Yellow LED (Green & Red LED both on through light pipe)
PongSat.LEDControl(7, HIGH)
PongSat.LEDControl(6, HIGH)
TIMING.PauseSec(2) ' Pause two seconds
  

GDB.SendText(STRING("FIRE THE LASERS!", DEBUG#CR)) 

repeat i from 1 to 100
  PongSat.FireLaser(3, 18)
  TIMING.PauseSec(1) ' Pause one second  
  PongSat.FireLaser(6, 18)
  TIMING.PauseSec(1) ' Pause one second
   
GDB.SendText(STRING("HAL 9000 TEST: Hello World… Daisy, Daisy, give me your answer, do, I'm half"))
GDB.SendText(STRING("crazy all for the love of you. It won't be a stylish marriage, I can't afford a"))
GDB.SendText(STRING("carriage, But you'd look sweet upon the seat Of a bicycle built for two."))

TIMING.PauseSec(2) ' Pause two seconds
   
PongSat.LogData

{{ 
PongSat.MeasureLightIntensity


PongSat.TakePicture

PongSat.StartVideoRecording
'Pause five second
TIMING.PauseSec(5)            
PongSat.StopVideoRecording

'PongSat.RecordVideo(5)
}}

return