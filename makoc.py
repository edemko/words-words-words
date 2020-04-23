import os, sys
from os import path
from mako.lookup import TemplateLookup

# FIXME this should not depend on zedo, right?
TEMPL_DIR = path.join(os.getenv("ZEDO__ROOT"), os.getenv("BUILD"), "templates")
# print(TEMPL_DIR, file=sys.stderr) # DEBUG
CACHE_DIR = path.join(TEMPL_DIR, ".cache")
TLOOKUP = TemplateLookup(
    directories=[TEMPL_DIR],
    module_directory=CACHE_DIR,
    input_encoding='utf-8',
    )


def compile(templateName, **kwargs):
    template = TLOOKUP.get_template(templateName)
    return template.render(**kwargs)
