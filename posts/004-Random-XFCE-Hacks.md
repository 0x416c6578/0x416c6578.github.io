# Random XFCE4 Hacks
Like the trick to get a light/dark mode working on XFCE, I have many other small programs and tweaks that I have made over the ~2 years I have used XFCE that I want to put on the internet for future reference. Here is going to lie a collection of these notes that I will hopefully add to in the future
## Muting Discord Notifications Through `xfconf-query`
I wanted the ability to mute and unmute Discord desktop notifications at will without having to open Discord and toggle notifications. Not knowing how to do that via a Discord API or whatever, I decided to go the route of blocking the notifications through `xfconf-query`. To see what this program is, read [here](../posts/003-Auto-Dark-Mode-XFCE.md).  
I wrote a small script that toggled between running these two commands:
```bash
xfconf-query -c xfce4-notifyd -p "/applications/muted_applications" -t string -a -s "discord"
xfconf-query -c xfce4-notifyd -p "/applications/muted_applications" -t string -a -s ""
```
XFCE4 notifyd stores an array of strings of application names that have their notifications muted, so when I want all Discord notifications muted, I just write the singleton `["discord"]` to the array. For unmuting, I just set the array to contain only `""`. Since I have no other applications whose notifications I wish to mute, clearing the array and adding singletons suffices, since I will probably never need to add more applications to the list.