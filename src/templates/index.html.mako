<%inherit file="/base.html.mako"/>
<%namespace name="archive" file="archive.html.mako"/>

${content|n}

<div style="padding-top: 1em; padding-left:2em;">
    <img src="/assets/logos/feed-icon-28x28.png" height="18" width="18"/>
    <a href="/rss.html">RSS</a>
    <a href="/atom.xml">Atom</a>
</div>

<h3>Latest Article: ${latest.title}</h3>

<div class="include-article">
    <div class="content">
        ${latest.html|n}
    </div>
    <div class="read-more"><a href="${latest.url}">read more…</a></div>
</div>

% if pinned:
<h3>Pinned Articles</h3>
<ul>
    % for article in pinned:
    ${archive.mkhref(article)}
    % endfor
</ul>
% endif