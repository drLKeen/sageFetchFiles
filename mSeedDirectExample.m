%[text] # SAGE Data Retrieval
%[text:tableOfContents]{"heading":"Table of Contents"}
%[text] 
%%
%[text] ## How to use this notebook
%[text] ### Data Retrieval- Time Series Data
%[text] Time series data can be retrieved in the miniSeed format via SAGE's [iris](https://service.iris.edu/irisws/) and [fdsn](https://service.iris.edu/fdsnws/) web services. The function sageFetch.m retrieves the data directly into the MATLAB workspace without downloading the file itself. To build the appropriate URL for fetching data, fill in the fields in the next section. It is okay to leave a field blank. A table called "request\_info" will be assembled with your specified parameters.
%[text] SageFetch takes the request\_info table as an input and builds the URL for requesting your desired data. The URL building works in the same way as SAGE's own URL builder, composing a URL string from your input criteria. SageFetch then uses [MATLAB's built-in RESTful web service functions](https://www.mathworks.com/help/matlab/http-interface.html?s_tid=CRUX_lftnav) to bring the requested data directly from the internet into your workspace. However, in order to interpret the trace data, sageFetch calls one of two functions  created by [François Beauducel](https://www.mathworks.com/matlabcentral/profile/authors/1195687): [rdmseed](https://www.mathworks.com/matlabcentral/fileexchange/28803-rdmseed-and-mkmseed-read-and-write-miniseed-files?s_tid=prof_contriblnk) or [rdsac](https://www.mathworks.com/matlabcentral/fileexchange/46356-rdsac-and-mksac-read-and-write-sac-seismic-data-file?s_tid=prof_contriblnk). They are available on the MATLAB File Exchange or GitHub. If you do not have at least one of these functions downloaded and installed on the MATLAB path, sageFetch will not be able to bring in the data. SageFetch will not be bundling the above functions with the rest of its retrieval code, as they belong to François Beauducel, and his repositories should get credit for the function downloads from everyone using them.
%[text] With the above functions and MATLAB's built-in ability to read and save csv (or other) file formats, your basic data access needs should be met! However, we are working on also incorporating options to use SAGE's other services (such as downloading specific event metadata). If you have a specific workflow you need help with or want incorporated into sageFetch's capabilities, please reach out to the owner of the repository where you found this notebook!
%%
%[text] ## Select your data parameters
%[text] This setup is for using IRISWS (Iris web services) for retrieving data. This allows a few more parameters to be specified than the FSDN web services. The `ws` flag can be changed from `"timeseries"` to `"webservice"` if you wish to use the FDSN method. The format of the start time and end time may also need to be adjusted. Each has a serparate URL building tool on the SAGE site as the syntax is marginally different between the two.
ws = "fdsnws"; %[control:dropdown:1bae]{"position":[6,14]}
network = "IU"; %[control:editfield:65d4]{"position":[11,15]}
station = "ANMO"; %[control:editfield:2ffb]{"position":[11,17]}
location = "00"; %[control:editfield:26a9]{"position":[12,16]}
channel = "BHZ"; %[control:editfield:3d71]{"position":[11,16]}
start_time = "2025-02-06T00:00:00";
% for now, you'll need to specify your own time
end_time = "2025-02-06T02:00:00"; 
% for now, you'll need to specify your own time
quality = "D"; %[control:dropdown:8334]{"position":[11,14]}
file_format = "miniseed"; %[control:dropdown:8900]{"position":[15,25]}
longestOnly = false; %[control:checkbox:64d8]{"position":[15,20]}
useAuth = false; %[control:checkbox:93d8]{"position":[11,16]}

request_info = table(network, station, location, channel, start_time, ...
    end_time, quality, file_format, longestOnly, useAuth,ws);

clear network station location channel start_time end_time quality file_format longestOnly useAuth ws

% working example URLs: 
% https://service.earthscope.org/fdsnws/dataselect/1/query?net=IU&sta=ANMO&loc=00&cha=BHZ&starttime=2016-01-01T00:00:00&endtime=2016-01-13T00:00:00&quality=M&format=miniseed&nodata=404
%%
%[text] ## Retrieve your data
S = sageFetch(request_info); %[output:363340f7]

% save your data as a...
    %% mat file
    % save('myData.mat','S')
    
    %% sac file
    % T0 = S.T0;
    % H = S.H;
    % D = rmfield(S,{'H','T0'});
    % mksac('myData','D','T0','H')
%%
%[text] ## Plot your data
figure
plot(S(1).d)
ylabel('Amplitude')
xlabel('Index')
% Change the x-axis to the appropriate time
t =  datetime(S(1).t,'ConvertFrom','datenum','Format','yyyy-MM-dd HH:mm:ss.SSSSSS');

figure
plot(t,S(1).d)
ylabel('Amplitude')
title(strcat(S(1).ChannelFullName, ', date:',S(1).RecordStartTimeISO))


% another plot option
figure
h = tiledlayout(3,1);
nexttile
plot(S(1).d);
nexttile
plot(S(2).d)
nexttile
plot(S(3).d)

title(h,'Multiple Plots')

%[appendix]{"version":"1.0"}
%---
%[metadata:styles]
%   data: {"heading1":{"color":"#268cdd"},"heading2":{"color":"#edb120"},"referenceBackgroundColor":"#262626"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[control:dropdown:1bae]
%   data: {"defaultValue":"\"fdsnws\"","itemLabels":["FDSNWS","Iris Timeseries WS"],"items":["\"fdsnws\"","\"timeseries\""],"label":"ws","run":"Section"}
%---
%[control:editfield:65d4]
%   data: {"defaultValue":"\"IU\"","label":"network","run":"Section","valueType":"String"}
%---
%[control:editfield:2ffb]
%   data: {"defaultValue":"\"ANMO\"","label":"station","run":"Section","valueType":"String"}
%---
%[control:editfield:26a9]
%   data: {"defaultValue":"\"00\"","label":"location","run":"Section","valueType":"String"}
%---
%[control:editfield:3d71]
%   data: {"defaultValue":"\"BHZ\"","label":"channel","run":"Section","valueType":"String"}
%---
%[control:dropdown:8334]
%   data: {"defaultValue":"\"M\"","itemLabels":["-","D","R","Q","M","B"],"items":["\"\"","\"D\"","\"R\"","\"Q\"","\"M\"","\"B\""],"label":"quality","run":"Section"}
%---
%[control:dropdown:8900]
%   data: {"defaultValue":"\"miniseed\"","itemLabels":["miniSeed","SAC.zip"],"items":["\"miniseed\"","\"sac.zip\""],"label":"file_format","run":"Section"}
%---
%[control:checkbox:64d8]
%   data: {"defaultValue":false,"label":"longestOnly","run":"Section"}
%---
%[control:checkbox:93d8]
%   data: {"defaultValue":false,"label":"useAuth","run":"Section"}
%---
%[output:363340f7]
%   data: {"dataType":"textualVariable","outputData":{"name":"url","value":"\"https:\/\/service.earthscope.org\/fdsnws\/dataselect\/1\/query?net=IU&sta=ANMO&loc=00&cha=BHZ&starttime=2025-02-06T00:00:00&endtime=2025-02-06T02:00:00&quality=D&format=miniseed&nodata=404\""}}
%---
