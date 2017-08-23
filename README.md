# parseTime

Parses a number in seconds into a human readable string of the following
units: {'year','week','day','hour','minute','second'}

`str = parseTime(seconds)` converts the number of seconds input to a string
  representing that value in units of years, weeks, days, hours, minutes,
  and seconds.

`str = parseTime(seconds,precision)` additionally specifies the number of
  digits printed after the decimal point in seconds. If this is not
  specified, the seconds value is printed between zero and six digits
  past the decimal point to provide four significant digits.

```
>> parseTime(61)
ans =
    '1 minute and 1.00 seconds'
>> parseTime(61, 0)
ans =
    '1 minute and 1 second'
>> parseTime(3600*24*365-1)
ans =
    '52 weeks, 23 hours, 59 minutes, and 59 seconds'
>> parseTime(-123456789)
ans =
    '-3 years, 47 weeks, 4 days, 21 hours, 33 minutes, and 9 seconds'
>> parseTime(525600 * 60)
ans =
    '1 year'
```
