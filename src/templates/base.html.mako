<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>A Poorer Molecular Biologist</title>
    <link rel="stylesheet" type="text/css" href="/assets/fonts/cmun-serif.css"/>
    <link rel="stylesheet" type="text/css" href="/assets/fonts/source-code-pro.css"/>
    <link rel="stylesheet" type="text/css" href="/assets/fonts/cmun-typewriter-light.css"/>
    <link rel="stylesheet" type="text/css" href="/assets/main.css"/>
    <link rel="stylesheet" type="text/css" href="/assets/admonition.css"/>
    <link rel="stylesheet" type="text/css" href="/assets/code.css"/>
    <!-- Yeah, I know, it's some javascript. Worth it for math. -->
    <!-- <script async src="/assets/script/MathJax.js"></script> -->
    <script type="text/javascript">
        var extraTeXExts = window.location.hostname == "localhost" ? [] : ["noUndefined.js", "noErrors.js"];
        window.MathJax =
          { config: ["MMLorHTML.js"]
          , jax: ["input/TeX", "output/SVG", "output/HTML-CSS"]
          , extensions: [ "MathMenu.js", "MathZoom.js", "a11y/accessibility-menu.js" ]
          , TeX:
            { extensions: [ "AMSmath.js", "AMSsymbols.js" ].concat(extraTeXExts)
            }
          }
    </script>
    <script async src="https://cdn.jsdelivr.net/npm/mathjax@2/MathJax.js"></script>

</head>
<body>
<nav>
    <h1>A Poorer Molecular Biologist</h1>
    <ul>
        <li><a href="/index.html">Home</a></li>
        <li><a href="/archive.html">Archive</a></li>
        <li><a href="/about.html">About</a></li>
    </ul>
</nav>
<hr/>
<div class="content">
${self.body()}
</div>
</body>
</html>
