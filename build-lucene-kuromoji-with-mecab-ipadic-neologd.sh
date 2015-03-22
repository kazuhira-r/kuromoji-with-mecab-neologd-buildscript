#!/bin/bash

########## Init  ##########
WORK_DIR=`pwd`

########## Variables ##########
## MeCab
MECAB_VERSION=mecab-0.996
MECAB_INSTALL_DIR=${WORK_DIR}/mecab

## MeCab IPA Dictionary
MECAB_IPA_DICTIONARY_VERSION=mecab-ipadic-2.7.0-20070801
DEFAULT_CHARSET=utf-8

## mecab-ipadic-NEologd
MAX_BASEFORM_LENGTH=15

## Lucene Target Tag
LUCENE_VERSION_TAG=lucene_solr_5_0_0

########## Main Process ##########
if [ ! `which mecab` ]; then
    echo '##### MeCab Install Local #####'

    wget https://mecab.googlecode.com/files/${MECAB_VERSION}.tar.gz
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

    echo '##### MeCab IPA Dictionary Install Local #####'
    wget https://mecab.googlecode.com/files/${MECAB_IPA_DICTIONARY_VERSION}.tar.gz
    tar -zxf ${MECAB_IPA_DICTIONARY_VERSION}.tar.gz
    cd ${MECAB_IPA_DICTIONARY_VERSION}
    ./configure --with-charset=${DEFAULT_CHARSET}
    make
    make install
fi

cd ${WORK_DIR}

echo '##### Download mecab-ipadic-NEologd #####'
if [ ! -e mecab-ipadic-neologd ]; then
    git clone https://github.com/neologd/mecab-ipadic-neologd.git
fi

cd mecab-ipadic-neologd

if [ -d build ]; then
    rm -rf build
fi

git pull
libexec/make-mecab-ipadic-neologd.sh -L ${MAX_BASEFORM_LENGTH}

DIR=`pwd`

NEOLOGD_BUILD_DIR=`find ${DIR}/build/mecab-ipadic-* -maxdepth 1 -type d`
NEOLOGD_DIRNAME=`basename ${NEOLOGD_BUILD_DIR}`
NEOLOGD_VERSION_DATE=`echo ${NEOLOGD_DIRNAME} | perl -wp -e 's!.+-(\d+)!$1!'`

cd ${WORK_DIR}

echo '##### Clone & Build Lucene #####'
if [ ! -e lucene-solr ]; then
    git clone https://github.com/apache/lucene-solr.git
else
    cd lucene-solr
    git checkout *
    git checkout trunk
    ant clean
    git pull
    cd ..
fi

cd lucene-solr
LUCENE_SRC_DIR=`pwd`

git checkout ${LUCENE_VERSION_TAG}

cd lucene
ant ivy-bootstrap

cd analysis/kuromoji

git checkout build.xml

ant regenerate
if [ $? -ne 0 ]; then
    echo 'Standard IPA Dictionary Build Fail.'
    exit 1
fi

echo '##### Build Lucene Kuromoji, with mecab-ipadic-NEologd #####'
cp -Rp ${NEOLOGD_BUILD_DIR} ${LUCENE_SRC_DIR}/lucene/build/analysis/kuromoji

perl -wp -i -e "s!mecab-ipadic-[.a-zA-Z0-9\-]+!${NEOLOGD_DIRNAME}!" build.xml
perl -wp -i -e 's!name="dict.encoding" value="[^"]+"!name="dict.encoding" value="utf-8"!' build.xml
perl -wp -i -e 's!, download-dict!!' build.xml
perl -wp -i -e 's!maxmemory="[^"]+"!maxmemory="2g"!' build.xml

ant regenerate
if [ $? -ne 0 ]; then
    echo 'Dictionary Build Fail.'
    exit 1
fi

ant jar-core
if [ $? -ne 0 ]; then
    echo 'Kuromoji Build Fail.'
    exit 1
fi

cd ${WORK_DIR}

JAR_PATH=`ls -1 ${LUCENE_SRC_DIR}/lucene/build/analysis/kuromoji/lucene-analyzers-kuromoji*`
echo ${JAR_PATH} | perl -wp -e 's!((.+/)(lucene-analyzers-kuromoji)-([0-9.]+)-(.+))!mv $1 $2$3-ipadic-neologd-$4-NEOLOGD_VERSION_DATE-$5!' | perl -wp -e "s!NEOLOGD_VERSION_DATE!${NEOLOGD_VERSION_DATE}!" | perl -wn -e 'system($_)'

cp ${LUCENE_SRC_DIR}/lucene/build/analysis/kuromoji/lucene-analyzers-kuromoji* ./.

ls -l lucene-analyzers-kuromoji*
echo '##### END #####'
