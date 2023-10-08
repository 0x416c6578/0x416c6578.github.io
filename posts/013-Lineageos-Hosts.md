# Editing LineageOS Hosts File Without Root or TWRP
I am an avid user of LineageOS, both for the privacy benefits and the long term software support and headache / distraction free software experience. To limit my usage of social media (especially YouTube) and excessive impulsive reading of the news, I like to put in Adblock rules as firebreaks. The problem is that I would habitually ignore the adblock prompts and continue to the site regardless, so they ended up being mostly ineffective.

To properly block these sites, I would like to use a hosts file method. I however don't run any root solution on my device (mostly because I forget to update Magisk every OS update!). So to edit the hosts file directly, I used the following method:

1. Boot into LineageOS recovery
2. Enable ADB and mount the system partition in advanced settings
3. Get an ADB root shell, remount the system partition as rw with `mount -o rw,remount /mnt/system`
4. ADB push a statically compiled busybox binary to `/tmp`
5. Give the busybox binary executable permissions, then call `busybox vi /mnt/system/system/etc/hosts` to edit the file and add the domains one would like to block
6. (Probably not necessary), remount system partition as ro
7. Reboot - the hosts should now be blocked

The irony is this still requires manually redoing every OS update (once a month), but its a tradeoff for not running root on my device.