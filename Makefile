SRPM_OUT=./out/srpm
RPM_OUT=./out/rpm
SRC=./src
OUT=./out

SPEC_TOOL=/usr/bin/spectool
MOCK=/usr/bin/mock
TAR=/usr/bin/tar
MOCK_ENV=epel-7-x86_64
DIST=el7.centos

SPEC_FILE=./yum-plugin-s3-iam.spec
VERSION:=$(shell grep Version\: ${SPEC_FILE} | awk '{print $$2}')

# Jenkins sets this environment variable for us. If it isn't set, set to 0
ifndef BUILD_NUMBER
BUILD_NUMBER=0
endif

MOCK_DEFINE=--define '__tr_release_num ${BUILD_NUMBER}'

.PHONY: all rpm install dirs clean build-rpm build-srpm fetch-source mock-dep spectool-dep

all:
	@echo "Usage: make build-rpm"

install:
	install -m 0755 -d $(DESTDIR)/etc/yum/pluginconf.d/
	install -m 0644 s3iam.conf $(DESTDIR)/etc/yum/pluginconf.d/
	install -m 0755 -d $(DESTDIR)/usr/lib/yum-plugins/
	install -m 0644 s3iam.py $(DESTDIR)/usr/lib/yum-plugins/
	cp s3iam.repo LICENSE NOTICE README.md ../

dirs:
	mkdir -p ${SRPM_OUT} ${RPM_OUT} ${SRC}

clean:
	rm -rf ${OUT} ${SRC}

build-srpm: src/yum-plugin-s3-iam.tar.gz fetch-source mock-dep
	cp ${SPEC_FILE} ${SRC}
	${MOCK} -v -r ${MOCK_ENV} --buildsrpm --spec ${SPEC_FILE} --sources ${SRC} ${MOCK_DEFINE} --resultdir ${SRPM_OUT}

build-rpm:  build-srpm mock-dep
	${MOCK} -v -r ${MOCK_ENV} --rebuild ${SRPM_OUT}/yum-plugin-s3-iam-${VERSION}-${BUILD_NUMBER}.${DIST}.src.rpm ${MOCK_DEFINE} --resultdir ${RPM_OUT}

fetch-source: spectool-dep
	${SPEC_TOOL} -g -R -C ${SRC} ${SPEC_FILE}

src/yum-plugin-s3-iam.tar.gz: dirs
	tar --exclude=".git" --exclude="yum-plugin-s3-iam.tar.gz" -czvvf src/yum-plugin-s3-iam.tar.gz .

mock-dep:
	test -x ${MOCK} || { echo "You do not have mock installed! Install with 'yum install -y mock'. Exiting..."; false; }

spectool-dep:
	test -x ${SPEC_TOOL} || { echo "You do not have spectool installed! Install with 'yum install -y rpmdevtools'. Exiting..."; false; }
