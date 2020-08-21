# Various Info From p8-firmware Sources
This post will contain random snippets of information about p8-firmware in an attempt to clean up the source code a bit of random block comments
## Spacing in Strings
Writing a string is as follows:  
From the p8-firmware source, the x position of character `n` (starting at char 0) in a string is `stringXOrigin + n*pixelsPerPixel*FONT_WIDTH + (n*pixelsPerPixel)`. Before adding the last term in that expression (`n*pixelsPerPixel`), the position of a character is just the origin + `n*(horizontal pixels per character)`.  
This doesn't allow for a gap between characters however, so an offset must then be added proportional to the current character we are on, so we add `n*pixelsPerPixel`, which effectively adds another pixel-width between characters and spaces them properly.

## The Display
```
   THE DISPLAY:
      ◀ 240 ▶
  ______..._______
 |                |
 |   12:32        |
 .   01/01/20     .  ▲
 .                . 240
 .                .  ▼
 |                |
 |                |
 |______..._______|
```
The top left pixel is (0,0), with the bottom right being (239,239).

## The Interrupt Handler
The interrupt handler works as follows:  
If the handler routine (`GPIOTE_IRQHandler()`) is called, we know that there has been a change in state of any pin configured. So we first check which pin was set that sent the interrupt for each pin configured to send an interrupt, then we change the interrupt configuration on that pin to only trigger when the inverse of the current read value is seen (basically inverting the trigger state of the interrupt). This means that an interrupt will only fire on a TRANSITION of state of any of the interrupt pins. This is effectively the same behaviour as GPIOTE LoToHi or HiToLo interrupts, however it has the added benefit of drawing less power. Finally we only set the specific interrupt flag (which is checked by the thread mode interrupt handler `handleInterrupts()`)if the correct state of the interrupt is seen, for example only setting a button interrupt when the button is HIGH (since the button is active high logic).

## Bug in `delay.c` of `arduino-nRF5`
In `delay.c` of the popular `arduino-nRF5` library, there is a bug that causes the `millis()` function to rollover every ~36 hours. This is caused by the line [here](https://github.com/sandeepmistry/arduino-nRF5/blob/0ccd430d82c7aad1a5863606ac58c3c98ba9183e/cores/nRF5/delay.c#L68) where the overflow counter is incremented, and then for an unknown reason ANDed with 0xFF. This means that the overflow counter will reset every 255 increments, causing the `millis()` value to be wrong. This occurs every `255*((2^24)*(1/32768)) = 130560` seconds or 36.2 hours (since the RTC counter in the nRF5* is 24 bit, and runs at 32.768kHz), and can be fixed by removing the `& 0xff` at the end of that line. 