# import_ens_zones.sh

As of 2024.07.27, VNA V4.22.11.9 does not allow to import locations from a file.
If you are migrating VNA and have an ENS Installation with hundreds of zones, it would take a long time to create the locations manually through the web interface.
This script will assist you into importing ENS Zones into VNA Locations. 
<br>**To be used on a new installation only**

## Requirements
- VNA Must have its basic configuration setup
- VNA Must have at least one tenant

## How to use this script:
- **TAKE A SNAPSHOT OF YOUR VNA VIRTUAL MACHINE**
- Setup the default VNA and create one new tenant
- Copy this script to the VNA Server, with rights to execute the file
- In ENS, export the zones, and copy the file zone.csv into the VNA Server in the same folder where the script is
- Backup the VNA database with the command "vna db backup vna.sql.gz"
- Launch the script. it will ask you which one you want to assign the zones to
- If you want to test the script, you can enter a specific number of records you want to import
- If you need to roll back to the previous database you just saved, use the command "vna db restore -f ./vna.sql.gz" or restore your SNAPSHOT
<br><br><br><br><br>
### CHANGELOG:
#### - 2024.07.27 \V1.0\
First iteration of this script
