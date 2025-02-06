# DID Extractor

If you have an installation with hundred or thousands of incoming DID assigned to the DID Translator, but nobody know what DID is assigned to what extension, then this script is for you. 
<br>
<br>From the 8770, download the DID Translator list
<br>From the 8770, download the users (only, no any other option) list
<br>
<br>
## Understanding the DID to Extension Relationship
The DID (Direct Inward Dial) to Extension relationship is defined in the second input file (translator.txt). This file specifies how external phone numbers (DIDs) map to internal phone extensions in the OXE.

<br><br>
### Basic Mapping (One-to-One)

In the simplest case, each DID corresponds directly to an Extension.<br>
If the Range Size is greater than 1, it means that multiple DIDs should map to multiple extensions in sequential order.<br>
If Unique Internal Number is YES, this means that all DIDs in the range share the same extension.

<br><br>
## How the Script Works

The Python script follows these rules:

Read translator.txt to build the DID-to-Extension mapping.
<br>If Range Size = 1, store a single DID-to-Extension pair.
<br>If Range Size > 1:
<br>If Unique Internal Number = NO, map each DID to a unique extension.
<br>If Unique Internal Number = YES, all DIDs in the range share the same extension.
<br>
<br>Read users.txt to get First Name and Last Name for each DID.
<br>Match the DID from users.txt with the DID in translator.txt.

<br>In the DIDtoExtensinos.csv file:
<br>If a match is found, store the corresponding extension.
<br>If no match is found, set the extension first name as "EXTENSION" and last name as "NOT ASSIGNED".
<br>

### Summary of DID to Extension Logic

✅ Each DID can either have a unique extension or share an extension with others.
<br>✅ Range Size determines whether multiple DIDs are affected.
<br>✅ If Unique Internal Number = NO, DIDs get their own sequential extensions.
<br>✅ If Unique Internal Number = YES, all DIDs share the same extension.
<br><br>
DID-to-Extension Mapping from translator.txt
<br>If Range Size > 1, map DIDs sequentially to Extensions.
<br>If Unique Internal = NO, assign each DID a unique extension.
<br>If Unique Internal = YES, all DIDs in the range get the same extension.
<br>Look for a matching Extension in users.txt
<br>If the extension exists in users.txt, retrieve First Name and Last Name.
<br>If the extension does not exist, set:
<br>First Name → "EXTENSION"
<br>Last Name → "NOT ASSIGNED"