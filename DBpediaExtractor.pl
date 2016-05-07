#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;

my $install = "";
my $man = "";
my $outputfile = "";
my @tablangues = "";
GetOptions('install' => \$install,
		   'man' => \$man,
		   'help' => \$man,
		   'o=s' => \$outputfile,
		   'output=s' => \$outputfile,
		   'l=s' => \@tablangues);
@tablangues = split(/,/,join(',',@tablangues));

if ($man eq 1)
{
	system("man ./manpage");
	exit;
}

if ($install eq 1)
{
	print "Installation de SPARQLWrapper :\n" ;
	chdir "./sparqlwrapper-1.7.6/";
	system("python setup.py install");
	chdir "../";
	print "Installation effectuée.\nSi le programme ne fonctionne toujours pas, essayez la même commande précédée de sudo.\n";
	exit;
}

if ($outputfile eq ""){$outputfile = "out.xml"};

# Définition du préfixe RDF
my $prefix = "PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX : <http://dbpedia.org/resource/>
PREFIX dbpedia2: <http://dbpedia.org/property/>
PREFIX dbpedia: <http://dbpedia.org/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n";

# Création d'une table des classes en minuscules pour éviter les problèmes de majuscules/minuscules lors de la requête
my $class="";
my %classliste;
if (!open (CLASSLISTE,"<:encoding(utf8)","classlist.txt")) {die "Impossible d'ouvrir classlist.txt : $!\n"};
while (my $classline = <CLASSLISTE>)
{
	chomp ($classline);
	$classliste{lc($classline)}=$classline;
}

# Programme principal
print "Quelle catégorie d'entités voulez-vous récupérer ?\n";
my $query = selectionclass();
print "Veuillez patienter...\n";
system("python sparql.py \"$query\"");
transfoxml("outputpython.txt");
system ("sed -i 's/&/&amp;/g' out.xml ");
print "Le fichier $outputfile est prêt.\n" ;

# Demande une catégorie d'entité à l'utilisateur et vérifie si elle existe
sub selectionclass
{
	while (1)
	{
		chomp($class = <STDIN>);
		$class = lc($class);
		if (exists $classliste{$class})
		{
			return "select ?entite ?nomInternational where {?entite rdf:type dbpedia-owl:".$classliste{$class}.". ?entite owl:sameAs ?nomInternational}";
		}
		print "Cette catégorie n'existe pas, veuillez recommencer.\n"
	}
}

# Crée un fichier XML à partir du fichier de sortie en JSON de SPARQLWrapper.py
sub transfoxml
{
	my ($fichier) = @_;
	if (!open (SPARQL,"<:encoding(utf8)","$fichier")) {die "Impossible d'ouvrir sparql\n"};
	if (!open (OUT,">:encoding(utf8)","$outputfile")) {die "Impossible d'ouvrir out.xml\n"};

	my $entite_prec = "BEGIN";
	my $entite;
	my $langue;
	my $traduction;

	while (my $ligne = <SPARQL>)
	{
		if ($ligne =~ /<binding name="entite"><uri>http:\/\/fr.dbpedia.org\/resource\/([^<]*)<\/uri><\/binding>/)
		{
			$entite = $1;
			$entite =~ s/_/ /g;
			$entite =~ s/ \(.+\)//g;
			if ($entite_prec eq "BEGIN")
			{
				print OUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
				print OUT "<?xml-stylesheet type=\"text/xsl\" href=\"out.xslt\"?>\n";
				print OUT "<sparql>\n";
				print OUT "\t<recherche class=\"$class\">\n";
				print OUT "\t\t<entite id=\"$entite\">\n";
			}
			elsif ($entite ne $entite_prec)
			{
				print OUT "\t\t</entite>\n";
				print OUT "\t\t<entite id=\"$entite\">\n";
				print OUT "\t\t\t<traduction lang=\"fr\">".$entite."<\/traduction>\n";
			}

			$entite_prec = $entite;
		}
		elsif ($ligne =~ /<binding name="nomInternational"><uri>http:\/\/([a-z]{2,2}).dbpedia.org\/resource\/([^<]*)<\/uri><\/binding>/)
		{
			$langue = $1;
			$traduction = $2;
			$traduction =~ s/_/ /g;
			$traduction =~ s/ \(.+\)//g;
			if ($langue eq "fr"){next};
			if (@tablangues eq "")
			{
				print OUT "\t\t\t<traduction lang=\"$langue\">".$traduction."<\/traduction>\n";
			}
			else
			{
				foreach my $l (@tablangues)
				{
					if ($langue eq $l)
					{
						print OUT "\t\t\t<traduction lang=\"$langue\">".$traduction."<\/traduction>\n";
					}
					else{next};
				}
			}
		}
	}
	print OUT "\t\t</entite>\n";
	print OUT "\t</recherche>\n";
	print OUT "\t</sparql>\n";
	close SPARQL;
	close OUT;
}