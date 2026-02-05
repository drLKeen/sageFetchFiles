classdef sageFetchObj
% Made to follow similar syntax to irisFetch and mimic its
% capabilities.
% Functionality to be added to mimic irisFetch:
% Catalog(), Resp()
%
% SAGEFETCH allows seamless access to data stored within the SAGE-DMC via 
% IRIS web services (IRISWS)
%
% sageFetch Methods:
%
% sageFetch waveform retrieval Methods:
%    Timseries - retrieve sac-equivalent waveforms with channel metadata
%
% sageFetch miscellaneous Methods:
%   under development
%
%  For additional guidance, type help <method>

%
%
   properties (Constant = true)
     VERSION           = '1.0';  % sageFetch version number
     DATE_FORMATTER    = 'yyyy-mm-dd HH:MM:SS.FFF'; %default data format, in ms NEED TO ADD A "T"

     VALID_QUALITIES   = {'D','R','Q','M','B'}; % list of Qualities accepted by Traces
     DEFAULT_QUALITY   = 'M'; % default Quality for Traces
     FETCHER_LIST      = {'Timeseries','Catalog','Resp'}; % list of functions that fetch
     URL_BASE          = {'https://service.iris.edu/irisws/'};
   end %constant properties


   methods(Static)
%
function S = Timeseries(network, station, location, channel, startDate, endDate, varargin)
% Timeseries  Retrieve SAC-equivalent waveform(s) with optional behaviours.
% Required inputs:
%   network, station, location, channel - char/string (can use wildcards/comma lists)
%   startDate, endDate                 - 'YYYY-MM-DD hh:mm:ss' or with .sss
% Optional name-value pairs:
%   'correction'  - char scalar. default: 'none'    (examples: 'none','remove_response')
%   'fileFormat' - char scalar. default: 'sac'     (examples: 'sac','mseed')
%   'useAuth'     - logical scalar. default: false
    import matlab.net.*
    import matlab.net.http.*

    str2webdate = @(x) strrep(x,' ', 'T'); % 'YYYY-MM-DD hh:mm:ss' -> 'YYYY-MM-DDThh:mm:ss'
    web2strdate = @(x) strrep(x,'T',' ');

    % basic validation for required args (expand as needed)
    validateattributes(network, {'char','string'}, {'nonempty'});
    validateattributes(station, {'char','string'}, {'nonempty'});
    validateattributes(location, {'char','string'}, {}); % location may be empty
    validateattributes(channel, {'char','string'}, {'nonempty'});
    validateattributes(startDate, {'char','string'}, {'nonempty'});
    validateattributes(endDate, {'char','string'}, {'nonempty'});

    % ---- inputParser setup ----
    p = inputParser;
    p.FunctionName = mfilename;
    addRequired(p,'network');
    addRequired(p,'station');
    addRequired(p,'location');
    addRequired(p,'channel');
    addRequired(p,'startDate');
    addRequired(p,'endDate');

    % defaults and validators
    defaultCorrection = 'none';
    validCorrections = {'none','correction'}; % extend as needed
    checkCorrection = @(x) ischar(x) || isstring(x) && any(strcmpi(char(x), validCorrections));

    defaultFileFormat = 'sac';
    validFormats = {'sac','miniseed'};
    checkFormat = @(x) ischar(x) || isstring(x) && any(strcmpi(char(x), validFormats));

    defaultUseAuth = false;
    checkUseAuth = @(x) islogical(x) || (isnumeric(x) && isscalar(x));

    addParameter(p,'correction', defaultCorrection, checkCorrection);
    addParameter(p,'fileFormat', defaultFileFormat, checkFormat);
    addParameter(p,'useAuth', defaultUseAuth, checkUseAuth);

    parse(p, network, station, location, channel, startDate, endDate, varargin{:});
    opts = p.Results;

    % Determine which optional parameters were explicitly provided
    allOptNames = {'correction','fileFormat','useAuth'};
    provided = setdiff(allOptNames, p.UsingDefaults);

    % Example conditional behaviors based on explicit specification:
    % (Replace these placeholders with real operations.)
    if ismember('correction', provided)
        corr = lower(char(opts.correction));
        switch corr
            case 'none'
                % explicit request: no correction
                opts.scale = '';
                opts.correction = '';

            case 'TotalSensitivity'
                % explicit request: plan to remove instrument response
                opts.scale = '&scale=AUTO';
                opts.correction = '';

            case 'InstrumentCorrection'
                opts.scale = '';
                opts.correction = '&correct=true';

                
            otherwise
                % unreachable due to validation, but kept for clarity
        end
    else
        opts.scale = '';
        opts.correction = '';
    end

    if ismember('fileFormat', provided)
        fmt = lower(char(opts.fileFormat));
        switch fmt
            case 'sac'
                % user explicitly requested SAC format
                opts.fileFormat = 'SAC.zip';
            case 'miniseed'
                % user explicitly requested MiniSEED
                opts.fileFormat = 'miniseed';
        end
    end

    if ismember('useAuth', provided)
        opts.useAuth = true;
    end

    if opts.useAuth == true
        % user explicitly requested authentication; enable auth flow
        % e.g., prepare credentials or token retrieval
        opts.Auth = 'auth'; % This is a placeholder as there is currently no use authentication option for irisws timeseries
    else
        % user explicitly requested no auth
        opts.Auth = '';
    end

    % ---- Core retrieval logic (placeholder) ----
    % Use network/station/location/channel and startDate/endDate to fetch data.
    % Convert dates for web APIs: startWeb = str2webdate(startDate);
    % Respect opts.correction, opts.fileFormat, opts.useAuth and whether they were provided.
    %
    % Replace the following placeholder return with real timeseries/struct/timetable:
    ts = struct();
    ts.network = network;
    ts.station = station;
    ts.location = location;
    ts.channel = channel;
    ts.startDate = startDate;
    ts.endDate = endDate;
    ts.options = opts;
    ts.provided = provided;
    

    %-------------------------------------------------------------------%
    %-------------------------------------------------------------------%
    % Build the data URL based on inputs and what retreival service you're
    % using
    
    auth = strcat('query',ts.options.Auth,'?');
    sta = strcat('&sta=',ts.station);
    cha = strcat('&cha=',ts.channel);
    format1 = strcat('&format=',ts.options.fileFormat);
    net = strcat('net=',ts.network);
    loc = strcat("&loc=",ts.location);
    startT = strcat('&start=',str2webdate(ts.startDate));
    endT = strcat('&end=',str2webdate(ts.endDate));
    scale = ts.options.scale;
    correct = ts.options.correction;
    

    
    baseURL = 'https://service.iris.edu/irisws/';
    url = strcat(baseURL,'timeseries/1/',auth,net,sta,cha,startT,endT,scale,format1,loc,correct)

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

    if strcmp(ts.options.fileFormat, 'miniseed')
    % Now call the reader (example: rdmseed). Convert to char again if required.
    %try
        S = rdmseed(tmp); % this function is from File Exchange!!
    %catch ME
     %   error('You must download rdmseed from File Exchange: https://www.mathworks.com/matlabcentral/fileexchange/28803-rdmseed-and-mkmseed-read-and-write-miniseed-files. If the function is already downloaded, make sure it is discoverable on your MATLAB path!')
    %end
    
    elseif strcmp(ts.options.fileFormat,'sac.zip')
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
end
      
end
