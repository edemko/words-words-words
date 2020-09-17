title: Tabs for Indentation, Spaces for Alignment?
published: 2020-09-14
tag: programming
tag: rant


The idea I've heard a lot is to use tabs for indentation (i.e. leading whitespace) but spaces for alignment (i.e. intra-line whitespace).
Obviously, don't use trailing whitespace.
This way, the reader can configure their editor to size indentation to their preference.
After all, if you can't configure your own editor, you aren't good enough at programming workflow to have your opinion taken seriously.

## Some Issues

Wherever tabs are present, line width is not predictable[^1], and is therefore not a sound metric.
Fixing a line-length limit would also require fixing a tab depth, erasing any configurability edge tabs might have.
Each of the multitude of tools which produce pretty-printed output would have to have their tab-width configured, assuming they all have that option.

[^1]: Tab is the only non-printing ASCII character that can occur within a line.
The width of such characters is dependent on the display software, even if that software is written correctly according to the standards.
Admittedly, also considering Unicode introduces many algorithmic complexities, and even some ambiguous-width printing characters, but who actually wants to go down _that_ rabbit-hole[^2]?
In any case, let's get ASCII code correct _at least_.

[^2]: _I_ want to. Send help.


Sometimes alignment happens at the start of a line.
Sure, you could allow leading whitespace to match `\t* *`, but in heat of coding, will you remember to mix your whitespace correctly?
If you just hit tab until it looks right, you might end up in this situation[^3]:

[^3]: Yes, I know I'm a monster that puts commas at the start of the line; I guess I'm less interested in grammar nazism than in instituting systems that decrease the likelihood of (usually my own) programmer error.

```js
function foo() {
  return {
      x: 1
    , y: 2
  }
}
```

```js
function foo() {
    return {
            x: 1
        , y: 2
    }
}
```


When you want to show the consequences of various whitespace techniques, you'll first have to convert tabs to spaces[^4].
This isn't a particularly cutting criticism: when does it ever come up?
Well, in typesetting the last example, but it wouldn't be a problem if we stopped the religious war.
Nevertheless, it does strike me as a symptom of a foundational issue that tabs for indentation is not able to reliably comment on itself.
Or it could just be my fondness all things meta.

[^4]: Or screenshots, but who wants to mess around with pictures when you have a keyboard `;P`


## My Recipe

Stop being picky about layout.
Well, be consistent within a project, but be adaptable to different codebases.
Sure, if you want, you can stop yourself from contributing to a project because it "looks ugly" to you.
On the other hand, if that ugliness is purely due to whitespace, then you probably have your own issues to worry about.
So suck it up, put on your adult clothes, and work with other people, or else shut it.
Adapting to our environment is kinda what us humans are known for; I don't know how humans lost their way.

Personally, I have my editor set up to show spaces and tabs differently so that I can quickly see what others have done with their code and adapt to it (or fix it).
For my own projects, I use space, but I don't particularly care how many I use.
I've used four in the past because it was the default on several editors, but I'm coming to enjoy two spaces now that I've been using it at work.
The important thing to remember is this: if you try a few indentation styles, you'll discover _it doesn't matter_.
