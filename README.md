# My Blog: A Poorer Molecular Biologist

The basic idea is to write in markdown, then generate static html.
The resulting site should be hostable entirely as static files.


## Developing

The build system is based on [zedo](https://github.com/Zankoku-Okuno/zedo); a shim is included.
The build scripts make use of `bash` and `python3` in a virtual environment.

Setting up for the first time looks like:

```sh
sudo apt install libxml2-dev libxslt-dev
cd /path/to/this/project
mkdir -p build
ln -s ../src/assets build
git submodule update --init zedo-shim
export PATH+=":$PWD/zedo-shim/bin"
python3 -m venv .venv-py3
source .venv-py3/bin/activate
pip install --upgrade pip
pip install -r do/requirements.txt
export PYTHONPATH+=":$PWD"
```

Subsequently:

```sh
cd /path/to/this/project
export PATH+=":$PWD/zedo-shim/bin"
source .venv-py3/bin/activate
export PYTHONPATH+=":$PWD"
```

optionally with:

```sh
git submodule update zedo-shim
pip install --upgrade pip
pip install --upgrade -r do/requirements.txt
```

Use `zedo all` to rebuild everything, but probably `zedo working.html` should be called while working on a new article.
Use `zedo httpd` (only after the other ones) to start up a testing server.
Distribute from the `build` directory after `zedo all`.


The major python dependencies are:

  * markdown (markdown-to-html)
  * Mako (html templates)
  * [feedgen](https://feedgen.kiesow.be/index.html) (generate rss/atom feeds)

There are also a handful of 3rd-party markdown extensions:

  * markdown-checklist
  * MarkdownSubscript
  * MarkdownSuperscript
  * python_markdown_math

### Deployment

I build the site on my local machine so as to eliminate dependencies from the server.
I'm using rsync to optimize time-to-xfer.

```sh
rsync -vrcL /this/repo/build/* servername:/path/to/www/root
ssh servername
cd /path/to/www/root
chown -R $USER:www-data .
find . -type d -exec chmod 750 {} \;
find . -type f -exec chmod 640 {} \;
```


## Name Candidates

- A Poorer Molecular Biologist
- \*\*/\*.md
- Words, words, words…
- Output Spy
- {Surreal|}

## Markdown Dialect

I'm using [Python-Markdown](https://github.com/Python-Markdown/markdown) for converting markdown to html.
It supports extensions, several of which I'd quite like, but I'm going to try to be conservative, and document everything I'm using just in case.

Basics
:   First, I've turned on [Extra], which consists, it seems, of syntax supported by [PHP Markdown Extra].
    For me, the most important features this includes are [footnotes], [fenced code blocks], and [definition lists].
    I've also turned on [Sane Lists], just to protect myself from myself.
    I'm not sure how useful it will really be.

Typography
:   I've turned on [Smarty Pants] to get me access to smart quotes, nice dashes and elipses with ASCII syntax.
    I'm using [Admonition] to add set off sidebars such as notes, warnings, &c.
    I've added [Superscript] and [Subscript], for obvious reasons.

Code
:   Nice code formatting with syntax highlighting is done with [CodeHilite], which depends on [Pygments].
    A third-party extension [checklist] implements github-style checklists.

Metadata
:   I've turned on [Meta-Data] so that I can more easily publish articles.
    Instead of having to enter all this data into a separate `articles.yaml`, I include publish date and tags in the article itself.
    I'm also using `slug` and `updated` metadata.

[Extra]: https://python-markdown.github.io/extensions/extra/
[PHP Markdown Extra]: http://michelf.com/projects/php-markdown/extra/
[footnotes]: https://python-markdown.github.io/extensions/footnotes/
[fenced code blocks]: https://python-markdown.github.io/extensions/fenced_code_blocks/
[definition lists]: https://python-markdown.github.io/extensions/definition_lists/
[Sane Lists]: https://python-markdown.github.io/extensions/sane_lists/
[Smarty Pants]: https://python-markdown.github.io/extensions/smarty/
[Admonition]: https://python-markdown.github.io/extensions/admonition/
[Superscript]: https://github.com/jambonrose/markdown_superscript_extension
[Subscript]: https://github.com/jambonrose/markdown_subscript_extension
[CodeHilite]: https://python-markdown.github.io/extensions/code_hilite/
[Pygments]: http://pygments.org/
[checklist]: https://github.com/FND/markdown-checklist
[Meta-Data]: https://python-markdown.github.io/extensions/meta_data/


I haven't gone through the entire [3rd-party extensions wiki](https://github.com/Python-Markdown/markdown/wiki/Third-Party-Extensions).
Nevertheless, there seem to be some neat things in there.
Here's a list of things I'd like to do:

- [x] For checklists, don't have bullet points --- the checkbox is sufficient.
- [x] Definition lists always have the worst styling by default.
- [x] Using computer modern and SourceCode Pro fonts.
- [x] Basic page styling (e.g. maybe don't let the page get all that wide).
- [x] Everything around the content (primarily a nav element)
- [x] I would have loved to use [InlineHilite], but it threw `.codehilite` on everything, even when I supposedly config'd it not to.
- [x] Add'l text styling (sub/superscript, strikethrough, maybe small caps).
- [x] You know, adding metadata in the document would allow me to publish more easily.
- [ ] Embedding audio/video might be nice.
- [ ] It'd also be good to let me type in math; actually a tikz plugin wouldn't be unwelcome, or flowcharts, for that matter.
- [ ] It's a bit niche, but [interlinear glosses](https://github.com/parryc/doctor_leipzig).
- [ ] Citations are an obvious follow-on from footnotes.
- [ ] It'd be good, though I don't know what might support it, but I'd like to link to headers (also from external sites, so the #tag must be predictable). I'd especially like if headers can be optionally auto-numbered.
- [ ] [Here's](https://github.com/aleray/mdx_outline) some nice semantics-ness that I don't think alters the syntax.
- [ ] A way to include files would be nice, but that's complicated by integration with zedo.
- [ ] Finally, accessibility would be nice.

[InlineHilite]: https://facelessuser.github.io/pymdown-extensions/extensions/inlinehilite/

### Admonition

On its own, admonition doesn't add much to the styling of admonitions.
Instead, you must include your own css file.
I've put this in `src/admonition.css`.
It defines some nice indentation for all admonitions.
Additionally, it defines background colors for `tip`, `note`, `caution`, and `warning`.

### CodeHilite

For now, I'm just using pygment's default coloring, which I don't think I'm that keen on.
It can be changed in `do/code.css.do`.

```haskell
fibs :: [Integer]
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)asfhjkdhjafdskljfhasdklfhlasdkhflajksdhflukaehuiawhewkfuhwe;ofhsedkafl;ehuiwahfdskfhuihsed
```

## Web Standards

This site uses no javascript, but it does use css.
It makes no attempt to work on older browsers.

!!! note
    Something [googley](https://google.com)-woogley. asdfhf a;ufh;d fasuofasdfauwnef ufda;gj sdadf duia;sd asdjf sd ad afdsfn; fa;sjf a df adf  dl;fasd da;dsfha sd 

    Abracadabra

It does render well without css, or even in the terminal.

Another paragraph.

And another paragraph.
