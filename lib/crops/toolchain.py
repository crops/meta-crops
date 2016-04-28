class Toolchain(object):

    # static member
    _toolsList = None

    @staticmethod
    def setToolList(oList):
        Toolchain._toolsList = oList
        return

    @staticmethod
    def getToolList():
        return Toolchain._toolsList
