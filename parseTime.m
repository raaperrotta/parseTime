function str = parseTime(seconds)
% Parses a number in seconds into a human readable string of the following
% units: {'year','week','day','hour','minute','second'}
%
% Created by Robert Perrotta

% Should add optional precision specifier and determine auto-precision based on
% input time, rather than just using 2 decimal places always.

% Will attach minus sign later if needed
isneg = seconds < 0;
seconds = abs(seconds);

units = {'year','week','day','hour','minute','second'};

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

% only keep 2 digits of precision
% seconds = round(seconds,2); % Only works with R2014b and newer
seconds = round(seconds*100)/100; % Works with R2014a and older, too

values = [years,weeks,days,hours,minutes,seconds];

% Remove units attached to zeros
i = values==0;
if all(i)
    str = '0';
    return
end
values(i) = [];
units(i) = [];

% Append 's' to pluralize units as needed
i = values~=1;
units(i) = cellfun(@(unit)[unit,'s'],units(i),'UniformOutput',false);

if length(units)>2 % need commas (incl. Oxford comma) and 'and'
    units(1:end-1) = cellfun(@(unit)[unit,', '],units(1:end-1),'UniformOutput',false);
    units{end-1} = [units{end-1},'and '];
elseif length(units)>1 % don't need a comma, just an 'and'
    units{end-1} = [units{end-1},' and '];
end

for i=1:length(units)-1 % only seconds can ever be non-integer
    units{i} = [num2sepstr(values(i),'%d'),' ',units{i}];
end
if mod(values(end),1) >= 0.005
    units{end} = [num2sepstr(values(end),'%.2f'),' ',units{end}];
else
    units{end} = [num2sepstr(values(end),'%.0f'),' ',units{end}];
end

str = [units{:}];

if isneg
    str = ['-',str];
end
