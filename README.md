# sageFetchFiles
A workflow for automatically accessing data from the SAGE (formerly IRIS) seismic data website via their IRISWS or FDSNWS interfaces.

This workflow allows you to:
* Specify IRISWS (timeseries) or FDSN dataselect parameters in a single table.
* Programmatically build a standards-compliant URL.
* Retrieve and parse seismic traces (MiniSEED or SAC) straight into MATLAB structs.
* Plot the data and optionally save to MAT or SAC.

The code centers around the helper function sageFetch.m, which accepts a request_info table and returns one or more time series records.
\

# Prerequisites
* MATLAB (R2019b or newer)

* At least one of the following MATLAB File Exchange parsers by François Beauducel must be installed on your MATLAB path:
  * rdmseed (for MiniSEED)
  * rdsac (for SAC)

* Internet access to SAGE/IRIS web services.

\
You can obtain the SAC and miniSEED parsers here:
* rdmseed/mkmseed: https://www.mathworks.com/matlabcentral/fileexchange/28803-rdmseed-and-mkmseed-read-and-write-miniseed-files
* rdsac/mksac: https://www.mathworks.com/matlabcentral/fileexchange/46356-rdsac-and-mksac-read-and-write-sac-seismic-data-file

Note: These third-party functions are not bundled. Please install them separately to ensure sageFetch can decode the retrieved traces.

\
# General Troubleshooting
No data returned / 404
* Verify network, station, channel, and time window.
* Try broadening the time range or removing optional filters (e.g., quality).
* Confirm the service endpoint (IRISWS timeseries vs FDSN dataselect) matches your ws setting.

Decoding errors
* Ensure rdmseed is installed for MiniSEED and rdsac for SAC.
* Confirm that the selected file_format aligns with the parser you have.

Timestamp issues
* Use datetime(..., 'ConvertFrom','datenum') as shown to visualize real time.
* Check for timezone assumptions in headers if times look shifted.

Authentication
* If using useAuth = true, make sure you have valid credentials and that sageFetch supports injecting them into requests.
