# Logging WPA2 and WPA3 Key Material
## Overview
This explains how to enable detailed logging of WPA2 and WPA3 key material using wpa_supplicant. This is especially important for Wi-Fi networks, as technologies like Wi-Fi 6E require the use of WPA3.

## Prerequisites
* Administrative (root or `sudo`) access to your system.
* `wpa_supplicant` installed on your system.

## Steps to enable detailed logging

### 1. Modify the `wpa_supplicant` Service File
For example to create log files in `/home/user/logs/wpa_supplicant/` then 
```
sudo vi /usr/lib/systemd/system/wpa_supplicant.service
```
Note: The location of the service file may vary depending on your distribution. It could be in /lib/systemd/system/ or /etc/systemd/system/.

### 2. Update the ExecStart Line
Modify the ExecStart to include a log output file (-f) and include key material in the logs (-K) and increase the debugging information (-dd). So for example the line may look like:

```
ExecStart=/sbin/wpa_supplicant -u -s -O /run/wpa_supplicant -dd -K -t -f /home/user/logs/wpa_supplicant/ wpa_supplicant.log -c /etc/wpa_supplicant/wpa_supplicant.conf
```

Explanation of all options used:

* -u: Enable the D-Bus control interface.
* -s: Log output to syslog.
* -O: Override control interface directory.
* -dd: Increase debugging verbosity.
* -K: Include key data in debug output (use with caution).
* -t: Include timestamps in debug messages.
* -f: Specify the log output file.
* -c: Specify the configuration file.

### 3. Create the Log Directory
Ensure that the log directory exists and has the correct permissions.

```
mkdir -p /home/user/logs/wpa_supplicant/
sudo chown user:user /home/user/logs/wpa_supplicant/
```

### 4. Reload Systemd and Restart the Service
After modifying the service file, reload the systemd daemon and restart wpa_supplicant.
```
sudo systemctl daemon-reload
sudo systemctl restart wpa_supplicant.service
```
### 5. Manage Logs with Scripts
Before starting logging, it's recommended to clear existing logs. Use the following scripts to start and stop log collection.

*Start Log Collection*
```
sudo tools/wifi/bin/wpa_collect_start
```

*Stop Log Collection*
```
sudo tools/wifi/bin/wpa_collect_stop logfile_name
```
Note: Replace logfile_name with your desired log file name. Ensure that these scripts are executable and located in the correct directory.

### 6. Configure wpa_supplicant
Create or edit the configuration file at `/etc/wpa_supplicant/wpa_supplicant.conf`.

```
sudo vi /etc/wpa_supplicant/wpa_supplicant.conf
```

This is the configuration file for wpa_supplicant and should be placed `/etc/wpa_supplicant/wpa_supplicant.conf`
```
# ctrl_interface is a parameter that determines where the control interface will be created. In this case, it is # under /var/run/wpa_supplicant and only the netdev group can access it.
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
# update_config allows wpa_cli commands to add and remove networks.
update_config=1

# Configuration for Network 1
network={
    ssid="Network1-SSID"
    psk="Network1-password"
    key_mgmt=WPA-PSK
    priority=1  # priority determines the order in which networks are tried when connecting.
}

# Configuration for Network 2
network={
    # scan_ssid: This option, when set to 1, instructs wpa_supplicant to scan for the SSID of the network in 
    # hidden networks. Some networks hide their SSID as a security measure, and setting scan_ssid to 1 can help 
    # connect to such networks.
    scan_ssid = 1
    ssid="Network2-SSID"
    key_mgmt=SAE
    sae_password="Network2-password"
    priority=2

    # proto: This is the protocol to be used for key negotiation and encryption. RSN stands for Robust Security 
    # Network, which is a term for networks using WPA2 or WPA3 security.
    proto=RSN

    # ieee80211w: This is for enabling management frame protection (MFP). The value of 2 means MFP is required. 
    # The standard IEEE 802.11w improves the security of Wi-Fi networks by adding mechanisms to protect against 
    # forgery and replay attacks.
    ieee80211w=2

    sae_password="123456"

    # pairwise: This parameter specifies the pairwise (unicast) cipher to be used for the network. CCMP is a type
    # of encryption used in WPA2 and WPA3 and is generally more secure than the TKIP used in WPA.
    pairwise=CCMP
    
    # group: This parameter specifies the group (broadcast/multicast) cipher to be used for the network. As with 
    # pairwise, CCMP is a more secure encryption method.
    group=CCMP

}
```