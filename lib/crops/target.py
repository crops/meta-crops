from json import JSONEncoder, JSONDecoder


class Target(JSONEncoder):
    """
    Describes a Target for which a toolchain was generated.
    """

    def __init__(self, arch, os, sysroot):
        """

        :type arch: str
        :type os: str
        :type sysroot: str
        """
        self.arch = arch
        self.os = os
        self.sysroot = sysroot
        JSONEncoder.__init__(self, Target)

    def default(self, obj):
        """
        Converts a Target python object into objects
        that can be decoded using the TargetJSONDecoder

        :type obj: Target
        """
        if isinstance(obj, Target):
            return {
                '__type__': 'Target',
                'arch': obj.arch,
                'os': obj.os,
                'sysroot': obj.sysroot
            }
        raise TypeError( repr(obj) + " is not an instance of Target")


class TargetJSONDecoder(JSONDecoder):
    """
    Converts a json string, where a Target python object was
    converted into objects compatible with TargetJSONEncoder, back
    into a python object.
    """

    def __init__(self, *args, **kwargs):
        JSONDecoder.__init__(self, object_hook=self.dict_to_object, *args, **kwargs)

    @staticmethod
    def dict_to_object(d):
        if '__type__' not in d:
            return d

        thistype = d.pop('__type__')
        if thistype == 'Target':
            return Target(**d)
        else:
            # Unhandled, so put it back together
            # TODO: throw NotSupportedException ?
            d['__type__'] = thistype
            return d
