#!/usr/bin/env python

import os
import json
from gluon import DAL
from gluon import Field

import time

class Corpus:
	def __init__( self, request ):
		self.request = request
		self.params = self.GetParams()
	
	def GetParams( self ):
		def GetNonNegativeInteger( key, defaultValue ):
			try:
				n = int( self.request.vars[ key ] )
				if n >= 0:
					return n
				else:
					return 0
			except:
				return defaultValue
		
		def GetString( key, defaultValue ):
			if key in self.request.vars:
				return self.request.vars[ key ]
			else:
				return defaultValue
		
		params = {
			'searchLimit' : GetNonNegativeInteger( 'searchLimit', 100 ),
			'searchOffset' : GetNonNegativeInteger( 'searchOffset', 0 ),
			'searchText' : GetString( 'searchText', '' ),
			'searchOrdering' : GetString( 'searchOrdering', '' ),
			'termLimit' : GetNonNegativeInteger( 'termLimit', 100 ),
			'termOffset' : GetNonNegativeInteger( 'termOffset', 0 )
		}
		return params
	
	def GetDocMeta( self, params = None ):
		if params is None:
			params = self.params
		searchText = params["searchText"]
		searchLimit = params["searchLimit"]
		searchOffset = params["searchOffset"]
		
		print "web2py"
		start = time.clock()
		
		# get data using web2py application layer
		db = DAL('sqlite://doc-meta.sqlite', migrate_enabled=False)
		db.define_table('DocMeta', Field('Key'), Field('DocContent'), Field('DocID'), primarykey=['Key'])
		
		# build query using params
		q = db.DocMeta.DocContent.like('%' + searchText + '%')
		matches = db(q).count();
		limitb = searchOffset + searchLimit
		
		count = 0
		pyResults = {}
		queryResults = db(q).select(orderby=db.DocMeta.DocID, orderby_on_limitby = False, limitby=(searchOffset, limitb));
		for row in queryResults:
		    count += 1
		    pyResults[row.DocID] = dict(row)
		
		elapsed = (time.clock() -start)
		print "elapsed = ", elapsed
		        
		        
		print "exhaustive"
		start = time.clock()
		# get data using exhaustive search of JSON
		filename = os.path.join( self.request.folder, 'data/corpus', 'doc-meta.json' )
		with open( filename ) as f:
			content = json.load( f, encoding = 'utf-8' )
			results = {}
			matchCount = 0
			discardCount = 0
			keys = sorted(content.keys())
			for index in range(len(keys)):
			    obj = content[keys[index]]
			    docContent = obj["DocContent"]
			    if searchText in docContent:
			        matchCount += 1
			        if len(results.keys()) < searchLimit and discardCount >= searchOffset:
			            results[obj["DocID"]] = obj
			        elif discardCount < searchOffset:
			            discardCount += 1
		elapsed = (time.clock() - start)
		print "elapsed = ", elapsed
		
		return {
			"Documents" : pyResults,
			"docCount" : len(pyResults),
			"docMaxCount" : matches
		}

	def GetTermFreqs( self, params = None ):
		if params is None:
			params = self.params
		termLimit = params['termLimit']
		termOffset = params['termOffset']

		filename = os.path.join( self.request.folder, 'data/corpus', 'term-freqs.json' )
		with open( filename ) as f:
			allTermFreqs = json.load( f, encoding = 'utf-8' )
		allTerms = sorted( allTermFreqs.keys(), key = lambda x : -allTermFreqs[x] )
		terms = allTerms[termOffset:termOffset+termLimit]
		termFreqs = { term : allTermFreqs[term] for term in terms if term in allTermFreqs }
		return termFreqs

	def GetTermCoFreqs( self, params = None ):
		if params is None:
			params = self.params
		termLimit = params['termLimit']
		termOffset = params['termOffset']

		filename = os.path.join( self.request.folder, 'data/corpus', 'term-freqs.json' )
		with open( filename ) as f:
			allTermFreqs = json.load( f, encoding = 'utf-8' )
		allTerms = sorted( allTermFreqs.keys(), key = lambda x : -allTermFreqs[x] )
		terms = allTerms[termOffset:termOffset+termLimit]
		
		filename = os.path.join( self.request.folder, 'data/corpus', 'term-co-freqs.json' )
		with open( filename ) as f:
			allTermCoFreqs = json.load( f, encoding = 'utf-8' )
		termCoFreqs = { term : allTermCoFreqs[term] for term in terms if term in allTermCoFreqs }
		for term, termFreqs in termCoFreqs.iteritems():
			termCoFreqs[ term ] = { t : termFreqs[t] for t in terms if t in termFreqs }
		return termCoFreqs
