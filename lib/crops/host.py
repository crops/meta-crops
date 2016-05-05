from json import JSONEncoder, JSONDecoder


class Host(object, JSONEncoder):
    """
    Describes a host for which a toolchain was generated.
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

    def default(self, obj):
        """
        Converts a Host python object into objects
        that can be decoded using the HostJSONDecoder

        :type obj: Host
        """
        if isinstance(obj, Host):
            return {
                '__type__': 'Host',
                'arch': obj.arch,
                'os': obj.os,
                'sysroot': obj.sysroot
            }
        else:
            return JSONEncoder.default(self, obj)


class HostJSONDecoder(JSONDecoder):
    """
    Converts a json string, where a Host python object was
    converted into objects compatible with HostJSONEncoder, back
    into a python object.
    """

    def __init__(self, *args, **kwargs):
        JSONDecoder.__init__(self, object_hook=self.dict_to_object, *args, **kwargs)

    @staticmethod
    def dict_to_object(self, d):
        if '__type__' not in d:
            return d

        thistype = d.pop('__type__')
        if thistype == 'Host':
            return Host(**d)
        else:
            # Unhandled, so put it back together
            # TODO: throw NotSupportedException ?
            d['__type__'] = thistype
            return d
