# Possibly needed if built-in json is not full-featured enough
# RDEPENDS += " python-jsonpath-rw"
# or
# RDEPENDS += ' python-jsonpickle"

# As a design decision, only one toolchain per json file to KISS
python create_toolchain_json() {
    import io, json
    from crops import host, target, tool, toolchain

    cc = tool.Tool(tool_args=['${TARGET_CC_ARCH}', '--sysroot=${SDKTARGETSYSROOT}'],
               uid='CC', name='gcc', command='${TARGET_PREFIX}gcc')
    cxx = tool.Tool(tool_args=['${TARGET_CC_ARCH}', '--sysroot=${SDKTARGETSYSROOT}'],
               uid='CXX', name='g++', command='${TARGET_PREFIX}g++')
    cpp = tool.Tool(tool_args=['${TARGET_CC_ARCH}', '--sysroot=${SDKTARGETSYSROOT}'],
	       uid='CPP', name='gcc', command='${TARGET_PREFIX}gcc -E')
    _as = tool.Tool(tool_args=['${TARGET_AS_ARCH}'],
	       uid='AS', name='as', command='${TARGET_PREFIX}as')
    ld = tool.Tool(tool_args=['${TARGET_LD_ARCH}', '--sysroot=${SDKTARGETSYSROOT}'],
	       uid='LD', name='ld', command='${TARGET_PREFIX}ld')
    gdb = tool.Tool(tool_args=[], uid='GDB', name='gdb', command='${TARGET_PREFIX}gdb')
    strip = tool.Tool(tool_args=[], uid='STRIP', name='strip', command='${TARGET_PREFIX}strip')
    ranlib = tool.Tool(tool_args=[], uid='RANLIB', name='ranlib', command='${TARGET_PREFIX}ranlib')
    objcopy = tool.Tool(tool_args=[], uid='OBJCOPY', name='objcopy', command='${TARGET_PREFIX}objcopy')
    objdump = tool.Tool(tool_args=[], uid='OBJDUMP', name='objdump', command='${TARGET_PREFIX}objdump')
    ar = tool.Tool(tool_args=[], uid='AR', name='ar', command='${TARGET_PREFIX}ar')
    nm = tool.Tool(tool_args=[], uid='NM', name='nm' , command='${TARGET_PREFIX}nm')
    m4 = tool.Tool(tool_args=[], uid='M4', name='m4', command='m4')

    host = host.Host(arch='${SDKMACHINE}', os='${SDK_OS}', sysroot='')
    target = target.Target(arch='${TARGET_ARCH}', os='${TARGET_OS}',
                    sysroot='${SDKTARGETSYSROOT}')
    tools = [cc, cxx, cpp, _as, ld, gdb, strip, ranlib, objcopy, objdump, ar, nm, m4]
    toolchain = toolchain.Toolchain(uid='${SDK_NAME}', name='${SDK_TITLE}',
                vendor='${SDK_VENDOR}', version='${SDK_VERSION}',
                distro='${DISTRO}', cross_compile='${TARGET_PREFIX}', sdk_install_dir='${SDK_INSTALL_DIR}', host=host, target=target, tools=tools)

    if d.getVar('TOOLCHAIN_JSON', True) == None:
        # for debug purposes uncomment the bb.warn lines
	# bb.warn(json.dumps(host, default=host.default).decode('utf-8'))
	# bb.warn(json.dumps(target, default=target.default).decode('utf-8'))
	# bb.warn(json.dumps(gcc, default=gcc.default).decode('utf-8'))
        # bb.warn(json.dumps(gxx, default=gxx.default).decode('utf-8'))
        # bb.warn(json.dumps(toolchain, default=toolchain.default).decode('utf-8'))
        d.setVar('TOOLCHAIN_JSON', json.dumps(toolchain, default=toolchain.default).decode('utf-8'))
        # bb.warn(d.getVar('TOOLCHAIN_JSON', True))

    with io.open(u'${SDK_OUTPUT}/${SDKPATH}/toolchain-${REAL_MULTIMACH_TARGET_SYS}.json', 'w') as outfile:
        outfile.write(
            # json.dump(obj, outfile) is tempting but
            # finicky about unicode in fp.write(chunk) 
            # easier to just decode it and write out as a string
            json.dumps(toolchain, default=toolchain.default).decode('UTF-8')
        )
}

SDK_POSTPROCESS_COMMAND =+ "create_toolchain_json; "
