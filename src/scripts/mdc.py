#!/usr/bin/env python3

from os import path
import markdown
import json
from mako.template import Template
from mako.lookup import TemplateLookup

class Object:
    pass

md = markdown.Markdown(
    extensions=
        [ "extra"
        , "sane_lists"
        , "meta"
        , 'mdx_superscript', 'subscript'
        , "smarty"
        , "admonition"
        , "codehilite"
        , "markdown_checklist.extension"
        ],
    output_format="html5",
)

def main(inFile, outFile):
    t = tlookup.get_template("bare.html.mako")
    with open(inFile, 'rt', encoding="utf-8") as fp:
        html = md.convert(fp.read())
    with open(outFile, 'wt', encoding='utf-8') as fp:
        html = t.render(content=html)
        fp.write(html)

def article(templDir, inFile, outFile, metaFile):
    t = tlookup.get_template("article.html.mako")
    with open(inFile, 'rt', encoding="utf-8") as fp:
        html = md.convert(fp.read())
        meta = md.Meta
        # TODO If I use these conversions, too many <p> tags get inserted and destroy everything
        # if "title" in meta:
        #     meta["title"] = [md.convert(x) for x in meta["title"]]
        # if "tag" in meta:
        #     meta["tag"] = [md.convert(x) for x in meta["tag"]]
    with open(outFile, 'wt', encoding='utf-8') as fp:
        article = Object()
        article.title = meta.get('title', ["Untitled"])[0]
        article.published = meta.get('published', ["unpublished"])[0]
        article.tags = ", ".join(meta.get('tag', []))
        article.content = html
        html = t.render(article=article)
        fp.write(html)
    for prop in ["title", "published"]:
        if prop in meta:
            meta[prop] = meta[prop][0]
    if 'tag' in meta:
        meta['tags'] = meta['tag']
        del meta['tag']
    else:
        meta['tags'] = []
    with open(metaFile, 'wt', encoding='utf-8') as fp:
        fp.write(json.dumps(meta))


if __name__ == "__main__":
    import sys
    templDir, inFile, outFile = sys.argv[1:4]
    cacheDir = path.join(templDir, ".cache")
    tlookup = TemplateLookup(directories=[templDir], module_directory=cacheDir)
    if "--article" in sys.argv[4:]:
        article(templDir, inFile, outFile, outFile+".meta")
    else:
        main(inFile, outFile)
