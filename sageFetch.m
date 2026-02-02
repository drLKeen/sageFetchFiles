function [S] = sageFetch(request_info)
% SAGEFETCH - Fetch data from EarthScope via FDSN services.
% Syntax
%   S = sageFetch(request_info)
%   
%   Input arguments:
%   request_info - struct with fields controlling containing information for
%                  building the URL to access data
%
%   Output arguments:
%   S - parsed waveform structure and associated data and metadata
%
% sageFetch waveform retrieval methods:
%   Table - retrieve waveforms with channel metadata (miniSeed style)
%   Structure - retrieve waveforms with channel metadata (SAC style)
%   
% Francois Beaucel has created functions for parsing miniSeed and SAC
% files. Please download the corresponding functions from his entry on
% MATLAB File Exchange or from his GitHub repository.
% 
% sageFetch FDSN event webservice: not yet implemented
% sageFetch miscellaneous: not yet implemented
% For additional guidance: not yet implemented
%
% README and Copyright location: https://github.com/drLKeen/sageFetchFiles/
%
% created by Dr. L. Keen, Jan - 2026; last updated 02/02/2026

%-------------------------------------------------------------------%

% Check whether the matlab.net.http package is available. Info at https://www.mathworks.com/help/matlab/http-interface.html
%try
    % Try to construct a simple matlab.net.http object (no network activity)
   % matlab.net.http.RequestMessage;
   % disp('matlab.net.http is available');
%catch ME
    % If construction fails, attempt a scope import and report the error
 %   warning('matlab.net.http not available: %s', E.message);
 % try catch the URI function
   % try
       import matlab.net.*
       import matlab.net.http.*
  %      disp('Imported matlab.net.* for the current scope (if available on path)');
  %  catch ME
 %   end
%end

%-------------------------------------------------------------------%
%-------------------------------------------------------------------%
% Build the data URL based on inputs and what retreival service you're
% using
% Universal inputs:
if request_info.useAuth == 1
    userAuth = 'auth';
else
    userAuth = '';
end
auth = strcat('query',userAuth,'?');

%
if request_info.station ~= ""
    sta = strcat('&sta=',request_info.station);
else
     error('You must provide a station from which to retrieve data.');

end

%
if request_info.channel ~= ""
    cha = strcat('&cha=',request_info.channel);
else
    cha = '';
    disp('Retrieving all channels. This may take a while.')
end

%
 if request_info.quality ~= ""
     quality = strcat('&quality=',request_info.quality);
 else
     quality = 'M';
 end
%
if request_info.file_format ~= ""
    format1 = strcat('&format=',request_info.file_format);
else
    error('You must provide a file format, either miniSEED if you want a MATLAB table, or sac.zip if you want a MATLAB struct');
end
%
if request_info.longestOnly == 1
    longestO = '&longestonly=true';
else
    longestO = '';
end

%-------------------------------------------------------------------%
% Inputs that change based on the service you're using
if strcmp(request_info.ws,'fdsnws')
    if request_info.network ~= ""
        net = strcat('net=',request_info.network);
    else
        error('You must provide a network.');
    end

    if request_info.location ~= ""
        loc = strcat("&loc=",request_info.location);
    else
        loc = '';
    end
    %
    if request_info.start_time ~= ""
        startT = strcat('&starttime=',request_info.start_time);
    else
        startT = '';
        disp('Retrieving ALL data from this station. Please be patient.')
    end
    %
    if request_info.end_time ~= ""
        endT = strcat('&endtime=',request_info.end_time);
    else
        endT = strcat('&endtime=',datestr(today,'yyyy-mm-dd'),'T00:00:00');
        disp('No end time specified. End time set to today.')
    end


    nodata = '&nodata=404';
    url_base = 'https://service.earthscope.org/fdsnws/dataselect/1/';
    url = strcat(url_base,auth,net,sta,loc,cha,startT,endT,quality,format1,longestO,nodata)

%-------------------------------------------------------------------%

elseif strcmp(request_info.ws,'timeseries')
    %
    if request_info.network ~= ""
        net = strcat('net=',request_info.network);
    else
        net = '';
    end

    if request_info.location ~= ""
        loc = strcat("&loc=",request_info.location);
    else
        loc = '';
    end
    %
    if request_info.start_time ~= ""
        startT = strcat('&start=',request_info.start_time);
    else
        startT = '';
        disp('Retrieving ALL data from this station. Please be patient.') 
    end
    %
    if request_info.end_time ~= ""
        endT = strcat('&end=',request_info.end_time);
    else
        endT = strcat('&end=',datestr(today,'yyyy-mm-dd'),'T00:00:00');
        disp('No end time specified. End time set to today.')
    end

    url_base = 'https://service.iris.edu/irisws/timeseries/1/';
    url = strcat(url_base,auth,net,sta,cha,startT,endT,format1,longestO,loc)

end

%-------------------------------------------------------------------%
%-------------------------------------------------------------------%
% Retrieve the data at the specified URL
uri = URI(url);
req = RequestMessage;
resp = req.send(uri);

% Check HTTP status
if resp.StatusCode ~= 200
    error("HTTP request failed: %d %s", resp.StatusCode, char(resp.StatusCode.ReasonPhrase));
end

% Get raw bytes (uint8)
raw = uint8(resp.Body.Data);         % ensure uint8

% Create a single filename (char)
tmp = char(tempname + ".mseed");     % tempname -> string concat -> char

% Write, checking fopen
[fid, msg] = fopen(tmp, 'w');
if fid == -1
    error("Failed to open temp file for writing: %s", msg);
end
count = fwrite(fid, raw, 'uint8');
fclose(fid);

% Verify file exists
if ~isfile(tmp)
    error("Temporary file not found after write: %s", tmp);
end


if strcmp(request_info.file_format, 'miniseed')
% Now call the reader (example: rdmseed). Convert to char again if required.
%try
    S = rdmseed(tmp); % this function is from File Exchange!!
%catch ME
 %   error('You must download rdmseed from File Exchange: https://www.mathworks.com/matlabcentral/fileexchange/28803-rdmseed-and-mkmseed-read-and-write-miniseed-files. If the function is already downloaded, make sure it is discoverable on your MATLAB path!')
%end

elseif strcmp(request_info.file_format,'sac.zip')
    uz = unzip(tmp);
    [D,T0,S] = rdsac(uz{1});
    
    S.D = D;
    S.T0 = T0;

end


% Clean up
% delete tmp file from my disk
fclose all; % you have to close the tmp file you've opened or else matlab will not delete it as it's "still in use"
delete(tmp);

end

%[appendix]{"version":"1.0"}
%---
%[metadata:styles]
%   data: {"heading1":{"color":"#268cdd"},"heading2":{"color":"#edb120"},"referenceBackgroundColor":"#262626"}
%---
