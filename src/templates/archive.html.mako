<%inherit file="/base.html.mako"/>
<% import re %>
<%def name="mkhref(article)">
    <li>
        <a href="${article.url}">${article.title}</a>
        <ul class="meta">
            <li><label>published</label>: ${article.published}</li>
            <li><label>tags</label>: ${", ".join(article.tags)}</li>
        </ul>
    </li>
</%def>
<h1>Archive</h1>

<div class="jumpto">
    Jump to:
    <ul>
        <li><a href="#by-date">By Date</a></li>
        <li class="section">By Tag</li>
        % for tag in sorted(by_tag.keys()):
        <% tag_id = re.sub(r"\s+", "-", tag) %>\
        <li><a href='#tag-${tag_id}'>${tag}</a></li>\
        % endfor
    </ul>
<div>

<h2>by Tag</h2>

% for tag, articles in sorted(by_tag.items()):
<h3 id="tag-${re.sub(r"\s+", "-", tag)}">${tag}</h3>
<ul>
    % for article in articles:
    ${mkhref(article)}
    % endfor
</ul>
% endfor


<h2 id="by-date">by Date</h2>
<ul>
    % for article in by_date:
    ${mkhref(article)}
    % endfor
</ul>
