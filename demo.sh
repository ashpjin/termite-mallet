#!/bin/bash

function __create_folder__ {
	FOLDER=$1
	TAB=$2
	if [ ! -d $FOLDER ]
	then
		echo "${TAB}Creating folder: $FOLDER"
		mkdir $FOLDER
	fi
}

function __fetch_infovis__ {
	bin/fetch_infovis.sh $DATASET_PATH
	META_PATH=$CORPUS_PATH/infovis-papers-meta.txt
	CORPUS_PATH=$CORPUS_PATH/infovis-papers.txt
}

function __fetch_20newsgroups__ {
	bin/fetch_20newsgroups.sh $DATASET_PATH
	META_PATH=
	CORPUS_PATH=$CORPUS_PATH
}

function __train_mallet__ {
	bin/setup_mallet.sh
	echo "# Training a MALLET LDA topic model..."
	echo
	echo "bin/train_mallet.sh $CORPUS_PATH $MODEL_PATH"
	echo
	bin/train_mallet.sh $CORPUS_PATH $MODEL_PATH
	echo
}

function __import_mallet__ {
	echo "# Importing a MALLET LDA topic model..."
	echo
	echo "bin/import_mallet.py $APP_IDENTIFIER $MODEL_PATH"
	echo
	bin/import_mallet.py $APP_IDENTIFIER $MODEL_PATH
	echo
	if [ "$META_PATH" == "" ]
	then
		echo "bin/import_corpus.py $APP_IDENTIFIER --terms $MODEL_PATH/corpus.mallet"
		echo
		bin/import_corpus.py $APP_IDENTIFIER --terms $MODEL_PATH/corpus.mallet
	else
		echo "bin/import_corpus.py $APP_IDENTIFIER --terms $MODEL_PATH/corpus.mallet --meta $META_PATH"
		echo
		bin/import_corpus.py $APP_IDENTIFIER --terms $MODEL_PATH/corpus.mallet --meta $META_PATH
	fi
	echo
}

function __train_treetm__ {
	bin/setup_treetm.sh
	echo "# Training a TreeTM model..."
	echo
	echo "bin/train_treetm.py $CORPUS_PATH $MODEL_PATH --iters 100"
	echo
	bin/train_treetm.py $CORPUS_PATH $MODEL_PATH --iters 100
	echo
}

function __import_treetm__ {
	echo "# Importing a TreeTM model..."
	echo
	echo "bin/import_treetm.py $APP_IDENTIFIER $MODEL_PATH"
	echo
	bin/import_treetm.py $APP_IDENTIFIER $MODEL_PATH
	echo
	if [ "$META_PATH" == "" ]
	then
		echo "bin/import_corpus.py $APP_IDENTIFIER --terms $MODEL_PATH/corpus.mallet"
		echo
		bin/import_corpus.py $APP_IDENTIFIER --terms $MODEL_PATH/corpus.mallet
	else
		echo "bin/import_corpus.py $APP_IDENTIFIER --terms $MODEL_PATH/corpus.mallet --meta $META_PATH"
		echo
		bin/import_corpus.py $APP_IDENTIFIER --terms $MODEL_PATH/corpus.mallet --meta $META_PATH
	fi
	echo
}

function __train_stmt__ {
	bin/setup_stmt.sh
	echo "# Training a STMT model..."
	echo
	echo "bin/train_stmt.py $CORPUS_PATH $MODEL_PATH"
	echo
	bin/train_stmt.py $CORPUS_PATH $MODEL_PATH
	echo
}

function __import_stmt__ {
	echo "# Importing a STMT model..."
	echo
	echo "bin/import_stmt.py $APP_IDENTIFIER $MODEL_PATH"
	echo
	bin/import_stmt.py $APP_IDENTIFIER $MODEL_PATH
	echo
	if [ "$META_PATH" == "" ]
	then
		echo "bin/import_corpus.py $APP_IDENTIFIER"
		echo
		bin/import_corpus.py $APP_IDENTIFIER
	else
		echo "bin/import_corpus.py $APP_IDENTIFIER --meta $META_PATH"
		echo
		bin/import_corpus.py $APP_IDENTIFIER --meta $META_PATH
	fi
	echo
}

function __train_gensim__ {
	bin/setup_gensim.sh
	echo "# Training a gensim LDA topic model..."
	echo
	echo "bin/train_gensim.py $CORPUS_PATH $MODEL_PATH"
	echo
	bin/train_gensim.py $CORPUS_PATH $MODEL_PATH
	echo
}

function __import_gensim__ {
	echo "# Importing a gensim LDA topic model..."
	echo
	echo "bin/import_gensim.py $APP_IDENTIFIER $MODEL_PATH/corpus.dict $MODEL_PATH/output.model"
	echo
	bin/import_gensim.py $APP_IDENTIFIER $MODEL_PATH/corpus.dict $MODEL_PATH/output.model
	echo
	if [ "$META_PATH" == "" ]
	then
		echo "bin/import_corpus.py $APP_IDENTIFIER"
		echo
		bin/import_corpus.py $APP_IDENTIFIER
	else
		echo "bin/import_corpus.py $APP_IDENTIFIER --meta $META_PATH"
		echo
		bin/import_corpus.py $APP_IDENTIFIER --meta $META_PATH
	fi
}

if [ $# -ge 1 ] && [ "$1" != "-h" ] && [ "$1" != "--help" ]
then
	DATASET=$1
	if [ "$DATASET" == "infovis" ] || [ "$DATASET" == "20newsgroups" ]
	then
		FETCH_DATASET=__fetch_${DATASET}__
		DATASET_PATH=data/demo/$DATASET
		CORPUS_PATH=$DATASET_PATH/corpus
		META_PATH=
		if [ $# -ge 2 ]
		then
			MODEL=$2
		else
			MODEL="mallet"
		fi
		if [ "$MODEL" == "mallet" ] || [ "$MODEL" == "treetm" ] || [ "$MODEL" == "stmt" ] || [ "$MODEL" == "stm" ] || [ "$MODEL" == "gensim" ]
		then
			TRAIN_MODEL=__train_${MODEL}__
			IMPORT_MODEL=__import_${MODEL}__
			MODEL_PATH=$DATASET_PATH/model-$MODEL
			APP_IDENTIFIER=${DATASET}_${MODEL}
			
			bin/setup_web2py.sh
			__create_folder__ data
			__create_folder__ data/demo
			$FETCH_DATASET
			$TRAIN_MODEL
			$IMPORT_MODEL
			./start_server.sh
			exit 0
		fi
	fi
fi

echo "Usage: $0 dataset model"
echo
echo "Available datasets:"
echo "      infovis | IEEE InfoVis Proceedings from 1995 to 2011"
echo "              | 449 paper abstracts with title, authors, year"
echo
echo " 20newsgroups | User postings in 20 newsgroups"
echo "              | 18,828 postings with duplicates removed"
echo "              | http://qwone.com/~jason/20Newsgroups"
echo
echo "Available models:"
echo "       mallet | MAchine Learning for LanguagE Toolkit (MALLET)"
echo "              | Default topic model if none is specified"
echo "              | http://mallet.cs.umass.edu"
echo
echo "       treetm | Efficient Tree-based Topic Modeling"
echo "              | http://www.cs.umd.edu/~ynhu"
echo
echo "         stmt | Stanford Topic Modeling Toolbox"
echo "              | http://nlp.stanford.edu/downloads/tmt"
echo
echo "          stm | Structural Topic Models"
echo "              | Requires R"
echo "              | http://scholar.harvard.edu/mroberts"
echo
echo "       gensim | Gensim"
echo "              | Requires numpy and scipy"
echo "              | http://radimrehurek.com/gensim/"
echo
