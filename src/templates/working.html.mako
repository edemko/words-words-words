<%inherit file="/base.html.mako"/>
## FIXME import this from the archive template
<%def name="mkhref(article)">
    <li>
        <a href="${article.url}">${article.title}</a>
        <ul class="meta">
            <li><label>published</label>: ${article.published}</li>
            <li><label>tags</label>: ${", ".join(article.tags)}</li>
        </ul>
    </li>
</%def>

<h1>In-Progress</h1>
<ul>
    % for article in articles:
    ${mkhref(article)}
    % endfor
</ul>
