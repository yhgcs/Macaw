#!/usr/bin/python

import sys

from selenium import webdriver
from selenium.webdriver.common.keys import Keys

# Take SVG as an input and customize drawsvg.html 
filename=sys.argv[1]
print "filename =", filename
htmlfile='drawsvg.html'
x=open(htmlfile, 'r').read()
y=x.replace('SVG_FILE_TO_PROCESS', filename)
out=open(htmlfile, 'w')
out.write(y)
out.close()

# Open browser to render and save file as PNG
driver = webdriver.Chrome(executable_path="/usr/local/bin/chromedriver")
driver.get("http://localhost:8008/drawsvg.html")
driver.close()
