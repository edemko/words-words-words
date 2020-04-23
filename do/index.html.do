#!/usr/bin/env python3

class Object: pass
import sys
from os import path
import zedo, mdc, makoc, json

def main():
    zedo.ifchange("templates/base.html.mako")
    zedo.ifchange("templates/archive.html.mako")
    zedo.ifchange("templates/index.html.mako")

    indexFile = "index.md"
    zedo.ifchange(indexFile)
    with open(indexFile, 'rt', encoding="utf-8") as fp:
        index = fp.read()
    index, _ = mdc.compile(index)

    published = "articles.txt"
    zedo.ifchange(published)
    with open(published, 'rt', encoding="utf-8") as fp:
        lines = fp.readlines()
    latest = load_latest(lines)
    with open(latest.mdFile, 'rt', encoding='utf-8') as fp:
        latest.html, _ = mdc.compile(fp.read())

    pinned = "pinned.txt"
    zedo.ifchange(pinned)
    with open(pinned, 'rt', encoding="utf-8") as fp:
        lines = fp.readlines()
    pinned = render_links(lines)

    html = makoc.compile("index.html.mako"
        , content=index
        , latest=latest
        , pinned=pinned
        )

    sys.stdout.write(html)


def load_latest(lines):
    latest, filepath = None, None
    lines = list(line.strip(" \t\n\r") for line in lines if line.strip(" \t\n\r"))
    zedo.ifchange(*("articles/{}.html".format(line) for line in lines))
    for line in lines:
        obj = load_article(line)
        if latest is None or latest.published < obj.published:
            latest = obj
    latest.mdFile = "articles/{}.md".format(line)
    return latest

def load_article(line):
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
    return obj

def render_links(lines):
    objs = []
    lines = list(line.strip(" \t\n\r") for line in lines if line.strip(" \t\n\r"))
    zedo.ifchange(*("articles/{}.html".format(line) for line in lines))
    for line in lines:
        obj = render_link(line)
        objs.append(obj)
    return objs

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
    return obj

if __name__ == '__main__':
    main()
