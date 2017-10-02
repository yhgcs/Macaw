#!/usr/bin/python

import sys
import csv
from pprint import pprint

PASS_THRESHOLD = 0.06
ORIGINAL_SUITE = set(map(lambda z: str.strip(z), open('original-test-suite.txt', 'r').readlines()))

if len(sys.argv) != 2:
    print "usage: calc-metrics.py <A.csv> <B.csv>"
    exit(1)

def parse(filename):
    data = map(lambda z: str.strip(z), open(filename, 'r').readlines())
    r = {}
    for l in data:
        name, pixels, diff = l.split(',')
        r[name] = {'pixels':pixels, 'diff':diff}
    return r

filename = sys.argv[1]
data = parse(filename)

if not set(data.keys()).issubset(ORIGINAL_SUITE):
    print "Test names from " + filename + " is not a subset of original test suite, difference:"
    pprint(data.keys().difference(ORIGINAL_SUITE))
    exit(1)

FAILED_TO_PARSE = ORIGINAL_SUITE.difference(data.keys())
PASSED = set()

for k in data:
    if float(data[k]['diff']) < PASS_THRESHOLD:
        PASSED.add(k)

total = float(len(ORIGINAL_SUITE))
passedPercentage = float(len(PASSED))/total*100
failedToParsePercentage = float(len(FAILED_TO_PARSE))/total*100
print "Tests passed (%, absolute value):", ",".join(map(lambda x:str(x), [passedPercentage, len(PASSED)]))
print "Tests failed (%, absolute value):", ",".join(map(lambda x:str(x), [100 - passedPercentage, len(ORIGINAL_SUITE)-len(PASSED)]))
print "Tests failed to parse (%, absolute value):", ",".join(map(lambda x:str(x),[str(failedToParsePercentage), len(FAILED_TO_PARSE)]))
print "Total amount of tests:", int(total)
