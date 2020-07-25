## RTC
- A bug I found in the millis() function causes the millis() function to wrap over about every 2 days (caused by &ing the overflow bits with 0xff meaning they wrap prematurely)
  - An issue has been filed with arduino-nRF5 (https://github.com/sandeepmistry/arduino-nRF5/issues/417) but the project is inactive now, so if you use that library, be sure to fix that bug to get propper 32 bit millis() functionality
## Heartrate sensor
- There are two LEDs on the heartrate sensor board, however these are independently controllable separate to the heartrate sensor itself (which has its own LED in the package) through pin 27

## Accelerometer