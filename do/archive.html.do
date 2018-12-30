#!/usr/bin/env python3

from os import path
import json
import re
from mako.template import Template
from mako.lookup import TemplateLookup
import zedo

class Object:
    pass

def main(outFp):
    published = "articles.txt"
    published = zedo.ifchange(published, find=True)
    with open(published, 'rt', encoding="utf-8") as fp:
        lines = fp.readlines()
    by_date, by_tag = render_links(lines)
    t = tlookup.get_template("archive.html.mako")
    outFp.write(t.render(by_date = by_date, by_tag = by_tag))

def render_links(lines):
    objs, by_tag = [], dict()
    for line in lines:
        line = line.strip(" \t\n\r")
        if not line: continue
        obj, tags = render_link(line)
        objs.insert(0, obj)
        for tag in tags:
            if tag not in by_tag:
                by_tag[tag] = []
            by_tag[tag].insert(0, obj)
    return objs, by_tag

def render_link(line):
    articleUrl = "articles/{}.html".format(line)
    articleHtml = zedo.ifchange(articleUrl, find=True)
    articleMeta = articleHtml + ".meta"
    with open(articleMeta, 'rt', encoding="utf-8") as meta:
        meta = json.loads(meta.read())
    obj = Object()
    obj.title = meta['title']
    obj.url = articleUrl
    obj.published = meta['published']
    obj.tags = meta['tags']
    return obj, meta['tags']


if __name__ == "__main__":
    zedo.ifchange("templates/base.html.mako")
    zedo.ifchange("templates/archive.html.mako")

    import sys
    templDir = "src/templates"
    cacheDir = path.join(templDir, ".cache")
    tlookup = TemplateLookup(directories=[templDir], module_directory=cacheDir)
    with open(sys.argv[1], 'wt', encoding="utf-8") as outFp:
        main(outFp)
