# OnePlus 8T Auto Brightness is Bad
I've been having some problems with the OnePlus 8T's auto brightness feature on LineageOS 19.1 (Android 12L). Because of the phones design, the ambient light sensor is positioned very close to the display, causing some strange and annoying behaviour.

## Positive Feedback Loop
When in a dark room, opening a light coloured app will cause the display to get into a feedback loop where it increases the brightness, which causes it to measure a brighter ambient light value, causing it to increase the brightness etc. There are two ways to fix this. First you can make the status bar black using an app (can be found on play store). This will create a boundary that means the display brightness doesn't get read by the sensor. Alternatively you can enable LineageOS's one-shot auto brightness. This feature will measure and set the screen brightness once - when the device is unlocked; thus stopping the loop.

## High Brightness on Unlock
Sometimes when the device is powered on, the screen will shoot to 100% brightness. I am not 100% sure on why it does this but my working theory is that the proximity sensor IR led will cause a "bright" reading from the closely situated ambient light sensor. I think this because when disabling the proximity check on unlock setting, this behaviour seemingly doesn't happen.

___

Overall the 8T is a pretty good phone, but I think the push for a massive bezel-less display and less than adequate testing has led to a worse design of this part of the phone, to the detriment of users (https://community.oneplus.com/thread/1409725, https://www.reddit.com/r/LineageOS/comments/nxxs36/oneplus_8t_display_auto_brightness_acting_weird/).