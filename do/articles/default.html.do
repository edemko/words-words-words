#!/usr/bin/env python3

class Object: pass
from os import path
import os, sys, json, glob
import mdc
import makoc
import zedo


print("article: {}".format(zedo.name), file=zedo.rooterr)

zedo.ifchange("/templates/article.html.mako")

# print(sys.argv[1:], file=sys.stderr) # DEBUG
# print(zedo.name, file=sys.stderr) # DEBUG

srcFile = zedo.name+".md"
zedo.ifchange(srcFile)
with open(srcFile, 'rt', encoding="utf-8") as fp:
    html, meta = mdc.compile(fp.read())

# print(meta, file=sys.stderr) # DEBUG


article = Object()
article.title = meta.get('title', "Untitled")
article.published = meta.get('published', "unpublished")
article.updated = ", ".join(meta.get('updated', []))
article.tags = ", ".join(meta.get('tags', []))
article.content = html

# FIXME I need a good way to get an absolute path for an outputted file
# alternately, run default files from the location of the default rather than the target
html = makoc.compile("article.html.mako", article=article)
with open(zedo.name+zedo.ext, 'wt', encoding="utf-8") as fp:
    fp.write(html)
# print("done with html", file=sys.stderr) # DEBUG

# FIXME use a tempfile, probably from zedo
with open(zedo.name+".html.meta", 'wt', encoding="utf-8") as fp:
    fp.write(json.dumps(meta))
# print("done with meta", file=sys.stderr) # DEBUG
