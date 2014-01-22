#!/usr/bin/perl

########################
## Gestion de l'utf-8 ##
########################

use encoding 'utf-8';
use Unicode::Normalize;

####################################
## Lecture de la ligne/du fichier ##
####################################

while(<>) {
        chomp;
        #($nom, $prenom)= split(' ', $_);
        supprimer($1) if(/(.*)/);
}

######################################
## Fonction de supression d'un user ##
######################################

sub supprimer {
	$login = shift;
	
	$login = caractereSpecial($login);

        $loginRetour = verification($login);
        chomp($loginRetour);
        $login = $loginRetour; 
	
	if($login eq "error") { next }

        $cheminLogin          = "/home/user/$login/";    
        
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
