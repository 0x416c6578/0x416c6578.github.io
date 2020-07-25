### Touch
- The touch controller used in the P8 is the CST716S, rather than the CST816S
- It seems to be an equivalent controller in terms of data output
- However this display controller cannot go into sleep mode and wake up with a tap
  - To wake it up, you must toggle the reset pin
- This means if you want tap-to-wake, you must settle with a ~3mA current draw, which is very bad
- Also, the display has a different swipe behaviour in that if you swipe a direction without removing your finger, the 816 will register the swipe, whereas the 716 will only register it when the finger is removed