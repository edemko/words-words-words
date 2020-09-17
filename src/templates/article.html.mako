<%inherit file="/base.html.mako"/>
<div class="meta">
    <h1>${article.title}</h1>
    <ul class="meta">
        <li><label>published</label>: ${article.published}</li>
        % if article.updated:
        <li><label>updated</label>: ${article.updated}</li>
        % endif
        <li><label>tags</label>: ${article.tags}</li>
    </ul>
</div>
${article.content |n}
