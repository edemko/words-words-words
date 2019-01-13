import sys, time
from contextlib import contextmanager

@contextmanager
def perf(name=None, disable=False):
    if disable:
        yield
    else:
        t0 = time.time()
        yield
        t = time.time() - t0
        print("{}{}".format(name+": " if name else "", t), file=sys.stderr)
