import subprocess as sh

def always(*targetNames):
    sh.run(("zedo", "always") + targetNames, check=True)

def ifchange(*targetNames, find=False):
    cmd = ("zedo", "ifchange")
    if find: cmd = cmd + ("--find",)
    cmd = sh.run(cmd + targetNames, check=True, stdout=sh.PIPE)
    lines = cmd.stdout.decode("utf-8").splitlines()
    if len(lines) == 0:
        return None
    elif len(lines) == 1:
        return lines[0]
    else:
        return tuple(lines)

def find(targetName):
    cmd = sh.run(["zedo", "find", targetName], check=True, stdout=sh.PIPE)
    return cmd.stdout.decode("utf-8").strip(" \t\n\r")

def phony():
    sh.run(("zedo", "phony"), check=True)