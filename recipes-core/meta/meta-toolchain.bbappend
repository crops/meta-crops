# Possibly needed if built-in json is not full-featured enough
# RDEPENDS += " python-jsonpath-rw"
# or
# RDEPENDS += ' python-jsonpickle"

# As a design decision, only one toolchain per json file to KISS
python create_toolchain_json() {
    import io, json
    from crops import Host, Target, Tool, Toolchain

    # what a Tool object instantiation might look like
    gcc = Tool(uid='CC', name='gcc', command='${TARGET_PREFIX}gcc',
               ['${TARGET_CC_ARCH}', '--sysroot=$SDKTARGETSYSROOT'])
    gxx = Tool(uid='CXX', name='g++', command='${TARGET_PREFIX}g++',
               ['${TARGET_CC_ARCH}', '--sysroot=$SDKTARGETSYSROOT'])
    #gxx_json = u'{"tool": {"id": "CXX", "command": "${TARGET_PREFIX}g++", "args":["${TARGET_CC_ARCH}", "--sysroot=${SDKTARGETSYSROOT}"]}}'

    host = Host(arch='${SDKMACHINE}', os='${SDK_OS}', sysroot='')
    target = Target(arch='${TARGET_ARCH}', os='${TARGET_OS}',
                    sysroot='${SDKTARGETSYSROOT}')
    toolchain = Toolchain(uid='${SDK_NAME}', name='${SDK_TITLE}',
                vendor='${SDK_VENDOR}', version='${SDK_VERSION}',
                distro='${DISTRO}', host, target,
		tools=[gcc,gxx])

    #gxx_dict = json.loads(gxx_json)
    if d.getVar('TOOLCHAIN_JSON', True) == None:
        # for debug purposes uncomment the bb.warn lines
        bb.warn(json.dumps(toolchain).decode('utf-8'))
        d.setVar('TOOLCHAIN_JSON', json.dumps(toolchain).decode('utf-8'))
        # bb.warn(d.getVar('TOOLCHAIN_JSON', True))

    with io.open(u'${SDK_OUTPUT}/${SDKPATH}/toolchain-${REAL_MULTIMACH_TARGET_SYS}.json', 'w') as outfile:
        outfile.write(
            # json.dump(gxx_dict, outfile) is tempting but
            # finicky about unicode in fp.write(chunk) 
            # easier to just decode it and write out as a string
            json.dumps(toolchain).decode('UTF-8')
        )
}

SDK_POSTPROCESS_COMMAND =+ "create_toolchain_json; "
