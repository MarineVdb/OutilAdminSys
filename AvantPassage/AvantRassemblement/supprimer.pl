#!/usr/bin/perl

########################
## Gestion de l'utf-8 ##
########################

use encoding 'utf-8';
use Unicode::Normalize;

####################################
## Lecture de la ligne/du fichier ##
####################################

if(@ARGV[0] eq "-n" || @ARGV[0] eq "--dry-run"){
	$description = 1;
	shift;
}

while(<>) {
        chomp;
        #($nom, $prenom)= split(' ', $_);
        supprimer($1, $2) if(/(.*)[,;:](.*)/);
}

######################################
## Fonction de supression d'un user ##
######################################

sub supprimer {
	$nom = shift;
	$prenom = shift;
	
	if($nom eq "" || $prenom eq ""){
		print "Il manque le nom ou prenom\n";
		next;
	}	

	$nom = caractereSpecial($nom);
	$prenom = caractereSpecial($prenom);

        $login = lc( substr($nom, 0, 7) . substr($prenom, 0, 1) );

        $loginRetour = verification($login);
        chomp($loginRetour);
        $login = $loginRetour; 
	
	if($login eq "error") { next }

        $cheminLogin          = "/home/user/$login/"; 
        
	if($description == 1){
		print "Suppression du groupe : $login\n";
		print "Suppression de l'utilisateur : $login\n";
		print "Suppression du répertoire : $cheminLogin\n\n";
	}else{
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

    $nombreDeLigne = `getent group | cut -d : -f 1 | grep $login | wc -l`;
    chomp($nombreDeLigne);
    
    $nomRetrouve = `getent group | cut -d : -f 1 | grep $login` if($nombreDeLigne == 1);
    chomp($nomRetrouve);

    if ($nombreDeLigne >= 2) {
        print "Il existe plusieurs login constituant : $login.\n";
        $nom = `getent group | cut -d : -f 1 | grep $login`;
        print $nom;

        print "Lequel voulez vous supprimer : ";
        $loginRetour = <STDIN>; 

        return $loginRetour;

    }elsif($nombreDeLigne == 1 && !($nomRetrouve eq $login)){
	print "Le seul login retrouve avec les caractéristiques donnees est : ". $nomRetrouve;
	print "Est-ce celui-ci que vous souhaitez supprimer ? (oui ou non) ";
	
	$reponse = <STDIN>;
	chomp($reponse);
	
	if($reponse eq "oui"){
		return $nomRetrouve;
	}else{
		return "error";	
	}
    }else{
        return $login;
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
