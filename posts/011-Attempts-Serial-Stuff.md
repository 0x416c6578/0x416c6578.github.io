# Efforts in Making Sense of Serial Data
As mentioned previously, I originally decided to use a bit of cardboard with teeth cut into it to emulate the spinning of the laser assembly, but some experimentation showed that it was definitely harder than it looks (getting correct teeth spacing, centered etc.). I now plan to just hook directly into the photoelectric fork sensor with an Arduino and use it to emulate the periodic inputs that the uController expects.

<figure>
<img width="200" src="../Images/failedTeethThing.jpg" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
</figcaption>
</figure>

## Simple Teeth Timing Calculation
There are 15 gaps in the light "teeth" on the base assembly. Assuming a conservative 2 rotations per second, this would mean 33ms per tooth. Because one gap is about twice the size of the rest, call it 31.5ms per "normal" gap. This means the larger gap has a timing of 59ms (since 2 revs per second), so the code just needs to toggle a GPIO in a `14*31.5ms + 1*59ms`pattern.

## The Fork Sensor
<figure>
<img width="300" src="../Images/forkSensor1.jpg" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
</figcaption>
</figure>

<figure>
<img width="300" src="../Images/forkSensor2.jpg" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
</figcaption>
</figure>

The pin closest to the diode (that isn't ground) is the digital output of the sensor. It goes high when being blocked by a tooth, and else low. So we know during the "gap" time of the Arduino program we should go low (or better just high impedance).

**MORE TO ADD**