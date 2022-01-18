from os import path
import re
from datetime import date, time, datetime, timezone
from feedgen.feed import FeedGenerator
import json

def main(outDir, articles):
    fg = init_feed()
    for articlePath in articles:
        articlePath = articlePath.strip(" \t\n\r")
        if not articlePath: continue
        articleName = re.sub(r"\.html$", "", path.basename(articlePath))
        mk_feed_entry(fg, articleName, articlePath+".meta")
    fg.atom_file(path.join(outDir, "atom.xml"))
    fg.rss_file(path.join(outDir, "rss.xml"))

def init_feed():
    fg = FeedGenerator()
    fg.title("A Poorer Molecular Biologist")
    fg.author({
        "name": "Eric Demko",
        "email": "zankoku.okuno@gmail.com",
        })
    # FIXME re-configurable domain
    fg.id("http://blag.edemko.net")
    fg.link(href="http://blag.edemko.net", rel="alternate")
    # fg.logo("some url")
    fg.subtitle("I write things sometimes.")
    fg.link(href="http://blag.edemko.net/rss.xml", rel="self")
    fg.language("en")
    return fg

def mk_feed_entry(fg, articleName, articleMeta):
    with open(articleMeta, 'rt', encoding="utf-8") as fp:
        meta = json.loads(fp.read())
    fe = fg.add_entry()
    fe.id("http://blag.edemko.net/articles/{}".format(articleName))
    fe.link(href="http://blag.edemko.net/articles/{}.html".format(articleName), rel="alternate")
    fe.title(meta["title"])
    fe.published(adapt_date(meta['published']))
    # fe.updated(adapt_date(meta['published'])) # FIXME find the latest date from published and updateds
    # TODO more metadata
    return fe

def adapt_date(d):
    d = datetime.strptime(d, "%Y-%m-%d")
    d = d.replace(tzinfo=timezone.utc)
    return d


if __name__ == "__main__":
    # FIXME call as `$0 $outDir < $articles`
    import sys
    outDir = sys.argv[1]
    main(outDir, sys.stdin.readlines())
