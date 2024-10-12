# Setting Up Wi-Fi 6E in the 6 GHz Band on Linux
## Overview 
Wi-Fi 6E is an extension of Wi-Fi 6, expanding Wi-Fi capabilities into the 6 GHz frequency band. This new spectrum offers more channels and less interference, leading to faster speeds and lower latency. This guide will walk you through setting up Wi-Fi 6E on a Linux system, enabling you to utilize the 6 GHz band.

## Table of Contents
Prerequisites
Step 1: Install Necessary Packages
Step 2: Check Wireless Device Capabilities
Step 3: Set the Regulatory Domain
Step 4: Verify 6 GHz Channels Availability
Step 5: Bring Up the Wireless Interface
Step 6: Handle RF-Kill Issues
Conclusion
References

## Prerequisites
A Wi-Fi 6E compatible wireless network card.
A Linux distribution (e.g., Ubuntu, Debian).
Root or `sudo` privileges.
## Step 1: Install Necessary Packages
Install the `wireless-regdb` and `iw` packages to manage wireless regulatory settings and interface configurations.

```
sudo apt update
sudo apt install wireless-regdb iw rfkill
```
## Step 2: Check Wireless Device Capabilities
Use the `iw list` command to display the capabilities of your wireless device, including supported frequencies.

```
iw list
```
Sample Output:
```
Frequencies:
    * 5955 MHz [1] (disabled)
    * 5975 MHz [5] (disabled)
    * 5995 MHz [9] (disabled)
    ...
```
Explanation:

The frequencies listed correspond to the 6 GHz band channels.
The (disabled) tag indicates that these channels are not currently enabled.

## Step 3: Set the Regulatory Domain
By default, your system may not be configured for your country's regulatory domain, which can restrict certain frequencies. Set the regulatory domain to your country code to enable the appropriate frequencies.

Check Current Regulatory Domain:

```
sudo iw reg get
```
Sample Output:
```
global
country 00: DFS-UNSET
    ...
```    
Set Regulatory Domain to the United States (Replace US with your country code):

```
sudo iw reg set US
```
Verify the Change:

```
sudo iw reg get
```
Sample Output:

```
global
country US: DFS-FCC
    (902 - 904 @ 2), (N/A, 30), (N/A)
    ...
    (5925 - 7125 @ 320), (N/A, 12), (N/A), NO-OUTDOOR, PASSIVE-SCAN
```
Explanation:

Setting the regulatory domain updates the allowed frequencies and power levels according to your country's regulations.
The 6 GHz band is now listed with specific power levels and flags.
### Step 4: Verify 6 GHz Channels Availability
After setting the regulatory domain, check if the 6 GHz channels are enabled.

List Wireless Interfaces:
```
iw dev
```
Sample Output:

```
phy#0
    Interface wlx9418654821f5
        ifindex 4
        wdev 0x1
        addr 94:18:65:48:21:f5
        type managed
        txpower 3.00 dBm
```
List Supported Channels:
```
iwlist wlx9418654821f5 channel

```
Sample Output:
```
wlx9418654821f5  32 channels in total; available frequencies :
          Channel 01 : 2.412 GHz
          ...
          Channel 149 : 5.745 GHz
```
Note: If the 6 GHz channels are not listed, your wireless card may not support them, or additional configuration is needed.

### Step 5: Bring Up the Wireless Interface
Before using the wireless interface, you need to bring it up.

```
sudo ip link set wlx9418654821f5 up

```
Possible Error:
```
RTNETLINK answers: Operation not possible due to RF-kill
```
This error indicates that the wireless device is blocked by the RF-Kill subsystem.

### Step 6: Handle RF-Kill Issues
The RF-Kill subsystem can block wireless devices for security or power-saving reasons. There are two types of blocks:

* Soft Block: Controlled by software.
* Hard Block: Controlled by physical switches on the device.
Check RF-Kill Status:
```
sudo rfkill list
```
Sample Output:
```
0: hci0: Bluetooth
    Soft blocked: no
    Hard blocked: no
1: phy0: Wireless LAN
    Soft blocked: yes
    Hard blocked: no
```
Unblock the Wireless Device:
```
sudo rfkill unblock wifi
```
Verify the Unblock:
```
sudo rfkill list
```
Expected Output:
```
1: phy0: Wireless LAN
    Soft blocked: no
    Hard blocked: no
```
Bring Up the Interface Again:
```
sudo ip link set wlx9418654821f5 up

```
Explanation:

Unblocking the device removes the software block, allowing the interface to be brought up.
If the hard block is yes, check for a physical switch or BIOS settings to enable the wireless device.
### Step 7: Verify 6 GHz Channels
After unblocking and bringing up the interface, check the available frequencies again.
```
iwlist wlx9418654821f5 channel
```
Sample Output:
```
wlx9418654821f5  51 channels in total; available frequencies :
          Channel 01 : 2.412 GHz
          ...
          Channel 233 : 6.995 GHz
```
Explanation:

The 6 GHz channels should now be listed if your hardware supports them.
Channels in the 6 GHz range indicate that the device is ready for Wi-Fi 6E operation.
### Conclusion
You have successfully set up your Linux system to utilize Wi-Fi 6E in the 6 GHz band. By installing the necessary packages, configuring the regulatory domain, handling RF-Kill issues, and verifying the available channels, you can now enjoy the benefits of Wi-Fi 6E.

### References
Wireless Regulatory Database: wireless-regdb
iw Tool Documentation: Linux Wireless
RF-Kill Subsystem: RFKill Documentation
Wi-Fi 6E Information: Wi-Fi Alliance
Note: Always ensure that your use of the wireless spectrum complies with local regulations. Unauthorized use of certain frequencies may be illegal in your country.

### Additional Information
Understanding Regulatory Domain Settings
The regulatory domain defines the allowed frequencies and power levels for wireless communication in a specific country or region. Incorrect settings can:

* Limit available frequencies.
* Cause legal issues due to non-compliance.
* Affect wireless performance.
* Setting the Correct Regulatory Domain:

Replace US with your country's two-letter ISO code.
For example, GB for the United Kingdom, DE for Germany.
```
sudo iw reg set <COUNTRY_CODE>
```
Dealing with Hardware Limitations
If, after following the steps, the 6 GHz channels are still not available:

Check Hardware Compatibility:
Ensure your wireless card supports Wi-Fi 6E and the 6 GHz band.
Update Drivers:
Install the latest drivers from the manufacturer.
Use the latest kernel that supports your hardware.
Example of Checking Device Support:

```
lspci -k | grep -A 3 -i "network"
```
Scanning for Networks in the 6 GHz Band
Once the interface is up and the 6 GHz channels are available, you can scan for networks.

```
sudo iw dev wlx9418654821f5 scan | grep "freq"
```
Sample Output:
```
        freq: 5955
        ...
```
Explanation:

The freq values in the 6 GHz range (5955 MHz and above) indicate Wi-Fi 6E networks.
Scanning may require elevated privileges.
Connecting to a Wi-Fi 6E Network
Use `wpa_supplicant` or a network manager that supports Wi-Fi 6E to connect.

Example with wpa_supplicant:

Create a configuration file `/etc/wpa_supplicant.conf:`
```
network={
    ssid="Your_SSID"
    psk="Your_Password"
}
```
Start `wpa_supplicant`:
```
sudo wpa_supplicant -B -i wlx9418654821f5 -c /etc/wpa_supplicant.conf
```
Obtain an IP address:
```
sudo dhclient wlx9418654821f5
```
