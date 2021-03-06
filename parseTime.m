function str = parseTime(seconds,precision)
% Parses a number in seconds into a human readable string of the following
% units: {'year','week','day','hour','minute','second'}
%
% str = parseTime(seconds) converts the number of seconds input to a string
%   representing that value in units of years, weeks, days, hours, minutes,
%   and seconds.
%
% str = parseTime(seconds,precision) additionally specifies the number of
%   digits printed after the decimal point in seconds. If this is not
%   specified and seconds is a float or double, the seconds value is
%   printed between zero and six digits past the decimal point to provide
%   four significant digits. When seconds is an integer type, the default
%   behavior is to print no decimal places.
%
% Created by Robert Perrotta

% Check inputs
assert(isnumeric(seconds), 'parseTime:badSeconds', ...
    'Seconds must be a number or array of numbers.')
if nargin >= 2
    assert(isscalar(precision) & mod(precision,1)==0 & precision>=0, ...
        'parseTime:badPrecision', ...
        'Precision must be a non-negative integer!')
    precision = repmat(precision, size(seconds));
end

if nargin == 1 % auto-determine precision
    if isfloat(seconds)
        sig_figs = 4;
        % account for possible rounding by 1/2 the decimal past the sig_figs
        after_decimal = sig_figs - 1 - floor(log10(abs(seconds)+(10^-sig_figs)/2));
        precision = max(min(after_decimal, 6), 0);
    else
        precision = zeros(size(seconds));
    end
end

% If input is array, return cell with results of each called separately
if numel(seconds) > 1
    str = arrayfun(@(s, p) parseTime(s, p), seconds, precision, ...
        'Uniform', false);
    return
end

if isfloat(seconds)
    % seconds = round(seconds,precision); % Only works with R2014b and newer
    seconds = round(seconds*10^precision)/10^precision; % Works with R2014a and older, too
else
    seconds = double(seconds);
end

% Will attach minus sign later if needed
isneg = seconds < 0;
seconds = abs(seconds);

units = {'year', 'week', 'day', 'hour', 'minute', 'second'};

years = floor(seconds/31536000);
seconds = seconds - years*31536000;

weeks = floor(seconds/604800);
seconds = seconds - weeks*604800;

days = floor(seconds/86400);
seconds = seconds - days*86400;

hours = floor(seconds/3600);
seconds = seconds - hours*3600;

minutes = floor(seconds/60);
seconds = seconds - minutes*60;

values = [years, weeks, days, hours, minutes, seconds];

% Remove units attached to zeros
i = values==0;
if all(i)
    str = '0';
    return
end
values(i) = [];
units(i) = [];

% Append 's' to pluralize units as needed
% Seconds are always plural unless precision is 0 and value is 1
i = values~=1 | (strcmp(units,'second') & precision~=0);
units(i) = cellfun(@(unit)[unit,'s'],units(i),'UniformOutput',false);

if length(units)>2 % need commas (incl. Oxford comma) and 'and'
    units(1:end-1) = cellfun(@(unit)[unit,', '],units(1:end-1),'UniformOutput',false);
    units{end-1} = [units{end-1},'and '];
elseif length(units)>1 % don't need a comma, just an 'and'
    units{end-1} = [units{end-1},' and '];
end

% Use num2sepstr if present. Otherwise use num2str.
% (only years could be >= 1,000)
if isempty(which('num2sepstr'))
    tostr = @(varargin) num2str(varargin{:});
else
    tostr = @(varargin) num2sepstr(varargin{:});
end

for i=1:length(units)-1 % only seconds can ever be non-integer
    units{i} = [tostr(values(i),'%d'),' ',units{i}];
end

if strcmp(units{end},'seconds')
    units{end} = [num2str(values(end),['%.',num2str(precision),'f']),' ',units{end}];
else
    units{end} = [tostr(values(end),'%d'),' ',units{end}];
end

str = [units{:}];

if isneg
    str = ['-',str];
end
