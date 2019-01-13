from os import path
from mako.lookup import TemplateLookup

TEMPL_DIR = "src/templates"
CACHE_DIR = path.join(TEMPL_DIR, ".cache")
TLOOKUP = TemplateLookup(directories=[TEMPL_DIR], module_directory=CACHE_DIR)


def compile(templateName, **kwargs):
    template = TLOOKUP.get_template(templateName)
    return template.render(**kwargs)
