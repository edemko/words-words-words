#!/usr/bin/env python3

class Object: pass
import os, sys, json
import mdc
import makoc
import zedo

outFile, basename = sys.argv[1:3]
metaTmp = outFile+".meta"
print(basename, file=sys.stderr) # DEBUG
srcFile = zedo.ifchange(basename+".md", find=True)
# TODO zedo ifchange the templates
with open(srcFile, 'rt', encoding="utf-8") as fp:
    src = fp.read()

html, meta = mdc.compile(src)
article = Object()
article.title = meta.get('title', "Untitled")
article.published = meta.get('published', "unpublished")
article.tags = ", ".join(meta.get('tags', []))
article.content = html
html = makoc.compile("article.html.mako", article=article)

with open(outFile, 'wt', encoding="utf-8") as fp:
    fp.write(html)
with open(metaTmp, 'wt', encoding="utf-8") as fp:
    fp.write(json.dumps(meta))

metaOut = zedo.find(basename+".html")+".meta"
os.rename(metaTmp, metaOut)
