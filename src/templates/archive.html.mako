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

<h2>by Date</h2>

<ul>
    % for article in by_date:
    ${mkhref(article)}
    % endfor
</ul>


<h2>by Tag</h2>

## FIXME this is not ideal wrt the semantic web
% for i, tag in enumerate(sorted(by_tag.keys())):
<% tag_id = re.sub(r"\s+", "-", tag) %>\
${", " if i else ""}<a href='#tag-${tag_id}'>${tag}</a>\
% endfor

% for tag, articles in sorted(by_tag.items()):
<h3 id="tag-${re.sub(r"\s+", "-", tag)}">${tag}</h3>
<ul>
    % for article in articles:
    ${mkhref(article)}
    % endfor
</ul>
% endfor
