# Updates on the LDS-006
Unfortunately it turns out I was wrong; the flash in the new (working) LDS-006 is actually locked. Interestingly when I run `flash info 0` the output is:

```
device id = 0x13030410
flash size = 32kbytes
#0 : stm32f1x at 0x08000000, size 0x00008000, buswidth 0, chipwidth 0
	#  0: 0x00000000 (0x1000 4kB) not protected
	#  1: 0x00001000 (0x1000 4kB) not protected
	#  2: 0x00002000 (0x1000 4kB) not protected
	#  3: 0x00003000 (0x1000 4kB) not protected
	#  4: 0x00004000 (0x1000 4kB) not protected
	#  5: 0x00005000 (0x1000 4kB) not protected
	#  6: 0x00006000 (0x1000 4kB) not protected
	#  7: 0x00007000 (0x1000 4kB) not protected
```
This made me think that the flash wasn't protected, however after some reading around, I found the command `stm32f1x options_read 0`, which gives the output:
```
option byte register = 0xffffff02
write protection register = 0xffffffff
read protection: on
watchdog: hardware
stop mode: reset generated upon entry
standby mode: reset generated upon entry
user data = 0xffff
```
Here we can see the read protection is definitely enabled.

The chip is (I think) locked at read protection level 1 since I can still get debug access and read out SRAM. According to some stm32 documentation (link 2), "Any read request to the protected Flash memory generates a bus error", which is consistent with the errors I was getting with OpenOCD. There are ways to gain access to the flash (link 1, CVE-2020-13470 and 
CVE-2020-13468), however these seem very advanced (at least at the moment). I might mess with the techniques shown in this paper on a sacrificial chip from AliExpress at some point, but I don't think I trust my skills to perform such work correctly first time round. Until then, I plan to look into the serial data more and try and figure out how to get the motor started.

___

### Links
1. https://www.usenix.org/system/files/woot20-paper-obermaier.pdf - Paper on hardware exploits for stm32's and gd32's
2. https://www.st.com/resource/en/application_note/dm00186528-proprietary-code-readout-protection-on-microcontrollers-of-the-stm32f4-series-stmicroelectronics.pdf - Info on flash protection on stm32's