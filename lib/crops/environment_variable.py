from json import JSONEncoder, JSONDecoder


class EnvironmentVariable(JSONEncoder):
    """
    Describes an environment variable in a toolchain, e.g. CFLAGS or LDFLAGS.
    """

    def __init__(self, uid, name, value, *args, **kwargs):
        self.uid = uid
        self.name = name
        self.value = value
        self.args = args
        self.kwargs = kwargs
        JSONEncoder.__init__(self, EnvironmentVariable)

    def default(self, obj):
        """
        Converts an EnvironmentVariable python object into objects
        that can be decoded using the EnvironmentVariableJSONDecoder
        """
        if isinstance(obj, EnvironmentVariable):
            return {
                '__type__': 'EnvironmentVariable',
                'uid': obj.uid,
                'name': obj.name,
                'value': obj.value,
            }
        raise TypeError( repr(obj) + " is not an instance of EnvironmentVariable")


class EnvironmentVariableJSONDecoder(JSONDecoder):
    """
    Converts a json string, where an EnvironmentVariable python object was
    converted into objects compatible with EnvironmentVariableJSONEncoder, back
    into a python object.
    """

    def __init__(self, *args, **kwargs):
        JSONDecoder.__init__(self, object_hook=self.dict_to_object, *args, **kwargs)

    @staticmethod
    def dict_to_object(self, d):
        if '__type__' not in d:
            return d

        thistype = d.pop('__type__')
        if thistype == 'EnvironmentVariable':
            return EnvironmentVariable(**d)
        else:
            # Unhandled, so put it back together
            # TODO: throw NotSupportedException ?
            d['__type__'] = thistype
            return d
