# LDS-006 Lidar
## General Overview
The LDS-006 is a 360 degree lidar commonly found in the Ecovacs DeeBot line of robotic vacuums. Generally a part similar to the LDS-006 would cost over £50, with many higher end ones costing over £100 (see [here](https://www.aliexpress.com/wholesale?catId=0&SearchText=lidar) for reference). However this lidar could be found for as little as $7 (plus shipping and tax) on Aliexpress, listed as being salvaged / taken from Ecovacs vacuums.

<figure>
<img width="300" src="../Images/lidar.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
</figcaption>
</figure>

<figure>
<img width="300" src="../Images/lidarMotor.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
</figcaption>
</figure>

My motivation for messing with these modules came from a [Marco Reps](https://www.youtube.com/user/reppesis) video where he [messes with a Xiaomi vacuum lidar](https://www.youtube.com/watch?v=4sQCz75BfrM). The price of such modules put me off for some time, but after discovering the LDS-006 I knew I wanted to mess with it.

## Hardware
There are 4 wires coming from the module. They are:
```
black: GND
red: VCC (5v)
blue: UART TX (3v3)
green: UART RX (3v3)
```
The module has two distinct parts to it; first is the spinning assembly with laser, and second is the motor control / serial comms board.

## Spinning Assembly
<figure>
<img width="300" src="../Images/lidarSpinner.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
</figcaption>
</figure>

The spinning assembly contains a main board which handles power supply stuff, and a daughter board which houses an ADC and a GD32F\[something\] microcontroller. \[**More info to come here in the future**\]

Power is inductively coupled to the spinning part, and data is sent back via an infrared LED and IR receiver on the controller board. 

## Controller Board and Motor Assembly
<figure>
<img width="300" src="../Images/lidarMainBoardZoomed.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
</figcaption>
</figure>

This board handles power supply stuff, data handling, and serial comms control. The main microcontroller is a GD32F130P6F6 on the top right of the board.

### Connections to the uC
- The blue wire connects to PA2 via a 100ohm resistor
- The green wire connects to PA3 via a 100ohm resistor
  - These are the USART-1 TX and RX pins respectively
  - The UART isn't 5v tolerant
- The motor is controlled via PWM on PA4
  - Control of the motor via software is not yet understood
- The SWD debug port is visible to the right of the uC, and its pinout is GND->SWCLK->SWDIO->3v3 (from bottom pin to top pin)
  - You can connect to it via an STLink (clone) and it works fine with the `stm32f1x.cfg` file since this uC is a clone of the stm32f103

## Serial Data
\[**TODO**\]