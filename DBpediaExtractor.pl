#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use Getopt::Long;

my $install = "";
my $man = "";
my $outputfile = "";
my @tablangues = "";
my $langues="";
GetOptions('install' => \$install);

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
# Mise en place de l'interface graphique 
use Glib qw/TRUE FALSE/;
use Gtk2 'init';

my $window = Gtk2::Dialog->new('Quelle catégorie d\'entitées voulez-vous récupérer ?',
            undef,
            [qw/modal destroy-with-parent/],
            'gtk-undo'     => 'reject',
			'gtk-save'     => 'accept',
);
$window->set_response_sensitive ('reject', FALSE);
$window->set_response_sensitive ('accept', FALSE);
$window->signal_connect('delete-event'=> sub {Gtk2->main_quit()});
$window->set_position('center-always');

&fill_dialog($window);
$window->show();
Gtk2->main();

# ------------------------------------- PROCEDURE -------------------------------------
sub fill_dialog 
{
	my ($window) = @_;
	my $vbox = $window->vbox;
	$vbox->set_border_width(4);

	#-------------------------------------
	my $table = Gtk2::Table->new (1, 2, FALSE);
	my $label = Gtk2::Label->new_with_mnemonic("_Nom de l'entité : ");
	$label->set_alignment(1,0.5);
	$table->attach_defaults ($label, 0, 1, 0,1);
	# Afficher une valeur initiale dans la zone d'écriture
	my $entry = Gtk2::Entry->new();
	my $ent_orig = &get_init_val();
	$entry->set_text($ent_orig);

	$entry->signal_connect (changed => sub 
	{
		# Garder le bouton "enregistrer" grisé tant que l'utilisateurn'a pas écrit quelque chose
		my $text = $entry->get_text;
		$window->set_response_sensitive ('accept', $text !~ m/^\s*$/);
		$window->set_response_sensitive ('reject', TRUE);
	});

	$label->set_mnemonic_widget ($entry);
	$table->attach_defaults($entry,1,2,0,1);

	#---------------------------------------
	$vbox->pack_start($table,0,0,4);

	$window->signal_connect(response => sub 
	{
		print "YOU CLICKED: ".$_[1]."\n";
		# Si l'utilisateur clique, on exécute le programme
		if($_[1] =~ m/accept/)
		{
			my $class = $entry->get_text();
			$class = lc($class);
			if (exists $classliste{$class})
			{
				# Afficher une boîte de dialogue pour le choix des langues
				my $languesutil = windowlangues();
				# Afficher une boîte de dialogue pour le choix du nom de fichier de sortie
				my $nameoutput = windowoutput();
				if ($languesutil eq "all")
				{
					my $query = "select ?entite ?nomInternational where {?entite rdf:type dbpedia-owl:".$classliste{$class}.". ?entite owl:sameAs ?nomInternational}";
					print "Veuillez patienter...\n";
					system("python sparql.py \"$query\"");
					transfoxmlsanslangues("outputpython.txt", $class, $nameoutput);
					system ("sed -i 's/&/&amp;/g' $nameoutput ");
					&show_message_dialog($window, 'info', "Le ficher $nameoutput est prêt.");
					Gtk2->main_quit();
				}
				else
				{
					@tablangues = split(/,/,join(',',$languesutil));

					# Lancement de la requête
					my $query = "select ?entite ?nomInternational where {?entite rdf:type dbpedia-owl:".$classliste{$class}.". ?entite owl:sameAs ?nomInternational}";
					print "Veuillez patienter...\n";
					system("python sparql.py \"$query\"");
					transfoxml("outputpython.txt", $class, $nameoutput);
					system ("sed -i 's/&/&amp;/g' $nameoutput ");
					&show_message_dialog($window, 'info', "Le ficher $nameoutput est prêt.");
					Gtk2->main_quit();
				}
			}
			else
			{
				&show_message_dialog($window, 'info', "Erreur, cette catégorie n\'existe pas.");
			}
		}
		# si on clique sur "annulrer", on réinitialise l'interface et on affiche la valeur par défaut.
		if($_[1] =~ m/reject/)
		{
			$entry->set_text($ent_orig);
			$window->set_response_sensitive ('reject', FALSE);
			$window->set_response_sensitive ('accept', FALSE);
		}
	});
	$vbox->show_all();
	return $vbox;
}


sub get_init_val 
{
	my $init_val = "Entrez_un_nom_d'entité";
	return $init_val;
}

# Boîte de dialoque pour les messages d'erreur et d'information pour l'utilisateur.
sub show_message_dialog 
{
	my ($parent,$icon,$text) = @_;
	my $dialog = Gtk2::MessageDialog->new_with_markup ($parent,
						[qw/modal destroy-with-parent/],
						$icon,
						'ok',
						sprintf "$text");
	$dialog->run;
	$dialog->destroy;
}

# Crée un fichier XML à partir du fichier de sortie en JSON de SPARQLWrapper.py
sub transfoxml
{
	my ($fichier, $class, $outputfile) = @_;
	if (!open (SPARQL,"<:encoding(utf8)","$fichier")) {die "Impossible d'ouvrir sparql\n"};
	if (!open (OUT,">:encoding(utf8)","$outputfile")) {die "Impossible d'ouvrir out.xml\n"};

	my $entite_prec = "BEGIN";
	my $entite;
	my $traduction;
	my $langue;

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

sub transfoxmlsanslangues
# Crée un fichier XML à partir du fichier de sortie en JSON de SPARQLWrapper.py

{
	my ($fichier, $class, $outputfile) = @_;
	if (!open (SPARQL,"<:encoding(utf8)","$fichier")) {die "Impossible d'ouvrir sparql\n"};
	if (!open (OUT,">:encoding(utf8)","$outputfile")) {die "Impossible d'ouvrir out.xml\n"};

	my $entite_prec = "BEGIN";
	my $entite;
	my $traduction;
	my $langue;

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
			print OUT "\t\t\t<traduction lang=\"$langue\">".$traduction."<\/traduction>\n";
		}
	}
	print OUT "\t\t</entite>\n";
	print OUT "\t</recherche>\n";
	print OUT "\t</sparql>\n";
	close SPARQL;
	close OUT;
}

# -----------------------------Fenêtre de choix des langues -------------------------
sub windowlangues
{
	my $langues="";
	# Ouvrir une boîte de dialogue pour le choix des langues
	my $windowlangues = Gtk2::Dialog->new('Quelles langues cherchez-vous ?',
								undef,
								[qw/modal destroy-with-parent/],
								'gtk-ok'     => 'accept',
								);
	$windowlangues->set_response_sensitive ('accept', FALSE);
 	$windowlangues->signal_connect('delete-event'=> sub {Gtk2->main_quit()});
	$windowlangues->set_position('center-always');
	&fill_dialoglangues($windowlangues);
	$windowlangues->show();
	Gtk2->main();

	# ------------------------------------- PROCEDURE -------------------------------------
	sub fill_dialoglangues 
	{
		my ($windowlangues) = @_;
		my $text="";
		my $vbox = $windowlangues->vbox;
		$vbox->set_border_width(4);
		#-------------------------------------
		my $table = Gtk2::Table->new (1, 2, FALSE);
		my $label = Gtk2::Label->new_with_mnemonic("_Codes ISO des langues : ");
		$label->set_alignment(1,0.5);
		$table->attach_defaults ($label, 0, 1, 0,1);
		my $entreelangue = Gtk2::Entry->new();
		$entreelangue->signal_connect (changed => sub
		{
			# Grise le bouton de validation si la zone de texte est vide
			$text = $entreelangue->get_text;
			$windowlangues->set_response_sensitive ('accept', $text !~ m/^\s*$/);
		});
		
		$label->set_mnemonic_widget ($entreelangue);
		$table->attach_defaults($entreelangue,1,2,0,1);
		#---------------------------------------
		$vbox->pack_start($table,0,0,4);
		$windowlangues->signal_connect(response => sub 
		{
			#if the person clicked save, we show a message
			if($_[1] =~ m/accept/)
			{
				$langues = $entreelangue->get_text();
				Gtk2->main_quit();
			}
		});
		$vbox->show_all();
		return $vbox;
	}
	return $langues;
}

# -----------------------------Fenêtre de choix du nom de fichier sortie-------------------------
sub windowoutput
{
	# Ouvrir une boîte de dialogue pour le choix du nom du fichier sortie
	my $output ="";
	my $windowoutput = Gtk2::Dialog->new('Quel nom pour le fichier de sortie ?',
										 undef,
										 [qw/modal destroy-with-parent/],
										 'gtk-ok'     => 'accept',
										);
	$windowoutput->set_response_sensitive ('accept', FALSE);
 	$windowoutput->signal_connect('delete-event'=> sub {Gtk2->main_quit()});
	$windowoutput->set_position('center-always');
	&fill_dialogoutput($windowoutput);
	$windowoutput->show();
	Gtk2->main();

	# ------------------------------------- PROCEDURE -------------------------------------
	sub fill_dialogoutput 
	{
		my ($windowoutput) = @_;
		my $text="";
		my $vbox = $windowoutput->vbox;
		$vbox->set_border_width(4);
		#-------------------------------------
		my $table = Gtk2::Table->new (1, 2, FALSE);
		my $label = Gtk2::Label->new_with_mnemonic("_Nom du fichier .xml : ");
		$label->set_alignment(1,0.5);
		$table->attach_defaults ($label, 0, 1, 0,1);
		my $entreeoutput = Gtk2::Entry->new();
		$entreeoutput->signal_connect (changed => sub
		{
			# Grise le bouton de validation si la zone de texte est vide
			$text = $entreeoutput->get_text;
			$windowoutput->set_response_sensitive ('accept', $text !~ m/^\s*$/);
		});
		
		$label->set_mnemonic_widget ($entreeoutput);
		$table->attach_defaults($entreeoutput,1,2,0,1);
		#---------------------------------------
		$vbox->pack_start($table,0,0,4);
		$windowoutput->signal_connect(response => sub 
		{
			#if the person clicked save, we show a message
			if($_[1] =~ m/accept/)
			{
				$output = $entreeoutput->get_text();
				Gtk2->main_quit();
			}
		});
		$vbox->show_all();
		return $vbox;
	}
	return $output;
}
