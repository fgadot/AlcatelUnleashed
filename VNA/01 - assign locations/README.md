# assign_locations.sh

This script is a follow up of import_ens_zones.sh
It will allow you to automatically assign the correct location to extensions, copying VNA setup

## Requirements
- VNA Must have one tenant
- VNA must have locations setup from the import_ens_zones.sh script 
- The file ens_locations (result of the import_ens_zones script)must be present in the same folder as this script
- The file phone.csv (VNA Phone/Authorized caller export) must be present in the same folder
- VNA must have all of its users present and synchronized with the OXE

## How to use this script:
- **TAKE A SNAPSHOT OF YOUR VNA VIRTUAL MACHINE**
- Copy this script to the VNA Server, with rights to execute the file
- Backup the VNA database with the command "vna db backup vna.sql.gz"
- Launch the script. 
- If you need to roll back to the previous database you just saved, use the command "vna db restore -f ./vna.sql.gz" or restore your SNAPSHOT
<br><br>
**NOTE:** 
<br>You might get postgreSQL errors if there is a variance between the ENS Users and the VNA Users. 
<br>Specially since VNA will import Virtual users. No worries about this, one the import is done, go to VNA and export all users in an excel spread sheet.
<br>You can then fix manually the issues - Hopefully not a lot. 

<br><br><br><br><br>
### CHANGELOG:
#### - 2024.07.27 \V1.0\
First iteration of this script