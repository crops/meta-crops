# Lifted directly from meta-openstack
# http://git.yoctoproject.org/cgit/cgit.cgi/meta-cloud-services/plain/meta-openstack/recipes-devtools/python/python-jsonpath-rw_1.4.0.bb

DESCRIPTION = "A robust and significantly extended implementation of JSONPath for Python"
HOMEPAGE = "https://github.com/kennknowles/python-jsonpath-rw"
SECTION = "devel/python"
LICENSE = "BSD+"
LIC_FILES_CHKSUM = "file://README.rst;md5=02384665f821c394981e0dd1faec9a7d"

SRCNAME = "jsonpath-rw"

SRC_URI = "http://pypi.python.org/packages/source/j/${SRCNAME}/${SRCNAME}-${PV}.tar.gz"

SRC_URI[md5sum] = "3a807e05c2c12158fc6bb0a402fd5778"
SRC_URI[sha256sum] = "05c471281c45ae113f6103d1268ec7a4831a2e96aa80de45edc89b11fac4fbec"

S = "${WORKDIR}/${SRCNAME}-${PV}"

inherit setuptools

