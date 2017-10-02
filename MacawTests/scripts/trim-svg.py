#!/usr/bin/python

import sys
from lxml import etree

filename = sys.argv[1]

d = etree.parse(filename)
toremove = []
for svg in d.iter('*'):
    if (svg.attrib.has_key('id') and svg.attrib['id'] == 'revision') \
    or svg.prefix == 'd' \
    or svg.tag == '{http://www.w3.org/2000/svg}title':
        toremove.append(svg)

map(lambda x:x.getparent().remove(x), toremove)

print(etree.tostring(d, pretty_print=True))
