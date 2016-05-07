# Script de requete sur fr.dbpedia.org avec SPARQLWrapper
# Lancer avec pour argument une requete SPARQL bien formee, sans prefixes

import sys
from SPARQLWrapper import SPARQLWrapper, JSON

sparql = SPARQLWrapper("http://fr.dbpedia.org/sparql")

# Liste de prefixes requis pour faire une requete sur fr.dbpedia.org
prefixes = """PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX : <http://dbpedia.org/resource/>
PREFIX dbpedia2: <http://dbpedia.org/property/>
PREFIX dbpedia: <http://dbpedia.org/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>"""

# Concatenation des prefixes et de la requete en argument sur la CLI
requete = "%s %s" % (prefixes, sys.argv[1])
sparql.setQuery(requete)

sparql.setReturnFormat(JSON)
results = sparql.query().convert()

outputfile = open('outputpython.txt', 'w')
    
for result in results["results"]["bindings"]:
	ligne1 = """<binding name="entite"><uri>""" + (result["entite"]["value"]) + """</uri></binding>"""
	ligne2 = """<binding name="nomInternational"><uri>""" + (result["nomInternational"]["value"]) + """</uri></binding>"""
	ligne1_utf8 = ligne1.encode('utf-8')
	ligne2_utf8 = ligne2.encode('utf-8')
	outputfile.write(ligne1_utf8 + '\n')
	outputfile.write(ligne2_utf8 + '\n')

outputfile.close()