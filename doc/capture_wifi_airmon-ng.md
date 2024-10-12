# Capturing Wi-Fi with airmon-ng for Monitor Mode and Scanning Channels

## Overview
This tutorial will guide you through the process of setting up your wireless network interface in monitor mode with airmon-ng, scanning for available channels, and understanding the output of certain wireless commands.

## Prerequisites
* A wireless network interface that supports monitor mode.
* Tools installed: `airmon-ng`, `iw`, and `iwlist`.
* Root or `sudo` privileges.

## Steps
### 1. Kill Interfering Processes
First, stop any processes that might interfere with putting your wireless interface into monitor mode.

```
sudo airmon-ng check kill
```

Output
```
Killing these processes:

    PID Name
   1003 wpa_supplicant
```
This command stops the wpa_supplicant process, which could interfere with the monitor mode operation.

### 2. Start Monitor Mode on the Interface
Start monitor mode on your wireless interface. Replace `wlx9418654821f5` with your actual interface name.

```
sudo airmon-ng start wlx9418654821f5
```
Output
```
PHY     Interface       Driver          Chipset

phy0    wlx9418654821f5 mt7921u         NetGear, Inc. Wireless_Device
Interface wlx9418654821f5mon is too long for linux so it will be renamed to the old style (wlan#) name.

                (mac80211 monitor mode vif enabled on [phy0]wlan0mon)
                (mac80211 station mode vif disabled for [phy0]wlx9418654821f5)
```
Note: If the interface name is too long, it will be renamed (e.g., to wlan0mon).

### 3. Bring Up the Monitor Interface
Enable the monitor interface you just created.
```
sudo ip link set wlan0mon up
```

### 4. List Supported Channels
Use iwlist to display the channels supported by your wireless interface.
```
iwlist wlan0mon channel
```
Output:
```
wlan0mon  32 channels in total; available frequencies :
          Channel 01 : 2.412 GHz
          Channel 02 : 2.417 GHz
          Channel 03 : 2.422 GHz
          ...
          Channel 149 : 5.745 GHz
          Current Frequency:2.412 GHz (Channel 1)
```

### 5. Set the Interface to a Specific Channel
Set your monitor interface to a specific channel (e.g., channel 6).
```
sudo iw wlan0mon set channel 6
```

### 6. Scan for Active Channels Used by Other Networks
To see which channels are currently in use by nearby wireless networks, perform a scan and extract channel information.

```
sudo iwlist wlan0mon scan | grep "Channel:"
```
Example Output:
```
                    Channel:1
                    Channel:6
                    Channel:11
```
Alternatively, to display both SSIDs and channels:

```
sudo iwlist wlan0mon scan | egrep "ESSID|Channel:"
```

### 7. Stop Monitor Mode
When you're done with monitor mode, stop it to return your interface to managed mode.
```
sudo airmon-ng stop wlan0mon
```
Output:
```
PHY     Interface       Driver          Chipset

phy0    wlan0mon        mt7921u         NetGear, Inc. Wireless_Device
        (mac80211 station mode vif enabled on [phy0]wlx9418654821f5)
        (mac80211 monitor mode vif disabled for [phy0]wlan0mon)
```
### 8. Bring Up the Managed Interface
Reactivate your wireless interface in managed mode.

```
sudo ip link set wlx9418654821f5 up
```

### 9. Scan for Available Networks
Use iw to scan for available wireless networks.

```
sudo iw dev wlx9418654821f5 scan | less
```
Use the arrow keys to navigate through the output and q to quit.

### Additional Information
Understanding iwlist Channel Output
The command iwlist [interface] channel does not display the active channels used by other networks. Instead, it shows the wireless frequencies (channels) that your NIC supports.

To scan for active channels used by nearby networks, you can perform a scan and filter the output:


```
sudo iwlist wlx9418654821f5 scan | grep "Channel:"
```

### Explanation of no IR in Frequency Listings
When running ```sudo ip link set wlxe0e1a938a361``` up, you might see output like:


```
Frequencies:
    * 5955 MHz [1] (12.0 dBm) (no IR)
    * 5975 MHz [5] (12.0 dBm) (no IR)
    * 5995 MHz [9] (12.0 dBm) (no IR)
```
### What Does no IR Mean?
no IR stands for No Initiate Radiation.
It indicates that your device is not allowed to initiate transmission on that frequency.
The device cannot start a new network or send out beacons on these channels.
However, it can join an existing network if another device initiates communication on that frequency.
Why Is This Important?
These restrictions are due to regulatory rules in your country or region.
The available frequencies, maximum transmission power, and flags like no IR are determined by your regulatory domain settings.
Compliance with local laws ensures legal operation and avoids interference with other devices.
Setting the Regulatory Domain
To ensure your device operates correctly for your location:

```
sudo iw reg set <COUNTRY_CODE>
```
Replace <COUNTRY_CODE> with your two-letter country code (e.g., US, GB, DE).

Warning: Setting an incorrect regulatory domain may violate local laws and can cause interference. Always use the correct country code.

### Conclusion
By following this tutorial, you've learned how to:

Switch your wireless interface to monitor mode.
Scan for available channels and networks.
Understand the output of wireless commands like iwlist and iw.
Recognize the significance of flags like no IR in frequency listings.
Always remember to operate within the legal regulations of your country when configuring wireless devices.

References:
airmon-ng manual: Aircrack-ng Documentation
iw tool documentation: Wireless Wiki
Regulatory information: Wireless Regulatory Information
