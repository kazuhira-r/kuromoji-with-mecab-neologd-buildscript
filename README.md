# buildscript for Kuromoji with mecab-neologd
These scripts to build a Lucene Kuromoji or Atilika Kuromoji with bundled mecab-ipadic-NEologd.

## What's Lucene Kuromoji
[Apache Lucene](http://lucene.apache.org/core/) is a high-performance, full-featured text search engine library written entirely in Java.  
Kuromoji is morphological analyzer which is included in Apache Lucene.

## What's Atilika Kuromoji
[Kuromoji](https://www.atilika.com/en/products/kuromoji.html) is an open source Japanese morphological analyzer written in Java.

## What's NEologd
[mecab-ipadic-NEologd](https://github.com/neologd/mecab-ipadic-neologd) : Neologism dictionary for MeCab

*Note:*

These build scripts are supporting is only IPA dictionary.

## Supported versions
Lucene Kuromoji: 4.x, 5.x, 6.x

Atilika Kuromoji: 0.9.0

## Usage
### Requirements
To use this script, you must install the following software.

* [JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [Apache Ant](http://ant.apache.org/) (for Lucene Kuromoji)
* [Apache Maven](https://maven.apache.org/) (for Atilika Kuromoji)
* C++ compiler
* Git
* Perl
* wget
* iconv
* xz
* [MeCab](http://taku910.github.io/mecab/) (optional)
* [mecab-ipadic](https://sourceforge.net/projects/mecab/files/mecab-ipadic/) (optional)

*Note:*

Many CPU and memory resource are used by a build.

About 5-6 GB of JavaVM heap is needed at present.

## Build Lucene Kuromoji for mecab-ipadic-NEologd
### Install
```shellscript
$ git clone https://github.com/kazuhira-r/kuromoji-with-mecab-neologd-buildscript
```
or
```shellscript
$ wget https://raw.githubusercontent.com/kazuhira-r/kuromoji-with-mecab-neologd-buildscript/master/build-lucene-kuromoji-with-mecab-ipadic-neologd.sh
```

Please to grant execute permissions.
```shellscript
$ chmod a+x build-lucene-kuromoji-with-mecab-ipadic-neologd.sh
```

### Build
In any directory, please run the script.
```shellscript
$ /path/to/build-lucene-kuromoji-with-mecab-ipadic-neologd.sh
```

The setting when execute, is indicated.
```
### [2016-05-29 15:18:45] [main] [INFO] START.

####################################################################
applied build options.

[MeCab Version]                 ... mecab-0.996
[MeCab IPA Dictionary Version]  ... mecab-ipadic-2.7.0-20070801
[Dictionary CharacterSet]       ... utf-8
[mecab-ipadic-NEologd Tag (-N)] ... master
[install adjective ext (-T)]    ... 0
[Max BaseForm Length]           ... 15
[Lucene Version Tag (-L)]       ... releases/lucene-solr/6.0.1
[Kuromoji Package Name (-p)]    ... org.apache.lucene.analysis.ja

####################################################################
```

That were built JAR file will be created in **current directory** where you run the script.

```shellscript
$ ls -l
total 60212
-rw-rw-r-- 1 xyz xyz 48023660 May 29 15:31 lucene-analyzers-kuromoji-ipadic-neologd-6.0.1-20160526-SNAPSHOT.jar
drwxrwxr-x 6 xyz xyz     4096 May 29 15:21 lucene-solr
drwxrwxr-x 8 xyz xyz     4096 May 23  2015 mecab
drwxr-xr-x 8 xyz xyz     4096 May 23  2015 mecab-0.996
-rw-rw-r-- 1 xyz xyz  1398663 Feb 18  2013 mecab-0.996.tar.gz
drwxrwxr-x 2 xyz xyz     4096 May 23  2015 mecab-ipadic-2.7.0-20070801
-rw-rw-r-- 1 xyz xyz 12208105 Oct 16  2011 mecab-ipadic-2.7.0-20070801.tar.gz
drwxrwxr-x 9 xyz xyz     4096 May 29 15:19 mecab-ipadic-neologd
```

In this case, it is "lucene-analyzers-kuromoji-ipadic-neologd-6.0.1-20160526-SNAPSHOT.jar" JAR file that was built.

### JAR file naming
Naming of a JAR file of a build result is as follows.

```
naming:
lucene-analyzers-kuromoji-ipadic-neologd-[Lucene Version]-[mecab-ipadic-NEologd dictionary date]-SNAPSHOT.jar

example:
lucene-analyzers-kuromoji-ipadic-neologd-6.0.1-20160526-SNAPSHOT.jar
```

### Build options
* -N - branch or tag name in mecab-ipadic-NEologd, included in a build. default: master
* -T - install adjective ext. if you want enable, specified 1. default: 0
* -L - branch or tag name in Apache Lucene of a build target. default: current Apache Lucene latest release tag.
* -p - package name at the time of a build. default: org.apache.lucene.analysis.ja (original package)

## Build Atilika Kuromoji for mecab-ipadic-NEologd
### Install
```shellscript
$ git clone https://github.com/kazuhira-r/kuromoji-with-mecab-neologd-buildscript
```
or
```shellscript
$ wget https://raw.githubusercontent.com/kazuhira-r/kuromoji-with-mecab-neologd-buildscript/master/build-atilika-kuromoji-with-mecab-ipadic-neologd.sh
```

Please to grant execute permissions.
```shellscript
$ chmod a+x build-atilika-kuromoji-with-mecab-ipadic-neologd.sh
```

### Build
In any directory, please run the script.
```shellscript
$ /path/to/build-atilika-kuromoji-with-mecab-ipadic-neologd.sh
```

The setting when execute, is indicated.
```
### [2016-05-29 16:14:34] [main] [INFO] START.

####################################################################
applied build options.

[MeCab Version]                 ... mecab-0.996
[MeCab IPA Dictionary Version]  ... mecab-ipadic-2.7.0-20070801
[Dictionary CharacterSet]       ... utf-8
[mecab-ipadic-NEologd Tag (-N)] ... master
[install adjective ext (-T)]    ... 0
[Kuromoji Version Tag (-K)]     ... 0.9.0
[Kuromoji Package Name (-p)]    ... com.atilika.kuromoji.ipadic

####################################################################
```

That were built JAR file will be created in **current directory** where you run the script.

```shellscript
$ ls -l
total 133868
drwxrwxr-x 10 xyz xyz      4096 May 29 16:44 kuromoji
-rw-rw-r--  1 xyz xyz 123447215 May 29 17:12 kuromoji-ipadic-neologd-0.9.0-20160526.jar
drwxrwxr-x  8 xyz xyz      4096 Sep 19  2015 mecab
drwxr-xr-x  8 xyz xyz      4096 Sep 19  2015 mecab-0.996
-rw-rw-r--  1 xyz xyz   1398663 Feb 18  2013 mecab-0.996.tar.gz
drwxrwxr-x  2 xyz xyz      4096 Sep 19  2015 mecab-ipadic-2.7.0-20070801
-rw-rw-r--  1 xyz xyz  12208105 Oct 16  2011 mecab-ipadic-2.7.0-20070801.tar.gz
drwxrwxr-x  9 xyz xyz      4096 May 29 16:43 mecab-ipadic-neologd
```

In this case, it is "kuromoji-ipadic-neologd-0.9.0-20160526.jar" JAR file that was built.

### JAR file naming
Naming of a JAR file of a build result is as follows.

```
naming:
kuromoji-ipadic-neologd-[Atilika Kuromoji Version]-[mecab-ipadic-NEologd dictionary date].jar

example:
kuromoji-ipadic-neologd-0.9.0-20160526.jar
```

### Build options
* -N - branch or tag name in mecab-ipadic-NEologd, included in a build. default: master
* -T - install adjective ext. if you want enable, specified 1. default: 0
* -K - branch or tag name in Atilika Kuromoji of a build target. default: current Atilika Kuromoji latest release tag.
* -p - package name at the time of a build. default: com.atilika.kuromoji.ipadic (original package)

## Internal Process
This script, perform the following processing.

* Check the installation of MeCab, Installing MeCab in the current directory unless MeCab is not installed
* Check the installation of MeCab, Installing mecab-ipadic in the current directory unless MeCab is not installed
* Clone mecab-ipadic-NEologd
* Generate a dictionary CSV(using libexec/make-mecab-ipadic-neologd.sh -L)
* Clone Apache Lucene or Atilika Kuromoji source code
* (Lucene Kuromoji only) Edit Apache Lucene Kuromoji's build.xml
* Rename package name, when being necessary
* Build Kuromoji and dictionary with mecab-ipadic-NEologd
* Copy JAR file to current directory

## LICENSE
Copyright &copy; 2015, 2016 kazuhira-r


Licensed under the [Apache License, Version 2.0][Apache]
 
[Apache]: http://www.apache.org/licenses/LICENSE-2.0
