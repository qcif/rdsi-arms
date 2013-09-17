from com.googlecode.fascinator.common import FascinatorHome
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "display")) 

from Dashboard import Dashboard

class AdminData(Dashboard):
    def __init__(self):
        pass

    def __activate__(self, context):
        self.activate(context)
