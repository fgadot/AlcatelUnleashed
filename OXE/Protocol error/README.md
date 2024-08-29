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
<br><br>**IMPORTANT: Please note that the script base itself on the past incident log reports (incvisu). Therefore, even if you fix the set type, the script will still display errors until you clear our the incident log
with the command "increset"**


## How to use this script:
- Installed the script in /DHS3data/mao
- Change rights to execute with the command 'chmod 755 protocol_error.sh'
- Edit the script and change the ERROR_MESSAGE variable to match the language in your incvisu error 1612
- Run the script with './protocol_error.sh'
<br><br><br><br><br>
### CHANGELOG:
#### - 2024.08.28 \V1.0\
- First iteration of this script
<br>
#### - 2024.08.29 \V1.1\
- Modified the script so the error message can be setup for any language 
- Modified the script so sets with space in their name (ex: IPT 8069) won't screw up the result display