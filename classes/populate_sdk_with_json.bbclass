# Toolchain discovery support for CROPS

inherit populate_sdk_base

# for the file in the same location as manifests
CROPS_DEPLOY = "${SDK_DEPLOY}/.crops"
SDK_TOOLCHAIN_JSON = "${CROPS_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}.json"
# for the file included in the sdk itself
CROPS_OUTDIR = "${SDK_OUTPUT}/${SDKPATH}/.crops"
OUTDIR_TOOLCHAIN_JSON = "${CROPS_OUTDIR}/${TOOLCHAIN_OUTPUTNAME}.json"

fakeroot python do_populate_sdk_with_json() {
    bb.build.exec_func("do_populate_sdk", d)
}

# As a design decision, only one toolchain per json file to KISS
python create_toolchain_json() {
    import io, json
    from crops import environment_variable, host, target, tool, toolchain

    # tools
    cc = tool.Tool(tool_args=[d.getVar('TARGET_CC_ARCH', True),
               '--sysroot=%s' % d.getVar('SDKTARGETSYSROOT', True)],
               uid='CC',
               name='gcc',
               command=d.getVar('TARGET_PREFIX', True) + 'gcc')

    cxx = tool.Tool(tool_args=[d.getVar('TARGET_CC_ARCH', True),
               '--sysroot=%s' % d.getVar('SDKTARGETSYSROOT', True)],
               uid='CXX',
               name='g++',
               command=d.getVar('TARGET_PREFIX', True) + 'g++')

    cpp = tool.Tool(tool_args=[d.getVar('TARGET_CC_ARCH', True),
               '--sysroot=${SDKTARGETSYSROOT}'],
               uid='CPP',
               name='gcc',
               command=d.getVar('TARGET_PREFIX', True) + 'gcc -E')

    _as = tool.Tool(tool_args=[d.getVar('TARGET_AS_ARCH', True)],
               uid='AS',
               name='as',
               command=d.getVar('TARGET_PREFIX', True) + 'as')

    ld = tool.Tool(tool_args=[d.getVar('TARGET_LD_ARCH', True),
           '--sysroot=%s' % d.getVar('SDKTARGETSYSROOT', True)],
               uid='LD',
               name='ld',
               command=d.getVar('TARGET_PREFIX', True) + 'ld')

    gdb = tool.Tool(tool_args=[], uid='GDB', name='gdb',
               command=d.getVar('TARGET_PREFIX', True) + 'gdb')

    strip = tool.Tool(tool_args=[], uid='STRIP', name='strip',
               command=d.getVar('TARGET_PREFIX', True) + 'strip')

    ranlib = tool.Tool(tool_args=[], uid='RANLIB', name='ranlib',
               command=d.getVar('TARGET_PREFIX', True) + 'ranlib')

    objcopy = tool.Tool(tool_args=[], uid='OBJCOPY', name='objcopy',
               command=d.getVar('TARGET_PREFIX', True) + 'objcopy')

    objdump = tool.Tool(tool_args=[], uid='OBJDUMP', name='objdump',
               command=d.getVar('TARGET_PREFIX', True) + 'objdump')

    ar = tool.Tool(tool_args=[], uid='AR', name='ar',
               command=d.getVar('TARGET_PREFIX', True) + 'ar')

    nm = tool.Tool(tool_args=[], uid='NM', name='nm' ,
               command=d.getVar('TARGET_PREFIX', True) + 'nm')

    m4 = tool.Tool(tool_args=[], uid='M4', name='m4', command='m4')

    # environment variables
    cflags = environment_variable.EnvironmentVariable(uid='CFLAGS',
               name='cflags',
               value=d.getVar('TARGET_CFLAGS', True))

    cxxflags = environment_variable.EnvironmentVariable(uid='CXXFLAGS',
               name='cxxflags',
               value=d.getVar('TARGET_CXXFLAGS', True))

    ldflags = environment_variable.EnvironmentVariable(uid='LDFLAGS',
               name='ldflags',
               value=d.getVar('TARGET_LDFLAGS', True))

    cppflags = environment_variable.EnvironmentVariable(uid='CPPFLAGS',
               name='cppflags',
               value=d.getVar('TARGET_CPPFLAGS', True))

    kcflags = environment_variable.EnvironmentVariable(uid='KCFLAGS',
              name='kcflags',
              value='--sysroot=%s' % d.getVar('SDKTARGETSYSROOT', True))

    # root objects
    host = host.Host(arch=d.getVar('SDKMACHINE', True),
               os=d.getVar('SDK_OS', True), sysroot='')
    target = target.Target(arch=d.getVar('TARGET_ARCH', True),
               os=d.getVar('TARGET_OS', True),
               sysroot=d.getVar('SDKTARGETSYSROOT', True))
    tools = [cc, cxx, cpp, _as, ld, gdb, strip, ranlib, objcopy, objdump, ar, nm, m4]
    envvars = [cflags, cxxflags, ldflags, cppflags, kcflags]

    # put it all together
    toolchain = toolchain.Toolchain(uid=d.getVar('SDK_NAME', True),
                name=d.getVar('SDK_TITLE', True),
                vendor=d.getVar('SDK_VENDOR', True),
                version=d.getVar('SDK_VERSION', True),
                distro=d.getVar('DISTRO', True),
                distro_version=d.getVar('DISTRO_VERSION', True),
                cross_compile=d.getVar('TARGET_PREFIX', True),
                sdk_install_dir='@SDK_INSTALL_DIR@',
                host=host, target=target, tools=tools, envvars=envvars)

    if d.getVar('TOOLCHAIN_JSON', True) == None:
        # for debug purposes uncomment the bb.warn lines
        # bb.warn(json.dumps(host, default=host.default).decode('utf-8'))
        # bb.warn(json.dumps(target, default=target.default).decode('utf-8'))
        # bb.warn(json.dumps(gcc, default=gcc.default).decode('utf-8'))
        # bb.warn(json.dumps(gxx, default=gxx.default).decode('utf-8'))
        # bb.warn(json.dumps(toolchain, default=toolchain.default).decode('utf-8'))
        d.setVar('TOOLCHAIN_JSON',
               json.dumps(toolchain,
               default=toolchain.default).decode('utf-8'))
        # bb.warn(d.getVar('TOOLCHAIN_JSON', True))


    crops_outdir = os.path.dirname(d.getVar('OUTDIR_TOOLCHAIN_JSON', True))
    if not os.path.exists(crops_outdir):
        bb.utils.mkdirhier(crops_outdir)

    bb.note('Creating SDK JSON at ' + d.getVar('OUTDIR_TOOLCHAIN_JSON', True))

    with io.open(d.getVar('OUTDIR_TOOLCHAIN_JSON', True), 'w') as outfile:
        outfile.write(
            json.dumps(toolchain, default=toolchain.default).decode('UTF-8')
        ) 
}

python write_sdk_toolchain_json () {
    import io, json

    crops_sdk_dir = os.path.dirname(d.getVar('SDK_TOOLCHAIN_JSON', True))
    if not os.path.exists(crops_sdk_dir):
        bb.utils.mkdirhier(crops_sdk_dir)

    with io.open(d.getVar('SDK_TOOLCHAIN_JSON', True), 'w') as outfile:
        outfile.write(
            d.getVar('TOOLCHAIN_JSON', True)
        )
}

fakeroot tar_sdk_json() {
    # Package it up
    mkdir -p ${CROPS_DEPLOY}
    cd ${SDK_OUTPUT}/${SDKPATH}
    ls -la
    tar ${SDKTAROPTS} -cf - .crops/ | pixz > ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}-json.tar.xz
}

fakeroot create_toolchain_json_shar() {
    # for third-party SDKs, create an installer for the toolchain JSON
    cp ${COREBASE}/meta-crops/files/toolchain-json-shar-extract.sh ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}-json.sh

    rm -f ${T}/pre_install_command ${T}/post_install_command

    cat << "EOF" >> ${T}/pre_install_command
${SDK_PRE_INSTALL_COMMAND}
EOF

    cat << "EOF" >> ${T}/post_install_command
${SDK_POST_INSTALL_COMMAND}
EOF

    # substitute variables
    sed -i -e 's#@SDK_ARCH@#${SDK_ARCH}#g' \
           -e 's#@SDKPATH@#${SDKPATH}#g' \
           -e 's#@SDKEXTPATH@#${SDKEXTPATH}#g' \
           -e 's#@OLDEST_KERNEL@#${SDK_OLDEST_KERNEL}#g' \
           -e 's#@REAL_MULTIMACH_TARGET_SYS@#${REAL_MULTIMACH_TARGET_SYS}#g' \
           -e 's#@SDK_TILE@#${SDK_TITLE}#g' \
           -e 's#@SDK_VERSION@#${SDK_VERSION}#g' \
           -e 's#@TOOLCHAIN_OUTPUTNAME@#${TOOLCHAIN_OUTPUTNAME}#g' \
           -e '/@SDK_PRE_INSTALL_COMMAND@/d' \
           -e '/@SDK_POST_INSTALL_COMMAND@/d' \
           ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}-json.sh

    # add execution permission
    chmod +x ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}-json.sh

    # append the SDK JSON tarball
    cat ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}-json.tar.xz >> ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}-json.sh

    # delete the old tarball, we don't need it anymore
    rm ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}-json.tar.xz
}

POPULATE_SDK_POST_TARGET_COMMAND_append = " create_toolchain_json; write_sdk_toolchain_json; "
SDK_POSTPROCESS_COMMAND =+ " tar_sdk_json; create_toolchain_json_shar; "

do_populate_sdk[file-checksums] += "${COREBASE}/meta-crops/files/toolchain-json-shar-extract.sh:True"

do_populate_sdk_with_json[dirs] = "${PKGDATA_DIR} ${TOPDIR}"
do_populate_sdk_with_json[depends] += "${@' '.join([x + ':do_populate_sysroot' for x in d.getVar('SDK_DEPENDS', True).split()])}  ${@d.getVarFlag('do_rootfs', 'depends', False)}"
do_populate_sdk_with_json[rdepends] = "${@' '.join([x + ':do_populate_sysroot' for x in d.getVar('SDK_RDEPENDS', True).split()])}"
do_populate_sdk_with_json[recrdeptask] += "do_packagedata do_package_write_rpm do_package_write_ipk do_package_write_deb"
addtask populate_sdk_with_json after do_populate_sdk
