#!/usr/bin/env python3

from os import path
import sys
import json
import re
import makoc
import zedo
class Object: pass


def main():
    print("ARCHIVE", file=zedo.rooterr)
    zedo.ifchange("templates/base.html.mako", "templates/archive.html.mako")
    published = "articles.txt"
    zedo.ifchange(published)
    with open(published, 'rt', encoding="utf-8") as fp:
        lines = fp.readlines()
    by_date, by_tag = render_links(lines)
    html = makoc.compile("archive.html.mako", by_date=by_date, by_tag=by_tag)
    sys.stdout.write(html)

def render_links(lines):
    objs, by_tag = [], dict()
    lines = list(line.strip(" \t\n\r") for line in lines if line.strip(" \t\n\r"))
    zedo.ifchange(*("articles/{}.html".format(line) for line in lines))
    for line in lines:
        obj, tags = render_link(line)
        objs.append(obj)
        for tag in tags:
            if tag not in by_tag:
                by_tag[tag] = []
            by_tag[tag].append(obj)
    objs = sorted(objs, key=lambda obj: obj.published, reverse=True)
    for tag, tagObjs in by_tag.items(): # WARNING tagObjs can't be just objs, because that would overwrite the objs that gets returned smh
        by_tag[tag] = sorted(tagObjs, key=lambda obj: obj.published, reverse=True)
    return objs, by_tag

def render_link(line):
    articleUrl = "articles/{}.html".format(line)
    articleMeta = path.join("articles", line+".html.meta")
    with open(articleMeta, 'rt', encoding="utf-8") as meta:
        meta = json.loads(meta.read())
    obj = Object()
    obj.title = meta['title']
    obj.url = articleUrl
    obj.published = meta['published']
    obj.updated = meta['updated']
    obj.tags = meta['tags']
    return obj, meta['tags']


if __name__ == "__main__":
    main()
