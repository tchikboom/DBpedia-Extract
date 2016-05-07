#DBpedia Extractor

##Synopsis
`perl DBpediaExtractor.pl [OPTIONS]...`

##Description
Exécute des requêtes SPARQL sur l'endpoint SPARQL fr.dbpedia.org et enregistre les résultats au format XML.

##Options
#####--install
  Installe SPARQLWrapper, dépendance nécessaire au bon fonctionnement du programme.
#####-o, --output*=NOM*
  Détermine le nom du fichier de sortie. ("out.xml" par défaut)
  Vous pouvez également indiquer un chemin de fichier.
#####-l, --language*=LISTE*
  N'affiche que les langues dont le code ISO-639-1 est spécifié dans la liste.
  Les codes doivent être séparés d'une virgule.
#####--man, --help
  Affiche cette page.

## Exemples
`perl DBpediaExtractor.pl` : Lance le programme.

`perl DBpediaExtractor.pl -l fr,nl,de` : Ne récupère que les résultats pour le français, le néerlandais et l'allemand.

`perl DBpediaExtractor.pl -o rivières.xml` : Imprime les résultats dans le fichier "rivières.xml".
## Auteurs
DBpediaExtractor a été écrit par Zakarya Després, Loïc Galand, Justine Mouveaux, Renise Pierre, Mathilde Poulain et Léon-Paul Schaub, tous étudiants en TAL à l'INALCO.

[SPARQLWrapper](https://rdflib.github.io/sparqlwrapper/) a été écrit par Sergio Fernández, Carlos Tejo, Ivan Herman et Alexey Zakhlestin.
