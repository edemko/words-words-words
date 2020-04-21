from os import path
import markdown

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
        # FIXME add math formatting
        ],
    extension_configs={
        "codehilite": { "guess_lang": False },
    },
    output_format="html5",
)


def compile(input):
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
