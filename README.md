# buildscript for Kuromoji with mecab-neologd
These scripts to build a Lucene Kuromoji or Atilika Kuromoji with bundled mecab-ipadic-NEologd.

## What's Lucene Kuromoji
[Apache Lucene](http://lucene.apache.org/core/) is a high-performance, full-featured text search engine library written entirely in Java.  
Kuromoji is morphological analyzer which is included in Apache Lucene.

## What's Atilika Kuromoji
[Kuromoji](https://www.atilika.com/en/products/kuromoji.html) is an open source Japanese morphological analyzer written in Java.

## What's NEologd
[mecab-ipadic-NEologd](https://github.com/neologd/mecab-ipadic-neologd) : Neologism dictionary for MeCab

*Note: These build scripts are supporting is only IPA dictionary.*

## Supported versions
Lucene Kuromoji: 4.x, 5.x, 6.x, 7.x

Atilika Kuromoji: 0.9.0

## Usage
### Requirements
To use this script, you must install the following software.

* [JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [Apache Ant](http://ant.apache.org/) (for Lucene Kuromoji)
* [Apache Maven](https://maven.apache.org/) (for Atilika Kuromoji)
* Git
* make
* curl
* iconv
* xz
* Perl
* [MeCab (mecab/mecab-config)](http://taku910.github.io/mecab/) (optional, auto install)
* C++ Compiler (when MeCab is installed automatically)

*Note: Many CPU and memory resource are used by a build. About 5-6 GB of JavaVM heap is needed at present.*

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
### [2016-12-18 17:57:02] [main] [INFO] START.

####################################################################
applied build options.

[Auto Install MeCab Version                  ]    ... mecab-0.996
[mecab-ipadic-NEologd Tag                (-N)]    ... master

*** deprecated option *** 
[install adjective ext                   (-T)]    ... 0
*** deprecated option *** 


[Max BaseForm Length                         ]    ... 15
[Lucene Version Tag                      (-L)]    ... releases/lucene-solr/6.3.0
[Kuromoji build Max Heapsize             (-M)]    ... 6g
[Kuromoji JAR File Output Directory Name (-o)]    ... .
[Kuromoji Package Name                   (-p)]    ... org.apache.lucene.analysis.ja

####################################################################
```

That were built JAR file will be created in user specified directory (default: current directory) where you run the script.

```shellscript
$ ls -l
total 51832
-rw-rw-r-- 1 xyz xyz 51655324 Dec 18 18:05 lucene-analyzers-kuromoji-ipadic-neologd-6.3.0-20161215.jar
drwxrwxr-x 6 xyz xyz     4096 Dec 18 18:02 lucene-solr
drwxrwxr-x 8 xyz xyz     4096 Jul 23 00:32 mecab
drwxr-xr-x 8 xyz xyz     4096 Jul 23 00:31 mecab-0.996
-rw-rw-r-- 1 xyz xyz  1398663 Jul 23 00:31 mecab-0.996.tar.gz
drwxrwxr-x 9 xyz xyz     4096 Dec 18 17:59 mecab-ipadic-neologd

```

In this case, it is "lucene-analyzers-kuromoji-ipadic-neologd-6.3.0-20161215.jar" JAR file that was built.

### JAR file naming
Naming of a JAR file of a build result is as follows.

```
naming:
lucene-analyzers-kuromoji-ipadic-neologd-[Lucene Version]-[mecab-ipadic-NEologd dictionary date].jar

example:
lucene-analyzers-kuromoji-ipadic-neologd-6.3.0-20161215.jar
```

### Build options
* -N - branch or tag name in mecab-ipadic-NEologd, included in a build. default: master
* \*\*\***deprecated**\*\*\* -T - install adjective ext. if you want enable, specified 1. default: 0
* -L - branch or tag name in Apache Lucene of a build target. default: current Apache Lucene latest release tag.
* -M - Kuromoji build max heapsize.
* -o - generated Kuromoji JAR file output directory. (default: . (current directory))
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
### [2016-12-18 23:10:54] [main] [INFO] START.

####################################################################
applied build options.

[Auto Install MeCab Version                  ]    ... mecab-0.996
[mecab-ipadic-NEologd Tag                (-N)]    ... master

*** deprecated option *** 
[install adjective ext                   (-T)]    ... 0
*** deprecated option *** 

[Kuromoji Version Tag                    (-K)]    ... 0.9.0
[Kuromoji build Max Heapsize             (-M)]    ... 7g
[Kuromoji JAR File Output Directory Name (-o)]    ... .
[Kuromoji Package Name                   (-p)]    ... com.atilika.kuromoji.ipadic

####################################################################
```

That were built JAR file will be created in user specified directory (default: current directory) where you run the script.

```shellscript
$ ls -l
total 133572
drwxrwxr-x 10 xyz xyz      4096 Dec 18 23:13 kuromoji
-rw-rw-r--  1 xyz xyz 135352388 Dec 18 23:33 kuromoji-ipadic-neologd-0.9.0-20161215.jar
drwxrwxr-x  8 xyz xyz      4096 Dec 18 22:39 mecab
drwxr-xr-x  8 xyz xyz      4096 Dec 18 22:39 mecab-0.996
-rw-rw-r--  1 xyz xyz   1398663 Jul 23 00:32 mecab-0.996.tar.gz
drwxrwxr-x  9 xyz xyz      4096 Dec 18 23:11 mecab-ipadic-neologd
```

In this case, it is "kuromoji-ipadic-neologd-0.9.0-20161215.jar" JAR file that was built.

### JAR file naming
Naming of a JAR file of a build result is as follows.

```
naming:
kuromoji-ipadic-neologd-[Atilika Kuromoji Version]-[mecab-ipadic-NEologd dictionary date].jar

example:
kuromoji-ipadic-neologd-0.9.0-20161215.jar
```

### Build options
* -N - branch or tag name in mecab-ipadic-NEologd, included in a build. default: master
* \*\*\***deprecated**\*\*\* -T - install adjective ext. if you want enable, specified 1. default: 0
* -K - branch or tag name in Atilika Kuromoji of a build target. default: current Atilika Kuromoji latest release tag.
* -M - Kuromoji build max heapsize.
* -o - generated Kuromoji JAR file output directory. (default: . (current directory))
* -p - package name at the time of a build. default: com.atilika.kuromoji.ipadic (original package)

## Internal Process
This script, perform the following processing.

* Check the installation of MeCab, Installing MeCab in the current directory unless MeCab is not installed
* Clone mecab-ipadic-NEologd
* Generate a dictionary CSV(using libexec/make-mecab-ipadic-neologd.sh -L)
* Clone Apache Lucene or Atilika Kuromoji source code
* (Lucene Kuromoji only) Edit Apache Lucene Kuromoji's build.xml
* Rename package name, when being necessary
* Build Kuromoji and dictionary with mecab-ipadic-NEologd
* Copy JAR file to specified directory (default: current directory)

## LICENSE
Copyright &copy; 2015, 2016, 2017, 2018 kazuhira-r


Licensed under the [Apache License, Version 2.0][Apache]
 
[Apache]: http://www.apache.org/licenses/LICENSE-2.0
