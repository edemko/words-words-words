#!/usr/bin/env python3

from os import path
import sys
import json
import re
import makoc
import zedo

class Object:
    pass

def main(outFp):
    published = "articles.txt"
    published = zedo.ifchange(published, find=True)
    with open(published, 'rt', encoding="utf-8") as fp:
        lines = fp.readlines()
    by_date, by_tag = render_links(lines)
    html = makoc.compile("archive.html.mako", by_date=by_date, by_tag=by_tag)
    outFp.write(html)

def render_links(lines):
    objs, by_tag = [], dict()
    lines = list(line.strip(" \t\n\r") for line in lines if line.strip(" \t\n\r"))
    zedo.ifchange(*("articles/{}.html".format(line) for line in lines), find=True)
    for line in lines:
        obj, tags = render_link(line)
        objs.insert(0, obj)
        for tag in tags:
            if tag not in by_tag:
                by_tag[tag] = []
            by_tag[tag].insert(0, obj)
    return objs, by_tag

def render_link(line):
    articleUrl = "articles/{}.html".format(line)
    articleHtml = path.join(".zedo", "build", articleUrl) # FIXME
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
    with open(sys.argv[1], 'wt', encoding="utf-8") as outFp:
        main(outFp)
