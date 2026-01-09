function [S] = sageFetch(request_info)
% SAGEFETCH - Fetch MiniSEED data from EarthScope dataselect service
%
% Input arguments:
% request_info - struct with fields controlling query and output
%
% Output arguments:
% S - parsed waveform structure returned by rdmseed
% 
% created by Dr. L. Keen, Jan - 2026; last updated 01/09/2026
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
% Build the data URL based on inputs
url_base = 'https://service.earthscope.org/fdsnws/dataselect/1/';
if request_info.useAuth == 1
    userAuth = 'auth';
else
    userAuth = '';
end
auth = strcat('query',userAuth,'?');
%
if request_info.network ~= ""
    net = strcat('&net=',request_info.network);
else
    net = '';
end
%
if request_info.station ~= ""
    sta = strcat('&sta=',request_info.station);
else
    sta = '';
end
%
if request_info.location ~= ""
    loc = strcat("&location=",request_info.location);
else
    loc = '';
end
%
if request_info.channel ~= ""
    cha = strcat('&cha=',request_info.channel);
else
    cha = '';
end
%
if request_info.start_time ~= ""
    startT = strcat('&starttime=',datestr(request_info.start_time,'yyyy-mm-dd'),'T00:00:00');
else
    startT = '';
end
%
if request_info.end_time ~= ""
    endT = strcat('&endtime=',datestr(request_info.end_time,'yyyy-mm-dd'),'T00:00:00');
else
    endT = '';
end
%
if request_info.quality ~= ""
    quality = strcat('&quality=',request_info.quality);
else
    quality = '';
end
%
if request_info.file_format ~= ""
    format1 = strcat('&format=',request_info.file_format);
else
    format1 = '';
end
%
if request_info.longestOnly == 1
    longestO = '&longestonly=true';
else
    longestO = '';
end
% https://service.earthscope.org/fdsnws/dataselect/1/queryauth?net=IU&sta=ANMO&loc=01&cha=BHZ&quality=D&format=miniseed&minimumlength=0.1&longestonly=true&nodata=404
%minimumlength = strcat('&minimumlength=',request_info.min_length); no
%longer supported
nodata = '&nodata=404';
url = strcat(url_base,auth,net,sta,loc,cha,startT,endT,quality,format1,longestO,nodata);
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
%fprintf("Wrote %d bytes to %s\n", count, tmp);
% Verify file exists
if ~isfile(tmp)
    error("Temporary file not found after write: %s", tmp);
end
% Now call the reader (example: rdmseed). Convert to char again if required.
%try
    S = rdmseed(tmp); % this function is from File Exchange!!
%catch ME
 %   error('You must download rdmseed from File Exchange: https://www.mathworks.com/matlabcentral/fileexchange/28803-rdmseed-and-mkmseed-read-and-write-miniseed-files. If the function is already downloaded, make sure it is discoverable on your MATLAB path!')
%end
% Clean up
delete(tmp);
end

%[appendix]{"version":"1.0"}
%---
%[metadata:styles]
%   data: {"heading1":{"color":"#268cdd"},"heading2":{"color":"#edb120"},"referenceBackgroundColor":"#262626"}
%---
