class Tool(object):

    # static member
    _argsList = None
    _optsDict = None

    @staticmethod
    def setArgsList(oList):
        Tool._argsList = oList
        return

    @staticmethod
    def getArgsList():
        return Tool._argsList

    def __init__(self, **kwargs):
        self._kwargs = kwargs
