#!/bin/bash

########## Init ##########
SCRIPT_NAME=$0
WORK_DIR=`pwd`

########## Proxy Settings ##########
#export http_proxy=http://your.proxy-host:your.proxy-port
#export https_proxy=http://your.proxy-host:your.proxy-port
#export ANT_OPTS='-DproxyHost=your.proxy-host -DproxyPort=your.proxy-port'

########## Define Functions ##########
logging() {
    LABEL=$1
    LEVEL=$2
    MESSAGE=$3

    TIME=`date +"%Y-%m-%d %H:%M:%S"`

    echo "### [$TIME] [$LABEL] [$LEVEL] $MESSAGE"
}

usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [options...]
  options:
    -N ... mecab-ipadic-NEologd Tag, use git checkout argument. (default: ${DEFAULT_MECAB_IPADIC_NEOLOGD_TAG})
    -T ... install adjective ext. if you want enable, specified 1. (default: ${DEFAULT_INSTALL_ADJECTIVE_EXT})
    -L ... Lucene Version Tag, use git checkout argument. (default: ${DEFAULT_LUCENE_VERSION_TAG}) 
    -p ... build Kuromoji Java Package. (default: ${DEFAULT_KUROMOJI_PACKAGE})
    -h ... print this help.
EOF
}

########## Default & Fixed Values ##########
## MeCab
MECAB_VERSION=mecab-0.996
MECAB_INSTALL_DIR=${WORK_DIR}/mecab

## mecab-ipadic-NEologd
MAX_BASEFORM_LENGTH=15

## mecab-ipadic-NEologd Target Tag
DEFAULT_MECAB_IPADIC_NEOLOGD_TAG=master
MECAB_IPADIC_NEOLOGD_TAG=${DEFAULT_MECAB_IPADIC_NEOLOGD_TAG}

## install adjective ext
DEFAULT_INSTALL_ADJECTIVE_EXT=0
INSTALL_ADJECTIVE_EXT=${DEFAULT_INSTALL_ADJECTIVE_EXT}

## Lucene Target Tag
DEFAULT_LUCENE_VERSION_TAG=releases/lucene-solr/6.1.0
LUCENE_VERSION_TAG=${DEFAULT_LUCENE_VERSION_TAG}

## Source Package
DEFAULT_KUROMOJI_PACKAGE=org.apache.lucene.analysis.ja
REDEFINED_KUROMOJI_PACKAGE=${DEFAULT_KUROMOJI_PACKAGE}

########## Arguments Process ##########
while getopts L:N:T:p:h OPTION
do
    case $OPTION in
        L)
            LUCENE_VERSION_TAG=${OPTARG};;
        N)
            MECAB_IPADIC_NEOLOGD_TAG=${OPTARG};;
        T)
            INSTALL_ADJECTIVE_EXT=${OPTARG};;
        p)
            REDEFINED_KUROMOJI_PACKAGE=${OPTARG};;
        h)
            usage
            exit 0;;
        \?)
            usage
            exit 1;;
    esac
done

shift `expr "${OPTIND}" - 1`

logging main INFO 'START.'

cat <<EOF

####################################################################
applied build options.

[MeCab Version]                 ... ${MECAB_VERSION}
[mecab-ipadic-NEologd Tag (-N)] ... ${MECAB_IPADIC_NEOLOGD_TAG}
[install adjective ext (-T)]    ... ${INSTALL_ADJECTIVE_EXT}
[Max BaseForm Length]           ... ${MAX_BASEFORM_LENGTH}
[Lucene Version Tag (-L)]       ... ${LUCENE_VERSION_TAG}
[Kuromoji Package Name (-p)]    ... ${REDEFINED_KUROMOJI_PACKAGE}

####################################################################

EOF

sleep 3

########## Main Process ##########
if [ ! `which mecab` ]; then
    if [ ! -e ${MECAB_INSTALL_DIR}/bin/mecab ]; then
        logging mecab INFO 'MeCab Install Local.'

        if [ ! -e ${MECAB_VERSION}.tar.gz ]; then
            curl https://mecab.googlecode.com/files/${MECAB_VERSION}.tar.gz -o ${MECAB_VERSION}.tar.gz
        fi
        tar -zxf ${MECAB_VERSION}.tar.gz
        cd ${MECAB_VERSION}

        if [ ! -e ${MECAB_INSTALL_DIR} ]; then
            mkdir -p ${MECAB_INSTALL_DIR}
        fi

        ./configure --prefix=${MECAB_INSTALL_DIR}
        make
        make install
    fi

    PATH=${MECAB_INSTALL_DIR}/bin:${PATH}
fi

cd ${WORK_DIR}

logging mecab-ipadic-NEologd INFO 'Download mecab-ipadic-NEologd.'
if [ ! -e mecab-ipadic-neologd ]; then
    git clone https://github.com/neologd/mecab-ipadic-neologd.git
else
    cd mecab-ipadic-neologd

    if [ -d build ]; then
        rm -rf build
    fi

    git checkout master
    git fetch origin
    git reset --hard origin/master
    git pull
    cd ..
fi

cd mecab-ipadic-neologd

git checkout ${MECAB_IPADIC_NEOLOGD_TAG}

if [ $? -ne 0 ]; then
    logging mecab-ipadic-NEologd ERROR "git checkout[${MECAB_IPADIC_NEOLOGD_TAG}] failed. Please re-run after execute 'rm -f mecab-ipadic-neologd'"
    exit 1
fi

libexec/make-mecab-ipadic-neologd.sh -L ${MAX_BASEFORM_LENGTH} -T ${INSTALL_ADJECTIVE_EXT}

DIR=`pwd`

NEOLOGD_BUILD_DIR=`find ${DIR}/build/mecab-ipadic-* -maxdepth 1 -type d`
NEOLOGD_DIRNAME=`basename ${NEOLOGD_BUILD_DIR}`
NEOLOGD_VERSION_DATE=`echo ${NEOLOGD_DIRNAME} | perl -wp -e 's!.+-(\d+)!$1!'`

cd ${WORK_DIR}

logging lucene INFO 'Lucene Repository Clone.'
if [ ! -e lucene-solr ]; then
    git clone https://github.com/apache/lucene-solr.git
else
    cd lucene-solr
    git checkout *
    git checkout master
    git fetch origin
    git reset --hard origin/master
    git status -s | grep '^?' | perl -wn -e 's!^\?+ ([^ ]+)!git clean -df $1!; system("$_")'
    ant clean
    git pull
    cd ..
fi

cd lucene-solr
LUCENE_SRC_DIR=`pwd`

git checkout ${LUCENE_VERSION_TAG}

if [ $? -ne 0 ]; then
    logging lucene ERROR "git checkout[${LUCENE_VERSION_TAG}] failed. Please re-run after execute 'rm -f lucene-solr'"
    exit 1
fi

cd lucene
ant ivy-bootstrap

cd analysis/kuromoji
KUROMOJI_SRC_DIR=`pwd`

git checkout build.xml

logging lucene INFO 'Build Lucene Kuromoji, with mecab-ipadic-NEologd.'
mkdir -p ${LUCENE_SRC_DIR}/lucene/build/analysis/kuromoji
cp -Rp ${NEOLOGD_BUILD_DIR} ${LUCENE_SRC_DIR}/lucene/build/analysis/kuromoji

if [ "${LUCENE_VERSION_TAG}" = "lucene_solr_5_0_0" ]; then
    loging lucene INFO 'avoid https://issues.apache.org/jira/browse/LUCENE-6368'
    perl -wp -i -e 's!^    try \(OutputStream os = Files.newOutputStream\(path\)\) {!    try (OutputStream os = new BufferedOutputStream(Files.newOutputStream(path))) {!' ${LUCENE_SRC_DIR}/lucene/core/src/java/org/apache/lucene/util/fst/FST.java
    perl -wp -i -e 's!^      save\(new OutputStreamDataOutput\(new BufferedOutputStream\(os\)\)\);!      save(new OutputStreamDataOutput(os));!' ${LUCENE_SRC_DIR}/lucene/core/src/java/org/apache/lucene/util/fst/FST.java
fi

if [ -e ${LUCENE_SRC_DIR}/lucene/version.properties ]; then
    perl -wp -i -e "s!^version.suffix=(.+)!version.suffix=${NEOLOGD_VERSION_DATE}-SNAPSHOT!" ${LUCENE_SRC_DIR}/lucene/version.properties
fi
perl -wp -i -e "s!\"dev.version.suffix\" value=\"SNAPSHOT\"!\"dev.version.suffix\" value=\"${NEOLOGD_VERSION_DATE}-SNAPSHOT\"!" ${LUCENE_SRC_DIR}/lucene/common-build.xml
perl -wp -i -e 's!<project name="analyzers-kuromoji"!<project name="analyzers-kuromoji-ipadic-neologd"!' build.xml
perl -wp -i -e 's!maxmemory="[^"]+"!maxmemory="5g"!' build.xml

if [ "${REDEFINED_KUROMOJI_PACKAGE}" != "${DEFAULT_KUROMOJI_PACKAGE}" ]; then
    logging lucene INFO "redefine package [${DEFAULT_KUROMOJI_PACKAGE}] => [${REDEFINED_KUROMOJI_PACKAGE}]."

    ORIGINAL_SRC_DIR=`echo ${DEFAULT_KUROMOJI_PACKAGE} | perl -wp -e 's!\.!/!g'`
    NEW_SRC_DIR=`echo ${REDEFINED_KUROMOJI_PACKAGE} | perl -wp -e 's!\.!/!g'`

    test -d ${KUROMOJI_SRC_DIR}/src/java/${NEW_SRC_DIR} && rm -rf ${KUROMOJI_SRC_DIR}/src/java/${NEW_SRC_DIR}
    mkdir -p ${KUROMOJI_SRC_DIR}/src/java/${NEW_SRC_DIR}
    find ${KUROMOJI_SRC_DIR}/src/java/${ORIGINAL_SRC_DIR} -mindepth 1 -maxdepth 1 | xargs -I{} mv {} ${KUROMOJI_SRC_DIR}/src/java/${NEW_SRC_DIR}
    find ${KUROMOJI_SRC_DIR}/src/java/${NEW_SRC_DIR} -type f | xargs perl -wp -i -e "s!${DEFAULT_KUROMOJI_PACKAGE}!${REDEFINED_KUROMOJI_PACKAGE}!g"

    test -d ${KUROMOJI_SRC_DIR}/src/resources/${NEW_SRC_DIR} && rm -rf ${KUROMOJI_SRC_DIR}/src/resources/${NEW_SRC_DIR}
    mkdir -p ${KUROMOJI_SRC_DIR}/src/resources/${NEW_SRC_DIR}
    find ${KUROMOJI_SRC_DIR}/src/resources/${ORIGINAL_SRC_DIR} -mindepth 1 -maxdepth 1 | xargs -I{} mv {} ${KUROMOJI_SRC_DIR}/src/resources/${NEW_SRC_DIR}

    test -d ${KUROMOJI_SRC_DIR}/src/tools/java/${NEW_SRC_DIR} && rm -rf ${KUROMOJI_SRC_DIR}/src/tools/java/${NEW_SRC_DIR}
    mkdir -p ${KUROMOJI_SRC_DIR}/src/tools/java/${NEW_SRC_DIR}
    find ${KUROMOJI_SRC_DIR}/src/tools/java/${ORIGINAL_SRC_DIR} -mindepth 1 -maxdepth 1 | xargs -I{} mv {} ${KUROMOJI_SRC_DIR}/src/tools/java/${NEW_SRC_DIR}
    find ${KUROMOJI_SRC_DIR}/src/tools/java/${NEW_SRC_DIR} -type f | xargs perl -wp -i -e "s!${DEFAULT_KUROMOJI_PACKAGE}!${REDEFINED_KUROMOJI_PACKAGE}!g"

    perl -wp -i -e "s!${ORIGINAL_SRC_DIR}!${NEW_SRC_DIR}!g" build.xml
    perl -wp -i -e "s!${DEFAULT_KUROMOJI_PACKAGE}!${REDEFINED_KUROMOJI_PACKAGE}!g" build.xml
fi

ant -Dipadic.version=${NEOLOGD_DIRNAME} -Ddict.encoding=utf-8 regenerate
if [ $? -ne 0 ]; then
    logging lucene ERROR 'Dictionary Build Fail.'
    exit 1
fi

ant jar-core
if [ $? -ne 0 ]; then
    logging lucene ERROR 'Kuromoji Build Fail.'
    exit 1
fi

cd ${WORK_DIR}

cp ${LUCENE_SRC_DIR}/lucene/build/analysis/kuromoji/lucene-analyzers-kuromoji* ./.

ls -l lucene-analyzers-kuromoji*

logging main INFO 'END.'
