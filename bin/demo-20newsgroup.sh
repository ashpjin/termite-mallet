#!/bin/bash

DEMO_PATH=demo-20newsgroups

function __create_folder__ {
	FOLDER=$1
	TAB=$2
	if [ ! -d $FOLDER ]
	then
		echo "${TAB}Creating folder: $FOLDER"
		mkdir $FOLDER
	fi
}

function __demo_fetch_data__ {
	DOWNLOAD_PATH=$DEMO_PATH/download
	CORPUS_PATH=$DEMO_PATH/corpus
	MODEL_PATH=$DEMO_PATH/model

	echo
	echo ">> Setting up the 20newsgroups dataset..."
	__create_folder__ $DEMO_PATH "    "

	if [ ! -d "$DOWNLOAD_PATH" ]
	then
		__create_folder__ $DOWNLOAD_PATH "    "
		echo "    Downloading the 20newsgroups dataset..."
		curl --insecure --location http://qwone.com/~jason/20Newsgroups/20news-18828.tar.gz > $DOWNLOAD_PATH/20news-18828.tar.gz
		echo "    Setting up 20newsgroups information page..."
		echo "<html><head><meta http-equiv='refresh' content='0;url=http://qwone.com/~jason/20Newsgroups/'></head></html>" > $DOWNLOAD_PATH/index.html
	else
		echo "    Already downloaded: $DOWNLOAD_PATH"
	fi
	
	if [ ! -d "$CORPUS_PATH" ]
	then
		__create_folder__ $CORPUS_PATH "    "
		echo "    Uncompressing the 20newsgroups dataset..."
		tar -zxf $DOWNLOAD_PATH/20news-18828.tar.gz 20news-18828 &&\
			mv 20news-18828/* $CORPUS_PATH &&\
			rmdir 20news-18828
	else
		echo "    Already available: $CORPUS_PATH"
	fi
}

function __demo_train_model__ {
	bin/train_from_folder.sh $CORPUS_PATH $MODEL_PATH
}

function __demo_import_model__ {
	bin/import_model.sh $MODEL_PATH 20newsgroups
}

bin/setup.sh
__demo_fetch_data__
__demo_train_model__
__demo_import_model__
bin/start_server.sh