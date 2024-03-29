{{
''***********************************************************************************
''*  Title:                                                                         *
''*  PongSatKits.spin                                                               *
''*  With the form factor of a ping pong ball, PONGSATs can measure temperature,    *
''*  pressure, gravity loading, cosmic rays and more at altitude of 100,000+ feet   *
''*  Author: Blaze Sanders                                                          *
''*  Copyright (c) 2014 Solar System Express LLC                                    *
''*  See end of file for terms of use.                                              *
''***********************************************************************************
''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: ?5? out of 8                                        *
''*                                                                                 *   
''*  This code controls the open source hardware of five Sol-X Pong Sat kits        *
''*  creating a high level API for the control of the following pieces of hardware: *
''*  1) One temperature & pressure sensor @ -40 to 180 C & 50 to 115 kPa            *    
''*  2) Nine laser diodes @ 850 nm, 1.5 mW and upto 2.5 Gbps                       *
''*  3) One Micro SD Card slot adapter @ 4 GB with FAT16/32 file read/write access  *
''*  4) One Anarean AIR wireless Reciever / Transmitter @ 2.4 GHz and 300 meters    *
''*  5) Three solar panels for sun tracking and trickle recharging @ 4 V and 50 uA  *
''*  6) N add solar panels for sun tracking and trickle recharging @ 4 V and 50 uA  * 
''*  Propeller MIni circuit diagram can be found at                                 *
''*  http://www.parallax.com/downloads/propeller-mini-schematic                     * 
''*  Datasheet can be found at                                                      *
''*  www.parallax.com/downloads/propeller-mini-product-guide                        *
 ''**********************************************************************************                                                         
}}
VAR 'Global variables  

'Store number of cog running this object (0 to 7) 
long  cog

'Array to control direction of 128 MHz general purpose I/O pins P0 - P18
byte HighSpeedIODirectionRegister[19]
'Array to control level output of the general purpose I/O pins P0 - P18  
byte HighSpeedIOOutputRegister[19]
'Array to read input level on of the general purpose I/O pins P0 - P18  
byte HighSpeedIOInputRegister[19]

'Array to store the output levels on upto 19 LED's 
byte LEDArray[19]

'Temporary memory, to hold operational data such as call stacks, parameters and intermediate expression results.
'Use an object like "Stack Length" to determine the optimal length and save memory. http://obex.parallax.com/object/574 
long  PongSatStackPointer[128]

'Global boolean variable that determines wheter debug text is displayed on Parallax Serial Terminal 
byte DEBUG_MODE

CON 'Global Constants 

'---Useful constants--- 
HIGH = 1
LOW = 0

OUTPUT = 1
INPUT = 0

INFINITY = -1  



'--Propeller mini pin configuration--

'Micro SD Card
CARD_DETECT = 0
DATA_BIT_2 = 1
CLOCK_SELECT = 2
SERIAL_DATA_INPUT = 3
SYNCHRONOUS_CLOCK_INPUT =4 
SERIAL_DATA_OUTPUT = 5
DATA_BIT_1 = 6

'64KB (Mini V1.2 - Purchase after Jan 21, 2014) or 32KB(Mini V1.1) I2C Electrically Erasable Programmable Read Only Memory 
I2C_SCL = 28
I2C_SDA = 29
                                                     

OBJ 'Additional files you would like imported / included   

'Used to output debugging statments to the Serial Terminal
'Custom Sol-X file updating http://obex.parallax.com/object/521 
DEBUG           : "GDB-SerialMirror"

'Used to controll a fully operational  Death Star laser diode   
DEATH_STAR      : "DeathStar"

'Used for the measurement of temperature and pressure
'Source URL - http://obex.parallax.com/object/407
TEMP_PRESSURE   : "MPL115A1"

'Used to read and write data to a Micro SD Card using text files
'Source URL - http://obex.parallax.com/object/33
DATA_LOGGING    : "SD_Card_Micro_01"

'Used to create a four channel wireless communication pipeline 
WIRELESS_RX_TX  : "Anarean AIR"

'Used to control a motor via three solar panel inputs     
SOLAR_TRACKING  : "CPC1822"

'Used to measure light intensity 
LIGHT_SENSOR    : "Light2Freq"

'Used to control Electrically Erasable Programmable Read Only Memory
'Source URL - http://obex.parallax.com/object/23 
EEPROM          : "I2C_ROMEngine"

'Used for Analog-to-Digital & Digital-to-Analog Conversion
'Source URL - http://obex.parallax.com/object/370  
ADC_DAC         : "MCP3208"

'Used to control the high power (72 Watt) GDB driver
'Source URL - http://obex.parallax.com/object/334
H_BRIDGE1        : "L298SetMotor"
H_BRIDGE2        : "L298SetMotor"

'Used to control GDB LED's and Low Speed general purpose I/O pins
'Custom Sol-X  file based losely off http://obex.parallax.com/object/170
MUX_DEMUX       : "NLAST4051"

PUB Initialize | OK 'Initializes all the Pong Sat hardware and firmware

DEBUG.start(DEBUG#DEBUG_OUTPUT_PIN, DEBUG#DEBUG_INPUT_PIN, 0, DEBUG#DEBUG_BAUD_RATE)

PUB LEDControl(LEDnumber, State) 'Turns LED's connected to any on the 19 GPIO pins on or off

''     Action: Turns LED's connected to any on the 19 GPIO pins on or off    
'' Parameters: LEDnumber -  LED to control 
''             State - Sets LED level (HIGH = LED on or LOW = LED off)                                 
''    Results: Changes the state of LED's                     
''+Reads/Uses: HighSpeedIODirectionRegister[] & HighSpeedIOOutputRegister[]                                                
''    +Writes: None
'' Local Vars: None                                     
''      Calls: None
''        URL: http://www.parallax.com/downloads/propeller-mini-product-guide

HighSpeedIODirectionRegister[LEDnumber] := OUTPUT
HighSpeedIOOutputRegister[LEDnumber] := State    

return

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
  MoonDestoryed := DEATH_STAR.FireLaser(Duration, Pin)   

return MoonDestoryed 

PUB SetLEDArrayState

PUB FlashLEDs(Frequency, Number) | i, j 'Flashes LED's connected to any on the 19 GPIO pins at a set frequency      

''     Action: Flashes LED's connected to any on the 19 GPIO pins at a set frequency  
'' Parameters: LEDArray -  LED's to control (upto 19 LED possible)
''             Frequency - Frequency in mHz that LED's flash on and off (Valid from 1 mHz 800 kHz)
''             Number - Number of times LED flashes   (-1 = infinity)                         
''    Results: Changes the state of LED's                     
''+Reads/Uses: None                                               
''    +Writes: None
'' Local Vars: i                                     
''      Calls: LEDControl( ) function
''        URL: None

repeat j from 1 to Number
  repeat i from 0 to 18 
    if (LEDArray[i] == HIGH)
      LEDControl(i, HIGH)  

  if (Frequency <= 1000)
    'Wait command for 1 mHz to 1000 mHz (1 Hz)
    waitcnt(clkfreq / (1000/Frequency) + cnt)  
  elseif (Frequency <= 1000000)
    'Wait command for 1,001 to 1,000,000 mHz  (1.001 Hz to 1kHz) 
    waitcnt(clkfreq / (1000000/Frequency) + cnt)   
  elseif (Frequency <= 1000000000)
    'Wait command for 1,000,001 to 800,000,001 mHz (1.001 kHz to 800 kHz)   
    waitcnt(clkfreq / (1000000000/Frequency) + cnt) 
  else
    if(DEBUG_MODE)
      DEBUG.Str(STRING("Invalid LED flashing frequency (> 800 kHz)", DEBUG#CR))
      return
  
  repeat i from 0 to 18 
    if (LEDArray[i] == HIGH)
      LEDControl(i, LOW)

  if(NUmber == INFINITY)
    'Infinity Loop
    FlashLEDs(Frequency, Number)  
      
return

PUB LogData

DATA_LOGGING.demo 

return

PUB MeasureLightIntensity

return
   
PUB SendText(StringPTR) 'Send debug text string to the Parallax Serial Terminal 

''     Action: Send debug text string to the Parallax Serial Terminal  
'' Parameters: StringPTR - Text to output, called using the following code
''                         SendText(STRING("TEXT TO OUTPUT", DEBUG#CR))                               
''    Results: Sends ANSI text string to the Parallax Serial Terminal                 
''+Reads/Uses: None                                               
''    +Writes: None
'' Local Vars: None                                  
''      Calls: DEBUG.tx( ) and DEBUG.Str( ) functions
''        URL: http://obex.parallax.com/object/521  

repeat strsize(StringPTR)
  DEBUG.tx(byte[StringPTR++])

DEBUG.Str(STRING(" ", DEBUG#CR))

return

PUB SendNumber(Value) 'Send debug number string to the Parallax Serial Terminal 

''     Action: Send debug number string to the Parallax Serial Terminal  
'' Parameters: Value - Number to output                            
''    Results: Sends ANSI number string to the Parallax Serial Terminal                 
''+Reads/Uses: None                                               
''    +Writes: None
'' Local Vars: None                                  
''      Calls: DEBUG.dec( ) function
''        URL: http://obex.parallax.com/object/521  

DEBUG.dec(value)

return

PUB GetNumber 'Get a positive or negative number in Decimal, Binary, or HexDecimal format from the Parallax Serial Terminal

''     Action: Get a positive or negative number in Decimal, Binary, or HexDecimal format from the Parallax Serial Terminal  
'' Parameters: None                           
''    Results: Updates a user variable                
''+Reads/Uses: None                                               
''    +Writes: None
'' Local Vars: None                                  
''      Calls: DEBUG.GetNumber( ) function
''        URL: http://obex.parallax.com/object/521  

return DEBUG.GetNumber   

PUB WriteData

PUB ReadData

PRI InitializeEEPROM : OK 'Prepares the GDB 24LC256-E/MF IC for use 

'     Action: Prepares the GDB 24LC256-E/MF IC for use
' Parameters: None                                
'    Results: Start a cog and initializes the GDB pins connected to the 24LC256-E/MF IC                    
'+Reads/Uses: None                                               
'    +Writes: None
' Local Vars: OK - Variable to check if initialization has gone good.                                    
'      Calls: EEPROM.ROMEngineStart( )
'        URL: http://www.digikey.com/schemeit/#nd7

return EEPROM.ROMEngineStart(I2C_SDA, I2C_SCL, 0)
{{

┌───────────────────────────────────────────────────────────────────────────┐
│               Terms of use: MIT License                                   │
├───────────────────────────────────────────────────────────────────────────┤ 
│  Permission is hereby granted, free of charge, to any person obtaining a  │
│ copy of this software and associated documentation files (the "Software"),│
│ to deal in the Software without restriction, including without limitation │
│ the rights to use, copy, modify, merge, publish, distribute, sublicense,  │
│   and/or sell copies of the Software, and to permit persons to whom the   │
│   Software is furnished to do so, subject to the following conditions:    │
│                                                                           │
│  The above copyright notice and this permission notice shall be included  │
│          in all copies or substantial portions of the Software.           │
│                                                                           │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR │
│ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  │
│FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE│
│  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER   │
│ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING   │
│   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER     │
│                      DEALINGS IN THE SOFTWARE.                            │
└───────────────────────────────────────────────────────────────────────────┘ 


}}       