# protocol_error.sh

You might find your OXE installation with a ton of protocol error lines in the incident file, like:<br>
28/08/24 11:30:08 001001M|---/--/-/---|=0:1612=Protocol error on Alcatel 8&9 series, type 13 (neqt 2048)

This means that the physical phone installed does not match the type of phone configured for the extension. 

This script will give you a list of phones generating the error, their current programmed type, and displayed name from the configuration. 
The reason for displaying the name is that you might have sites with thousands of extension, and you might not know by heart where is extension 1234 for example,
while a name might be easier to locate. 

Example:<br>
(101)oxe-a> ./protocol_error.sh
Ext     Type    Name
2402    4039    Room 402 
8887    4039    John Murphy
8975    4039    Principal 

<br>**NOTE**: This script was not tested on R101

## How to use this script:
- Installed the script in /DHS3data/mao
- Change rights to execute with the command 'chmod 755 protocol_error.sh'
- Run the script with './protocol_error.sh'
<br><br><br><br><br>
### CHANGELOG:
#### - 2024.08.28 \V1.0\
First iteration of this script