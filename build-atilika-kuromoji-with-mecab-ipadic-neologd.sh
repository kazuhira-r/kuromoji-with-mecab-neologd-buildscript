#!/bin/bash

########## Init ##########
SCRIPT_NAME=$0
WORK_DIR=`pwd`

########## Proxy Settings ##########
#export http_proxy=http://your.proxy-host:your.proxy-port
#export https_proxy=http://your.proxy-host:your.proxy-port

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
    -K ... Kuromoji Version Tag, use git checkout argument. (default: ${DEFAULT_KUROMOJI_VERSION_TAG}) 
    -p ... build Kuromoji Java Package. (default: ${DEFAULT_KUROMOJI_PACKAGE})
    -h ... print this help.
EOF
}

########## Default & Fixed Values ##########
## MeCab
MECAB_VERSION=mecab-0.996
MECAB_INSTALL_DIR=${WORK_DIR}/mecab

## MeCab IPA Dictionary
MECAB_IPA_DICTIONARY_VERSION=mecab-ipadic-2.7.0-20070801
DEFAULT_CHARSET=utf-8

## mecab-ipadic-NEologd Target Tag
DEFAULT_MECAB_IPADIC_NEOLOGD_TAG=master
MECAB_IPADIC_NEOLOGD_TAG=${DEFAULT_MECAB_IPADIC_NEOLOGD_TAG}

## install adjective ext
DEFAULT_INSTALL_ADJECTIVE_EXT=0
INSTALL_ADJECTIVE_EXT=${DEFAULT_INSTALL_ADJECTIVE_EXT}

## Kuromoji Target Tag
DEFAULT_KUROMOJI_VERSION_TAG=0.9.0
KUROMOJI_VERSION_TAG=${DEFAULT_KUROMOJI_VERSION_TAG}

## Source Package
DEFAULT_KUROMOJI_PACKAGE=com.atilika.kuromoji.ipadic
REDEFINED_KUROMOJI_PACKAGE=${DEFAULT_KUROMOJI_PACKAGE}

########## Arguments Process ##########
while getopts K:N:T:p:h OPTION
do
    case $OPTION in
        K)
            KUROMOJI_VERSION_TAG=${OPTARG};;
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
[MeCab IPA Dictionary Version]  ... ${MECAB_IPA_DICTIONARY_VERSION}
[Dictionary CharacterSet]       ... ${DEFAULT_CHARSET}
[mecab-ipadic-NEologd Tag (-N)] ... ${MECAB_IPADIC_NEOLOGD_TAG}
[install adjective ext (-T)]    ... ${INSTALL_ADJECTIVE_EXT}
[Kuromoji Version Tag (-K)]     ... ${KUROMOJI_VERSION_TAG}
[Kuromoji Package Name (-p)]    ... ${REDEFINED_KUROMOJI_PACKAGE}

####################################################################

EOF

sleep 3

########## Main Process ##########
if [ ! `which mecab` ]; then
    if [ ! -e ${MECAB_INSTALL_DIR}/bin/mecab ]; then
        logging mecab INFO 'MeCab Install Local.'

        if [ ! -e ${MECAB_VERSION}.tar.gz ]; then
            wget https://mecab.googlecode.com/files/${MECAB_VERSION}.tar.gz
        fi
        tar -zxf ${MECAB_VERSION}.tar.gz
        cd ${MECAB_VERSION}

        if [ ! -e ${MECAB_INSTALL_DIR} ]; then
            mkdir -p ${MECAB_INSTALL_DIR}
        fi

        ./configure --prefix=${MECAB_INSTALL_DIR}
        make
        make install

        PATH=${MECAB_INSTALL_DIR}/bin:${PATH}

        cd ${WORK_DIR}

        logging mecab INFO 'MeCab IPA Dictionary Install Local.'
        if [ ! -e ${MECAB_IPA_DICTIONARY_VERSION}.tar.gz ]; then
            wget https://mecab.googlecode.com/files/${MECAB_IPA_DICTIONARY_VERSION}.tar.gz
        fi
        tar -zxf ${MECAB_IPA_DICTIONARY_VERSION}.tar.gz
        cd ${MECAB_IPA_DICTIONARY_VERSION}
        ./configure --with-charset=${DEFAULT_CHARSET}
        make
        make install
    else
        PATH=${MECAB_INSTALL_DIR}/bin:${PATH}
    fi
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

libexec/make-mecab-ipadic-neologd.sh -T ${INSTALL_ADJECTIVE_EXT}

DIR=`pwd`

NEOLOGD_BUILD_DIR=`find ${DIR}/build/mecab-ipadic-* -maxdepth 1 -type d`
NEOLOGD_DIRNAME=`basename ${NEOLOGD_BUILD_DIR}`
NEOLOGD_VERSION_DATE=`echo ${NEOLOGD_DIRNAME} | perl -wp -e 's!.+-(\d+)!$1!'`

cd ${WORK_DIR}

logging kuromoji INFO 'Kuromoji Repository Clone.'
if [ ! -e kuromoji ]; then
    git clone https://github.com/atilika/kuromoji.git
else
    cd kuromoji
    git checkout *
    git checkout master
    git fetch origin
    git reset --hard origin/master
    git status -s | grep '^?' | perl -wn -e 's!^\?+ ([^ ]+)!git clean -df $1!; system("$_")'
    mvn clean
    git pull
    cd ..
fi

cd kuromoji
KUROMOJI_SRC_DIR=`pwd`

git checkout ${KUROMOJI_VERSION_TAG}

if [ $? -ne 0 ]; then
    logging kuromoji ERROR "git checkout[${KUROMOJI_VERSION_TAG}] failed. Please re-run after execute 'rm -f kuromoji'"
    exit 1
fi

export MAVEN_OPTS='-Xmx7g'

logging kuromoji INFO 'Build Kuromoji, with mecab-ipadic-NEologd.'
test ! -e kuromoji-ipadic/dictionary && mkdir kuromoji-ipadic/dictionary
cp -Rp ${NEOLOGD_BUILD_DIR} kuromoji-ipadic/dictionary

if [ "${REDEFINED_KUROMOJI_PACKAGE}" != "${DEFAULT_KUROMOJI_PACKAGE}" ]; then
    logging lucene INFO "redefine package [${DEFAULT_KUROMOJI_PACKAGE}] => [${REDEFINED_KUROMOJI_PACKAGE}]."

    ORIGINAL_SRC_DIR=`echo ${DEFAULT_KUROMOJI_PACKAGE} | perl -wp -e 's!\.!/!g'`
    NEW_SRC_DIR=`echo ${REDEFINED_KUROMOJI_PACKAGE} | perl -wp -e 's!\.!/!g'`

    test -d ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/main/java/${NEW_SRC_DIR} && rm -rf ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/main/java/${NEW_SRC_DIR}
    mkdir -p ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/main/java/${NEW_SRC_DIR}
    find ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/main/java/${ORIGINAL_SRC_DIR} -mindepth 1 -maxdepth 1 | xargs -I{} mv {} ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/main/java/${NEW_SRC_DIR}
    find ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/main/java/${NEW_SRC_DIR} -type f | xargs perl -wp -i -e "s!${DEFAULT_KUROMOJI_PACKAGE}!${REDEFINED_KUROMOJI_PACKAGE}!g"

    test -d ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/test/java/${NEW_SRC_DIR} && rm -rf ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/test/java/${NEW_SRC_DIR}
    mkdir -p ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/test/java/${NEW_SRC_DIR}
    find ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/test/java/${ORIGINAL_SRC_DIR} -mindepth 1 -maxdepth 1 | xargs -I{} mv {} ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/test/java/${NEW_SRC_DIR}
    find ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/src/test/java/${NEW_SRC_DIR} -type f | xargs perl -wp -i -e "s!${DEFAULT_KUROMOJI_PACKAGE}!${REDEFINED_KUROMOJI_PACKAGE}!g"

    perl -wp -i -e "s!${ORIGINAL_SRC_DIR}!${NEW_SRC_DIR}!g" kuromoji-ipadic/pom.xml
    perl -wp -i -e "s!${DEFAULT_KUROMOJI_PACKAGE}!${REDEFINED_KUROMOJI_PACKAGE}!g" kuromoji-ipadic/pom.xml
fi

mvn -pl kuromoji-ipadic -am package \
    -DskipTests=true \
    -DskipDownloadDictionary=true \
    -Dkuromoji.dict.dir=kuromoji-ipadic/dictionary/mecab-ipadic-2.7.0-20070801-neologd-${NEOLOGD_VERSION_DATE} \
    -Dkuromoji.dict.encoding=utf-8
if [ $? -ne 0 ]; then
    logging kuromoji ERROR 'Kuromoji Build Fail.'
    exit 1
fi

cd ${WORK_DIR}

KUROMOJI_JAR_VERSION=`echo ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/target/kuromoji-ipadic-*.jar | perl -wp -e 's!.+/kuromoji-ipadic-([.\d]+)(.*).jar!$1!'`
KUROMOJI_JAR_SUFFIX=`echo ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/target/kuromoji-ipadic-*.jar | perl -wp -e 's!.+/kuromoji-ipadic-([.\d]+)(.*).jar!$2!'`
cp ${KUROMOJI_SRC_DIR}/kuromoji-ipadic/target/kuromoji-ipadic-${KUROMOJI_JAR_VERSION}${KUROMOJI_JAR_SUFFIX}.jar kuromoji-ipadic-neologd-${KUROMOJI_JAR_VERSION}-${NEOLOGD_VERSION_DATE}${KUROMOJI_JAR_SUFFIX}.jar

ls -l kuromoji-ipadic*

logging main INFO 'END.'

