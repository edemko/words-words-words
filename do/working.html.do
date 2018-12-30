#!/usr/bin/env python3

# FIXME this is a near-copy of archive.md.do

import subprocess as sh
from os import path
from glob import glob
import json
import re
import zedo
from mako.template import Template
from mako.lookup import TemplateLookup

class Object:
    pass

def main(outFp):
    published = "articles.txt"
    published = zedo.ifchange(published, find=True)
    with open(published, 'rt', encoding="utf-8") as fp:
        published = {line.strip(' \t\n\r') for line in fp.readlines()}
    all_articles = {re.sub(r"^src/articles/(.*)\.md$", r"\1", x)
                    for x in glob("src/articles/*.md")}
    articles, _ = render_links(all_articles - published)
    t = tlookup.get_template("working.html.mako")
    outFp.write(t.render(articles = articles))

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
    obj.title = meta.get('title', "Untitled")
    obj.url = articleUrl
    obj.published = meta.get('published', "unpublished")
    obj.tags = meta.get('tags', [])
    return obj, meta['tags']


if __name__ == "__main__":
    # FIXME and it'd be nice to generate template dependencies from within mako itself
    zedo.ifchange("templates/base.html.mako", "templates/working.html.mako")

    import sys
    # FIXME this stuff should really go into some sort of common module
    templDir = "src/templates"
    cacheDir = path.join(templDir, ".cache")
    tlookup = TemplateLookup(directories=[templDir], module_directory=cacheDir)
    with open(sys.argv[1], 'wt', encoding="utf-8") as outFp:
        main(outFp)
