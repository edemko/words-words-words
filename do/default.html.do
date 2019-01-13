#!/usr/bin/env python3

import makoc
import zedo, mdc
import sys
class Object: pass

outFile, basename = sys.argv[1:3]
srcFile = zedo.ifchange(basename+".md", find=True)

with open(srcFile, 'rt', encoding="utf-8") as fp:
    src = fp.read()

zedo.ifchange("templates/base.html.mako")
zedo.ifchange("templates/bare.html.mako")

html, _ = mdc.compile(src)
html = makoc.compile("bare.html.mako", content=html)

with open(outFile, 'wt', encoding="utf-8") as fp:
    fp.write(html)
