#!/usr/bin/env python3

class Object: pass
import makoc
import zedo, mdc
import sys

print("page: {}".format(zedo.name), file=zedo.rooterr)


zedo.ifchange("templates/base.html.mako")
zedo.ifchange("templates/bare.html.mako")

srcFile = zedo.name+".md"

zedo.ifchange(srcFile)
with open(srcFile, 'rt', encoding="utf-8") as fp:
    src = fp.read()

html, _ = mdc.compile(src)
html = makoc.compile("bare.html.mako", content=html)

sys.stdout.write(html)
