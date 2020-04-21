import subprocess as sh
import sys

dirname, name, ext = sys.argv[1:]
rooterr = open("/dev/fd/3", mode="wt", encoding="utf-8")

def always(*targetNames):
    sh.run(("zedo", "always") + targetNames, check=True)

def ifchange(*targetNames):
    cmd = ("zedo", "if-change")
    cmd = sh.run(cmd + targetNames, check=True)

def ifcreate(*targetNames):
    cmd = ("zedo", "if-create")
    cmd = sh.run(cmd + targetNames, check=True)

def phony():
    sh.run(("zedo", "phony"), check=True)
