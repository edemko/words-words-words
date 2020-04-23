from os import path
import markdown, re

md = markdown.Markdown(
    extensions=
        [ "extra"
        , "sane_lists"
        , "meta"
        , "mdx_math"
        , 'mdx_superscript', 'subscript'
        , "smarty"
        , "admonition"
        , "codehilite"
        , "markdown_checklist.extension"
        ],
    extension_configs={
        "codehilite": { "guess_lang": False },
        "mdx_math": {
            "enable_dollar_delimiter": True,
            "add_preview": True,
        },
    },
    output_format="html5",
)


GFM2CODEHILITE = re.compile(r'^```([a-zA-Z0-9_-]+)$', flags=re.MULTILINE)

def compile(input):
    # NOTE this is to translate github-flavored codeblock syntax to codehilite syntax
    # and _why_ did they make this stuff up? were they earlier than github and decided to stick with it despite hell and high water?
    input = GFM2CODEHILITE.sub('```\n:::\\1', input)

    content = md.convert(input)
    meta = md.Meta
    prepare_meta(meta)
    return content, meta

def prepare_meta(rawmeta):
    for prop in ["title", "published"]:
        if prop in rawmeta:
            rawmeta[prop] = rawmeta[prop][0]
    if 'tag' in rawmeta:
        rawmeta['tags'] = rawmeta['tag']
        del rawmeta['tag']
    else:
        rawmeta['tags'] = []
