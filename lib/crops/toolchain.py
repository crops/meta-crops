from json import JSONEncoder, JSONDecoder
import crops


class Toolchain(JSONEncoder):

    """
     Describes a Toolchain in an SDK.
    """
    def __init__(self, uid, name,
                 vendor, version, distro,
                 cross_compile, sdk_install_dir,
                 host, target, tools):
        """

        :type target: Target
        """
        self.uid = uid
        self.name = name
        self.vendor = vendor
        self.version = version
        self.distro = distro
        self.cross_compile = cross_compile
        self.sdk_install_dir = sdk_install_dir
        if isinstance(host, crops.host.Host):
            self.host = host
        else:
            self.host = crops.host.Host()
        if isinstance(target, crops.target.Target):
            self.target = target
        else:
            self.target = crops.target.Target()
        self.tools = []
        if isinstance(tools, list):
            for tool in tools:
                if isinstance(tool, crops.tool.Tool):
                    self.tools.append(tool)
        else:
            self.tools = [crops.tool.Tool()]
        JSONEncoder.__init__(self, Toolchain)


    def default(self, obj):
        """
         Converts a Toolchain python object into objects
         that can be decoded using the ToolchainJSONDecoder
        """
        if isinstance(obj, Toolchain):
            return {
                '__type__': 'Toolchain',
                'uid': obj.uid,
                'name': obj.name,
                'vendor': obj.vendor,
                'version': obj.version,
                'distro': obj.distro,
                'cross_compile': obj.cross_compile,
                'sdk_install_dir': obj.sdk_install_dir,
                'host': obj.host.default(obj.host),
                'target': obj.target.default(obj.target),
                'tools': [tool.default(tool) for tool in obj.tools]
            }
        raise TypeError( repr(obj) + " is not an instance of Toolchain")


class ToolchainJSONDecoder(JSONDecoder):
    """
    Converts a json string, where a Toolchain python object was
    converted into objects compatible with ToolchainJSONEncoder, back
    into a python object.
    """

    def __init__(self, *args, **kwargs):
        JSONDecoder.__init__(self, object_hook=self.dict_to_object, *args, **kwargs)

    @staticmethod
    def dict_to_object(d):
        """
        :type d: object
        """
        if '__type__' not in d:
            return d

        thistype = d.pop('__type__')
        if thistype == 'Toolchain':
            return Toolchain(**d)
        else:
            # Unhandled, so put it back together
            # TODO: throw NotSupportedException ?
            d['__type__'] = thistype
            return d
