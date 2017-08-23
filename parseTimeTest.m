function tests = parseTimeTest
tests = functiontests(localfunctions);
end

function testGeneric(testCase)
verifyEqual(testCase,parseTime(3600*24*365-1),'52 weeks, 23 hours, 59 minutes, and 59 seconds')
verifyEqual(testCase,parseTime(3600*24*365-1.1),'52 weeks, 23 hours, 59 minutes, and 59 seconds')
verifyEqual(testCase,parseTime(123456789),'3 years, 47 weeks, 4 days, 21 hours, 33 minutes, and 9 seconds')
end
function testZero(testCase)
verifyEqual(testCase,parseTime(0),'0')
verifyEqual(testCase,parseTime(1e-9),'0')
verifyEqual(testCase,parseTime(-1e-9),'0')
end
function testSingularSecond(testCase)
verifyEqual(testCase,parseTime(1),'1.000 seconds')
verifyEqual(testCase,parseTime(1.0001),'1.000 seconds')
verifyEqual(testCase,parseTime(1, 1),'1.0 seconds')
verifyEqual(testCase,parseTime(1, 0),'1 second')
verifyEqual(testCase,parseTime(61, 1),'1 minute and 1.0 seconds')
verifyEqual(testCase,parseTime(61, 0),'1 minute and 1 second')
end
function testUnitOmission(testCase)
verifyEqual(testCase,parseTime(60),'1 minute')
verifyEqual(testCase,parseTime(7200),'2 hours')
verifyEqual(testCase,parseTime(7201),'2 hours and 1 second')
verifyEqual(testCase,parseTime(7380),'2 hours and 3 minutes')
verifyEqual(testCase,parseTime(3600*24*365),'1 year')
end
function testNegative(testCase)
verifyEqual(testCase,parseTime(-1e-9),'0')
verifyEqual(testCase,parseTime(-1),'-1.000 seconds')
verifyEqual(testCase,parseTime(1-3600*24*365),'-52 weeks, 23 hours, 59 minutes, and 59 seconds')
verifyEqual(testCase,parseTime(1.1-3600*24*365),'-52 weeks, 23 hours, 59 minutes, and 59 seconds')
verifyEqual(testCase,parseTime(-123456789),'-3 years, 47 weeks, 4 days, 21 hours, 33 minutes, and 9 seconds')
end
function testPrecision(testCase)
verifyEqual(testCase,parseTime(1e-6),'0.000001 seconds')
verifyEqual(testCase,parseTime(-1e-6),'-0.000001 seconds')
verifyEqual(testCase,parseTime(1e-6,7),'0.0000010 seconds')
verifyEqual(testCase,parseTime(1e-6,5),'0')
verifyEqual(testCase,parseTime(1+1e-6,5),'1.00000 seconds')
verifyEqual(testCase,parseTime(1+5e-6,5),'1.00001 seconds')
verifyEqual(testCase,parseTime(0.999,3),'0.999 seconds')
verifyEqual(testCase,parseTime(0.9994999,3),'0.999 seconds')
verifyEqual(testCase,parseTime(0.9995,3),'1.000 seconds')
verifyEqual(testCase,parseTime(0.99995,4),'1.0000 seconds')
% Have to watch out for that rounding to avoid '1.0000 seconds'
verifyEqual(testCase,parseTime(0.99995),'1.000 seconds')
verifyEqual(testCase,parseTime(-0.99995),'-1.000 seconds')
verifyEqual(testCase,parseTime(-9.9995),'-10.000 seconds')
end
function testWithNum2SepStr(testCase)
assumeNotEmpty(testCase, which('num2sepstr.m'), ...
    'Could not find num2sepstr to use in this test.')
verifyEqual(testCase,parseTime(1-3600*24*365),'-52 weeks, 23 hours, 59 minutes, and 59 seconds')
verifyEqual(testCase,parseTime(1e12),'31,709 years, 41 weeks, 2 days, 1 hour, 46 minutes, and 40 seconds')
verifyEqual(testCase,parseTime(-1e12),'-31,709 years, 41 weeks, 2 days, 1 hour, 46 minutes, and 40 seconds')
verifyEqual(testCase,parseTime(1e6*365*3600*24),'1,000,000 years')
end
function testBadInputErrors(testCase)
verifyError(testCase, @() parseTime('Hello!'), 'parseTime:badSeconds')
verifyError(testCase, @() parseTime('Hello!', 1), 'parseTime:badSeconds')
verifyError(testCase, @() parseTime(1, -1), 'parseTime:badPrecision')
verifyError(testCase, @() parseTime(1, 1.1), 'parseTime:badPrecision')
end