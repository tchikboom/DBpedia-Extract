#!/usr/bin/perl

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
my $class="";
print "Création de la table des classes...\n";
my %classliste;
if (!open (CLASSLISTE,"<:encoding(utf8)","classlist.txt")) {die "Impossible d'ouvrir classlist.txt : $!\n"};
while (my $classline = <CLASSLISTE>)
{
    chomp ($classline);
    $classliste{lc($classline)}=$classline;
}
my $query = selectionclass();
system("python SPARQLWrapper.py \"$query\"");
transfoxml("outputpython.txt");
system ("sed -i 's/&/&amp;/g' out.xml ");


sub selectionclass
{
  while (true)
  {
    print "Quelle catégorie d'entitées voulez-vous récupérer ?\n";
    chomp($class = <STDIN>);
    $class = lc($class);
    if (exists $classliste{$class})
    {
      return "select ?entite ?nomInternational where {?entite rdf:type dbpedia-owl:".$classliste{$class}.". ?entite owl:sameAs ?nomInternational}";
    } 
    print "Cette catégorie n'existe pas.\n"
  }
}

sub transfoxml
{
      my ($fichier) = @_;
      if (!open (SPARQL,"<:encoding(utf8)","$fichier")) {die "Impossible d'ouvrir sparql\n"};
      if (!open (OUT,">:encoding(utf8)","out.xml")) {die "Impossible d'ouvrir out.xml\n"};

      my $entite_prec = "BEGIN";
      my $entite;
      my $langue;
      my $traduction;

      while (my $ligne = <SPARQL>)
      {
	
	if ($ligne =~ /<binding name="entite"><uri>http:\/\/fr.dbpedia.org\/resource\/([^<]*)<\/uri><\/binding>/)
	{
	  $entite = $1;
	  $entite =~ s/_/ /g ;
	  $entite =~ s/ \(.+\)//g ;
	  if ($entite_prec eq "BEGIN")
	  {
	    print OUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	    print OUT "<?xml-stylesheet type=\"text/xsl\" href=\"out.xslt\"?>\n";
	    print OUT "<sparql>\n";
	    print OUT "<recherche class=\"$class\">\n";
	    print OUT "<entite id=\"$entite\">\n";
	  }
	  elsif ($entite ne $entite_prec)
	  {
	    print OUT "</entite>\n";
	    print OUT "<entite id=\"$entite\">\n";
	    print OUT "<traduction lang=\"fr\">".$entite."<\/traduction>\n";
	  }

	  $entite_prec = $entite;
	}
	
	elsif ($ligne =~ /<binding name="nomInternational"><uri>http:\/\/([a-z]{2,2}).dbpedia.org\/resource\/([^<]*)<\/uri><\/binding>/)
	{
	  $langue = $1;
	  $traduction = $2;
	  $traduction =~ s/_/ /g ;
	  $traduction =~ s/ \(.+\)//g ;
	  if ($langue eq "fr")
	  {
	  	next;
	  }
	  print OUT "<traduction lang=\"$langue\">".$traduction."<\/traduction>\n";
	}
	
      }

      print OUT "</entite>\n";
      print OUT "</recherche>\n";
      print OUT "</sparql>\n";
      close SPARQL;
      close OUT;
}