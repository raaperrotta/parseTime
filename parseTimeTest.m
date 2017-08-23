function tests = parseTimeTest
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% Record current MATLAB path, then resore the default path to ensure tests
% run without the use of helper functions. Record the whereabouts of
% num2sepstr (if present) for use in testWithNum2SepStr.
testCase.TestData.orig_path = path();
testCase.TestData.num2sepstr = which('num2sepstr.m');
restoredefaultpath()
end
function teardownOnce(testCase)
% Restore MATLAB path to state before these tests began.
path(testCase.TestData.orig_path)
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
% Have to watch out for rounding when auto-determining precision.
% Before fix, next test yielded '1.0000 seconds' (too many sig figs).
verifyEqual(testCase,parseTime(0.99995),'1.000 seconds')
verifyEqual(testCase,parseTime(-0.99995),'-1.000 seconds')
verifyEqual(testCase,parseTime(-9.9995),'-10.000 seconds')
end
function testWithNum2SepStr(testCase)
% Skip if num2sepstr was not on the MATLAB path when runtests was called.
assumeNotEmpty(testCase, testCase.TestData.num2sepstr, ...
    'Could not find num2sepstr to use in this test.')
orig_path = path();
restore = onCleanup(@() path(orig_path));
addpath(fileparts(testCase.TestData.num2sepstr))
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
function testNonDoubleSeconds(testCase)
verifyEqual(testCase,parseTime(single(1)),'1.000 seconds')
verifyEqual(testCase,parseTime(uint8(1)),'1 second')
verifyEqual(testCase,parseTime(uint64(1)),'1 second')
verifyEqual(testCase,parseTime(uint64([1, 2, 3])),{'1 second', '2 seconds', '3 seconds'})
verifyEqual(testCase,parseTime(uint64(1), 2),'1.00 seconds')
verifyEqual(testCase,parseTime(int16([1, 10, 100])),{'1 second', '10 seconds', '1 minute and 40 seconds'})
end
function testNonDoublePrecision(testCase)
verifyEqual(testCase,parseTime(1, uint8(2)),'1.00 seconds')
verifyEqual(testCase,parseTime(1, int16(1)),'1.0 seconds')
verifyEqual(testCase,parseTime([1, 2, 3], int32(2)),{'1.00 seconds', '2.00 seconds', '3.00 seconds'})
end
function testNonDoubleBoth(testCase)
verifyEqual(testCase,parseTime(uint64(1), single(2)),'1.00 seconds')
verifyEqual(testCase,parseTime(uint64(1), uint8(2)),'1.00 seconds')
verifyEqual(testCase,parseTime(int16(21), int32(3)),'21.000 seconds')
verifyEqual(testCase,parseTime(int16([1, 2, 3]), uint32(2)),{'1.00 seconds', '2.00 seconds', '3.00 seconds'})
end