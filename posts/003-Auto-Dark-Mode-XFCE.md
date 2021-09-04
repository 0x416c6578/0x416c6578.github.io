# XFCE4 Automatic Theme Changing
I have used the XFCE4 desktop for many years now, and it is generally a very robust and clean DE for Linux, with some nice features, and solid stability. One of the features I had wanted for a few months now is the ability to change the system theme without using the system settings prompt, and automating such an event to happen in the morning (light mode), and evening (dark mode).  
## Switching Between Light and Dark Modes
XFCE4 doesn't have a notion of "light" and "dark" modes, only that there exist multiple themes that the user can switch between. In order to have a working light/dark theme, we must first implement a simple framework for switching themes. I did this using purely shell scripts, and in my `$HOME/.config` directory, I have two subdirectories for light and dark mode, in which any script placed in either directory will run whenever the corresponding theme is chosen.  

This is needed because, as mentioned before, XFCE doesn't have a global light/dark theme that applications can access, and given that lots of Linux applications don't use GTK, switching the GTK theme will not switch the theme of those applications. A good example is xfce4-terminal, which has a static theme that doesn't follow the current GTK theme. This means that the preferences file must be updated with the light/dark theme whenever such a change happens. 

## Switching the GTK Theme
XFCE4 uses a program called `xfconf` to store configuration files, and offers APIs for changing key-value pairs in a more abstract manner, using _channels_ and _properties_, rather than editing the configuration files directly. The program `xfconf-query` is the CLI tool for accessing and modifying configuration data that `xfconf` manages.  

So to switch the GTK theme to Materia-Dark, you would use:
```bash
xfconf-query -c xsettings -p "/Net/ThemeName" -s "Materia-dark-compact"
```

## What to Change?
So far, I have the scripts setup to switch the icon theme, GTK theme, window decorations theme, and the xfce4-terminal theme. In the future I plan to add vscode to the list, as well as maybe some integration with the Chromium dark webview setting. It would also be nice to change the switch time to corresponding to sunrise and sunset, rather than just set statically.

## Automating Switching
I have 3 main scripts that run, two of them switch the theme to light/dark (they just run the scripts in the corresponding directory), and the final script will check the current time and switch to the correct theme for that time (dark at night, light during the day).  

Automation is done using the `cronie` cron implementation (which will set the correct theme at the specific switch times). The crontab is shown:
```
-----DARK AT 1900-----
00 19 * * * DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus $HOME/.local/bin/darkMode.sh
-----LIGHT AT 0600----
00 06 * * * DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus $HOME/.local/bin/lightMode.sh
```
The `DBUS_SESSION_BUS_ADDRESS` is needed because crontab scripts aren't run as a logged in user, meaning they don't have access to X the same way a logged in user would.  

A problem with using `cron` is that the script won't update the theme if the device is powered off. This means that if you shutdown the laptop in dark mode, and turn it on after the cron trigger time, then it will be stuck in dark mode incorrectly. To fix this, the aforementioned script that checks the time and updates the theme is run at login so that the theme is switched if it is incorrect.

___

## Addendum 04.09.21
I switched to using the `sunwait` program ([link](https://github.com/risacher/sunwait)) rather than hard coding times with `cron`. I also added a wrapper around Chromium to switch the webview dark mode preference based on the theme:

```bash
#!/usr/bin/env bash
if [ $(cat ~/.config/THEME) == "dark" ]; then
  chromium --flag-switches-begin --fingerprinting-canvas-image-data-noise --fingerprinting-canvas-measuretext-noise --fingerprinting-client-rects-noise --enable-features=WebContentsForceDark --flag-switches-end
else
  chromium --flag-switches-begin --fingerprinting-canvas-image-data-noise --fingerprinting-canvas-measuretext-noise --fingerprinting-client-rects-noise --flag-switches-end
fi
```

For VSCode I use the [Sundial](https://marketplace.visualstudio.com/items?itemName=muuvmuuv.vscode-sundial) extension. Discord has GTK theme-based dark mode switching which thankfully works with [the GTK theme I use](https://github.com/shimmerproject/Greybird).