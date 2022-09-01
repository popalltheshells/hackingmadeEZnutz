From TCM's Wireless Section and RSM Wiki and my experience

#### Resources
I like this site: https://github.com/ivan-sincek/wifi-penetration-testing-cheat-sheet#pmkid-attack



## Setup
*This section is Assuming you have a wifi card that is compatible and works in monitor mode*

Check interfaces:

	iwconfig

Make sure to run this command to kill any processes that might mess with capturing ability 

		airmon-ng check
		airmon-ng check kill


Setup your wireless card to monitor mode and browse nearby networks: (this is assuming you ran `iwconfig` and saw your wifi card as `wlan1`)

	airmon-ng start wlan1

*Note:* Sometimes after running this command the name of your interface will change to something like `wlan1mon`

Make sure you just doulbe check with `iwconfig` as you will need to type the name of the adapter exactly for when you want to listen for traffic

Now you should be ready to perform your initial recon and start figuring out which networks to target


## Targeting WPA2-PSK Networks
When on a Wireless pen-test -- if the target networks are WPA2PSK there are basically 3 attacks you can do to get into wpa2-psk

1. **Passive WPA Capture** 
	Run airodump-ng (see Recon section) on the target networks (make sure to give airodump `-c` to specify a channel that has flowing traffic) and wait around and monitor traffic. You might get lucky and get a WPA handshake quickly
	
	A. Works well if you get there before employees start for the day

	 B. Once you identify a target network you can specifiy a network and channel to listen on for handshakes

	`airodump-ng -c <channel> --bssid <D4:B9:2F:1E:C2:23> -w capture.txt wlan1mon`
  
	It's important to make sure you are writing output to a file and naming your files in a way that you and recall later because if you happen to capture a WPA handshake you will need the .cap file to provide to `aircrack-ng` for cracking.


2. **De-auth attack** on a specific client on a target network
	
	A. Use `Aireplay-ng` for this. Make sure to identify a connected host and an AP (Commands below)
	B. Be sure to have airodump listening on the network for which you are running the deauth attack against. Or just point airodump at the specific AP/BSSID for which your De-auth Target is connected to 

	If you dont get a handshake passively, you can try a **deauth attack**

	A. First you need a target in a deauth attack. you might see something like below when you are listening to a specific network
	
	![image](https://github.com/popalltheshells/hackingmadeEZnutz/blob/9a547edb4a463cf6f197a932d06239a0ca661c3e/assets/Pasted%20image%2020220831194215.png)
		
	The *BSSID* is the MAC Address of the Access Point. Also good to think of it as just the MAC of the In-Scope Target network, always good to jot down these MAC's in your notes

	The *STATION* is the individual devices connected to the AP. You can pick anyone of these stations as your target in the deauth attack
	
	**Once you have picked out a station and BSSID You can setup the attack**
	While you are listening to a specific network, in another terminal tab run:

		aireplay-ng --deauth 10 -a D4:B9:2F:1E:C2:23 -c 34:20:03:74:10:F9 wlan1mon 

	`-c` is the specific client (STATION) you want to attack, `-a` is the Access Point/BSSID from above

	The number after `--deauth` is the number of deauth packets/frames you want to send. I like to stick with 10-20max. It is basically a super quick DOS so keep this number small. 

If successful we will get a WPA handshake which we can crack with `aircrack-ng`.

3. **PMKID Attack** 
	*I'm not an expert on this attack*. Basically I know to install the needed tools (found in RSM wiki) and then run the tool and listen, you might get lucky and get a PMKID Client-Less token thingy which can be cracked and give you the network password.

	As I mentioned, I am not an expert here. These are basically the same commands from the wiki.

	The following attacks can be deployed against an SSID observed to use PSK for authentication and WPA/WPA2 for encryption. * PMKID Client-less Attack

	First have your adapter in monitor mode

	Capture PMKIDS

		hcxdumptool -i wlan1mon -o galleria.pcapng --enable__status=1

	Once you have gathered enough it will create a .pcapng file. You can extract the hashes from the capture file

	Extract Hashes

		hcxpcaptool hcxdumptool_results.cap -k hashes.txt

	Crack hashes

		hashcat -m 16800 -a 0 --session=cracking --force --status -O -o hashcat_results.txt hashes.txt rockyou.txt

## Testing Segmentation

For testing segmentation generally we want to ensure that devices on the **Corporate** wifi network are not reachable from the **Guest** wifi.

Generally I gain access to the guest wifi either by cracking a WPA handshake, or I just ask the client to give me the guest network password for segmentation testing.

Once you connect to the network I just run some standard NMAP scans as well as some tshark/Wireshark sniffs to see if you can see any stuff you'd normally want to find on an internal network
	- Mail servers
	- SMB shares
	- Corp devices
	- Any sort of filesharing/Network admin devices

If you do find some stuff grab screenshots and just try to go as deep as you can on those devices

