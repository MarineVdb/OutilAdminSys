#!/usr/bin/perl

########################
## Gestion de l'utf-8 ##
########################

use encoding 'utf-8';
use Unicode::Normalize;

####################################
## Lecture de la ligne/du fichier ##
####################################

$mode=shift; # -sys/-nat

if(@ARGV[0] eq "-n" || @ARGV[0] eq "--dry-run"){
	$description = 1;
	shift;
}

while(<>) {
        chomp;
        #($nom, $prenom)= split(' ', $_);
		if($mode eq "-sys"){
        	supprimer($1) if(/(.*)/);
		}else{
			supprimerNat($1) if(/(.*)/);
		}
}

######################################
## Fonction de supression d'un user ##
######################################

sub supprimer {
	$login = shift;
	next if($login eq "");
	
	$login = caractereSpecial($login);

    $loginRetour = verification($login);
    chomp($loginRetour);
    $login = $loginRetour; 
	
	if($login eq "error") {
        print "le login n'existe pas\n"; next;
    }

    $cheminLogin = "/home/user/$login/";    
        
	if($description == 1) {
		print "Suppression de $login du groupe user \n";
		print "Suppression de l'utilisateur : $login \n";
		print "Suppression du répertoire : $cheminLogin\n\n";
	} else {
		#On supprime le login de user
    	qx/ delgroup $login user /;
    
    	#On supprime l'utilisateur
    	qx/ deluser $login /;

    	#On supprime l'intérieur du fichier
    	`rm -rf $cheminLogin`;

    	#On envoie en paramètre le login qui va être supprime du fichier log
   		triListe($login);
    	print "Le login $login n'existe plus, ainsi que son répertoire.\n";
	}
}

##############################
## Fonction de vérification ##
##############################

sub verification {
    $login = shift;

    $nombreDeLigne = `getent group | cut -d : -f 1 | grep -w $login | wc -l`;
    chomp($nombreDeLigne);
    
    if ($nombreDeLigne == 1) {
        return $login;
    }else{
        return "error";
    }
}

##########################################################
## Fonction de supression d'un user dans le fichier log ##
##########################################################

sub triListe {
        #Création du fichier log2 et ouverture du fichier log
        open(LOG2, ">>log2") || die ("impossible d'ourir le fichier LOG. \n");
        open(LOG, "log") || die ("Fichier LOG inexistant. \n");
                while (my $ligne = <LOG>){
                        #Si le début de la ligne ne correspond pas au login de la personne que l'on supprime
                        #On l'ajoute au fichier lg2
                        if ($ligne !~ /^$login;/){ 
                               print LOG2 $ligne;
                        }
                } 
        close(LOG); 
        close(LOG2);

        #On supprime l'ancien log pour en ouvrir un autre
        `rm log`; 
        #On modifie l'ancien fichier en le nouveau !
        `mv log2 log`;
}

#####################################
## Gestion des caractères spéciaux ##
#####################################

sub caractereSpecial {
	$mot = shift;
	$mot = NFKD($mot); #Normalisation du mot
	$mot =~ s/\p{NonspacingMark}//g; #Suppression des caractères spéciaux
	$mot =~ y/àâäçéèêëîïôöùûü/aaaceeeeiioouuu/; #Suppression des accents
	$mot =~ s/\ //g; #Suppression des espaces
	return $mot;
}


#NATIF

sub supprimerNat{
	$login = shift;
	next if($login eq "");
	
	$login = caractereSpecial($login);

    $loginRetour = verification($login);
    chomp($loginRetour);
    $login = $loginRetour; 
	
	if($login eq "error") {
        print "le login n'existe pas\n"; next;
    }

    $cheminLogin = "/home/user/$login/";    
        
	if($description == 1) {
		print "Suppression de $login du groupe user \n";
		print "Suppression de l'utilisateur : $login \n";
		print "Suppression du répertoire : $cheminLogin\n\n";
	} else {
		#On supprime le login de user
    	# qx/ delgroup $login user /;
        suppGroupNat($login);
    
    	#On supprime l'utilisateur
    	# qx/ deluser $login /;
        suppUserNat($login);

    	#On supprime l'intérieur du fichier
    	`rm -rf $cheminLogin`;

    	#On envoie en paramètre le login qui va être supprime du fichier log
   		triListe($login);
    	print "Le login $login n'existe plus, ainsi que son répertoire.\n";
	}
}

sub suppGroupNat {
    $login = shift;
    
    open(GROUP, "/etc/group") || die("Ouverture du fichier /etc/group impossible");
    open(GR, ">group") || die("ouverture du fichier local group impossible");
    while(<GROUP>) {
        chomp;
        if($_ =~ /^(user)(.*)(:)$login,(.+)/) {
            print GR $1.$2.$3.$4."\n";
        } elsif($_ =~ /^(user)(.*)(,)$login(.*)/) {
            print GR $1.$2.$4."\n";
        } elsif($_ =~ /^(user)(.*)($login)/) {
            print GR $1.$2."\n";
        } elsif($_ !~ /^($login)/) {
            print GR $_."\n";
        }
    }
    close(GROUP);
    close(GR);

    qx/ chmod 644 group /;
    qx/ mv group \/etc\/ /;
}



sub suppUserNat {
    $login = shift;
    
    open(PASS, "/etc/passwd") || die("Ouverture du fichier /etc/passwd impossible");
    open(PS, ">passwd") || die("ouverture du fichier local passwd impossible");
    while(<PASS>) {
        chomp;
        if($_ !~ /^($login)/) {
            print PS $_."\n";
        }
    }
    close(PASS);
    close(PS);

    qx/ chmod 644 passwd /;
    qx/ mv passwd \/etc\/ /;
    
    open(SHAD, "/etc/shadow") || die("Ouverture du fichier /etc/shadow impossible");
    open(SH, ">shadow") || die("ouverture du fichier local shadow impossible");
    while(<SHAD>) {
        chomp;
        if($_ !~ /^($login)/) {
            print SH $_."\n";
        }
    }
    close(SHAD);
    close(SH);

    qx/ chmod 640 shadow /;
    qx/ mv shadow \/etc\/ /;
}

