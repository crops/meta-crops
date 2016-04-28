# Possibly needed if built-in json is not full-featured enough
# RDEPENDS += " python-jsonpath-rw"

python create_toolchain_json() {
    import io, json
    # from crops import tool, toolchain

    # what a Tool object instantiation might look like
    # tool = Tool(id='CC', command='${TARGET_PREFIX}gcc', args=['${TARGET_CC_ARCH}', '--sysroot=$SDKTARGETSYSROOT'])
    gxx_json = u'{"tool": {"id": "CXX", "command": "${TARGET_PREFIX}g++", "args":["${TARGET_CC_ARCH}", "--sysroot=${SDKTARGETSYSROOT}"]}}'

#    toolchain = {u'toolchain': {u'id': u'CC', u'command': '${TARGET_PREFIX}gcc',
#                               u'args': [u'${TARGET_CC_ARCH}', u'--sysroot=$SDKTARGETSYSROOT']}}
    gxx_dict = json.loads(gxx_json)
    if d.getVar('TOOLCHAIN_JSON', True) == None:
        # for debug purposes uncomment the bb.warn lines
        # bb.warn(json.dumps(gxx_dict).decode('utf-8'))
        d.setVar('TOOLCHAIN_JSON', json.dumps(gxx_dict).decode('utf-8'))
        # bb.warn(d.getVar('TOOLCHAIN_JSON', True))

    with io.open(u'${SDK_OUTPUT}/${SDKPATH}/zephyr-sdk-${REAL_MULTIMACH_TARGET_SYS}.json', 'w') as outfile:
        outfile.write(
            # json.dump(gxx_dict, outfile) is tempting but
            # finicky about unicode in fp.write(chunk) 
            # easier to just decode it and write out as a string
            json.dumps(gxx_dict).decode('UTF-8')
        )
}

SDK_POSTPROCESS_COMMAND =+ "create_toolchain_json; "
