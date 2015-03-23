# buildscript for Lucene Kuromoji with mecab-neologd
This script to build a Lucene Kuromoji with bundled mecab-xxxxx-neologd

## What's Lucene Kuromoji
[Apache Lucene](http://lucene.apache.org/core/) is a high-performance, full-featured text search engine library written entirely in Java.  
Kuromoji is morphological analyzer which is mounted on the Apache Lucene.

## What's neologd
[mecab-ipadic-NEologd](https://github.com/neologd/mecab-ipadic-neologd) : Neologism dictionary for MeCab

## What's this script
This is a script to build, including a dictionary of neologd the Kuromoji.

*Note*  
Support only build using IPA dictionary.

## Usage
### Requirements
To use this script, you must install the following software.

* [Apache Ant](http://ant.apache.org/)
* C++ compiler
* Git
* Perl
* iconv
* xz
* [MeCab](http://mecab.googlecode.com/svn/trunk/mecab/doc/index.html)(optional)
* [mecab-ipadic](http://mecab.googlecode.com/svn/trunk/mecab/doc/index.html)(optional)

### Install
```shellscript
$ git clone https://github.com/kazuhira-r/lucene-kuromoji-with-mecab-neologd-buildscript
```
or
```shellscript
$ wget https://raw.githubusercontent.com/kazuhira-r/lucene-kuromoji-with-mecab-neologd-buildscript/master/build-lucene-kuromoji-with-mecab-ipadic-neologd.sh
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

That were built JAR file will be created in **current directory** where you run the script.

```shellscript
$ ls -l
total 40384
-rwxrwxr-x 1 xyz xyz     4145 Mar 24 00:55 build-lucene-kuromoji-with-mecab-ipadic-neologd.sh
-rw-rw-r-- 1 xyz xyz 27710188 Mar 24 01:01 lucene-analyzers-kuromoji-ipadic-neologd-5.0.0-20150323-SNAPSHOT.jar
drwxrwxr-x 6 xyz xyz     4096 Mar 24 00:58 lucene-solr
drwxrwxr-x 8 xyz xyz     4096 Mar 24 00:56 mecab
drwxr-xr-x 8 xyz xyz     4096 Mar 24 00:55 mecab-0.996
-rw-rw-r-- 1 xyz xyz  1398663 Feb 18  2013 mecab-0.996.tar.gz
drwxrwxr-x 2 xyz xyz     4096 Mar 24 00:56 mecab-ipadic-2.7.0-20070801
-rw-rw-r-- 1 xyz xyz 12208105 Oct 16  2011 mecab-ipadic-2.7.0-20070801.tar.gz
drwxrwxr-x 8 xyz xyz     4096 Mar 24 00:57 mecab-ipadic-neologd
`````

In this case, it is "lucene-analyzers-kuromoji-ipadic-neologd-5.0.0-20150323-SNAPSHOT.jar" JAR file that was built.
