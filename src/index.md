
### Subscribe

<img src="/assets/logos/feed-icon-28x28.png" height="18" width="18"/> [RSS](/rss.xml)/[Atom](/atom.xml)

### TODO

- [ ] series framework
    - [ ] `all-articles` do-script
    - [ ] file that describes which articles are in which series
        - I would generate from tags, but that would mean tags get interpreted twice
        - alternately, a folder for each series with files `my-series.md, my-series/01.md, my-series/02.md, ...`
- [ ] home page
    - [ ] latest article, with max-height
    - [ ] pinned articles
- [x] better language selection for code blocks
    - [x] sed the triple-tick+lang to whatever format the current extension needs
    - [x] re-audit all my code blocks
- [x] mathematics markdown (see [this mess](/articles/clock-design.html))
    - [ ] the MathJax font looks a bit awful next to real computer modern
    - [ ] I'd love to render math locally and ship only the resulting svg
    - [ ] otherwise, I'd like to supply the MathJax files locally rather than rely on someone else's cdn
- [x] title needs the markdown treatment (esp. for typography) rather than going directly into html
    - [ ] I should figure something out about removing the bad `<p>` tags
    - [x] for now, I've just put `’` in place of `'`
- [x] make a post on the procedures for asymmetric key cryptography
- [ ] create a suite of my own keys and publish them on [About](/about.html)
- [x] python interface to zedo
- [x] make a (hidden) page containing a list of all the articles I'm working on
- [ ] clean up the archive
    - [ ] properly sorted by date, not just by entry into the file
    - [ ] max-height for each by-\*, or at least link to them as headers
- [ ] click on tags anywhere to jump to the archive of that tag
- [x] use mako instead of rolling my own terrible templates out of python format strings
- [ ] audit
    - [ ] is mako being used in the most efficient way?
    - [ ] can I automatically determine mako dependencies?
    - [x] are all targets phony/volatile as needed?
    - [ ] are extra files being marked as such?
    - [ ] feeds are constructed as fully as possible. see [here](https://validator.w3.org/feed/docs/atom.html)
    - [ ] dependencies (esp. on python scripts) are tracked correctly


### Latest Article

### Pinned Articles
