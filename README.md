#DBpedia Extractor

##Synopsis
`perl DBpediaExtractor.pl [OPTIONS]...`

##Description
Extrait des entités nommées dans toutes les langues disponibles à partir de l'endpoint SPARQL fr.dbpedia.org/sparql.
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

## Utilisation en interface graphique

### Description
Extrait des entités nommées dans toutes les langues disponibles à partir de l'endpoint SPARQL fr.dbpedia.org/sparql.
### Options
Possibilité de choix des langues affichées dans le fichier de sortie :
- Dans la fenêtre correspondante, indiquer les codes ISO des langues choisies
  Par exemple pour le français : fr, pour le japonais : ja, pour l'espagnol : es, pour l'italien : it ...
- Si vous souhaitez afficher toutes les langues, écrivez "all" dans la fenêtre de choix des langues en lieu et place des codes des langues.

### Exemples
Taper dans la fenêtre demandant les langues choisies :
`fr,nl,de` : Ne récupère que les résultats pour le français, le néerlandais et l'allemand.

## Auteurs
DBpediaExtractor a été écrit par Zakarya Després, Loïc Galand, Justine Mouveaux, Renise Pierre, Mathilde Poulain et Léon-Paul Schaub, tous étudiants en TAL à l'INALCO.

[SPARQLWrapper](https://rdflib.github.io/sparqlwrapper/) a été écrit par Sergio Fernández, Carlos Tejo, Ivan Herman et Alexey Zakhlestin.

Interface graphique réalisée à partir (et avec l'aide) du site  : http://gtk2-perl.sourceforge.net/
