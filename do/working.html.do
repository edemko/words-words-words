#!/usr/bin/env python3

# FIXME this is a near-copy of archive.md.do

import subprocess as sh
import os, sys
from os import path
from glob import glob
import json
import zedo
import makoc

class Object: pass

def main():
    print("WORKING", file=zedo.rooterr)
    # FIXME and it'd be nice to generate template dependencies from within mako itself
    zedo.ifchange("templates/base.html.mako", "templates/working.html.mako")
    published = "articles.txt"
    zedo.ifchange(published)
    with open(published, 'rt', encoding="utf-8") as fp:
        published = { line.strip(' \t\n\r') for line in fp.readlines() }
    # FIXME I need a way to glob source (and build?) directories
    # it'd be super helpful to also be able to get the matching file paths back
    src_articleDir = path.join(os.getenv("ZEDO__ROOT"), os.getenv("SRC"), "articles")
    all_articles = { path.basename(x)[:-3] for x in glob(path.join(src_articleDir, "*.md")) }
    articles, _ = render_links(all_articles - published)
    html = makoc.compile("working.html.mako", articles=articles)
    sys.stdout.write(html)


# FIXME the functions below here, I should probly import from archive.html.do
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
    zedo.ifchange(articleUrl)
    with open(articleUrl+".meta", 'rt', encoding="utf-8") as meta:
        meta = json.loads(meta.read())
    obj = Object()
    obj.title = meta.get('title', "Untitled")
    obj.url = articleUrl
    obj.published = meta.get('published', "unpublished")
    obj.tags = meta.get('tags', [])
    return obj, meta['tags']


if __name__ == "__main__":
    main()
