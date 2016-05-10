#DBpedia Extractor

##Synopsis
`perl DBpediaExtractor.pl`

##Description
DBExtractor est un programme avec une interface graphique permettant d'extraire des entités nommées dans toutes les langues disponibles à partir de l'endpoint SPARQL fr.dbpedia.org/sparql.

##Installation
Télécharger le dossier .zip, décompressez-le, puis tapez `sudo perl DBpediaExtractor.pl --install` dans votre terminal.

## Options
Vous pouvez choisir les langues affichées dans le fichier de sortie en indiquant les codes ISO des langues choisies séparées par des virgules dans la fenêtre correspondante.  
  
Par exemple pour le français : fr, pour le japonais : ja, pour l'espagnol : es, pour l'italien : it... La liste complète se trouve [ici](https://fr.wikipedia.org/wiki/Liste_des_codes_ISO_639-1).
  
Si vous souhaitez afficher toutes les langues, écrivez "all" dans la fenêtre de choix des langues en lieu et place des codes des langues.  

## Exemples

Taper dans la fenêtre demandant les langues choisies :  
`fr,nl,de` : Ne récupère que les résultats pour le français, le néerlandais et l'allemand.

## Auteurs
DBpediaExtractor a été écrit par Zakarya Després, Loïc Galand, Justine Mouveaux, Mathilde Poulain et Léon-Paul Schaub, tous étudiants en TAL à l'INALCO.

[SPARQLWrapper](https://rdflib.github.io/sparqlwrapper/) a été écrit par Sergio Fernández, Carlos Tejo, Ivan Herman et Alexey Zakhlestin.

Interface graphique réalisée à partir (et avec l'aide) du site : http://gtk2-perl.sourceforge.net/
