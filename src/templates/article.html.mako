<%inherit file="/base.html.mako"/>
<div class="meta">
    <h1>${article.title}</h1>
    <ul class="meta">
        <li><label>published</label>: ${article.published}</li>
        <li><label>tags</label>: ${article.tags}</li>
    </ul>
</div>
${article.content |n}
