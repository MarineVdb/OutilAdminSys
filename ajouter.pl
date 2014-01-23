#!/usr/bin/perl

########################
## Gestion de l'utf-8 ##
########################

use encoding 'utf8';
use Unicode::Normalize;

#########################################
## Création d'un dossier skelette type ##
#########################################

if (opendir(DIR, skel)) {
        close(DIR);
} else {
        mkdir "/home/skel";
        mkdir "/home/skel/Bureau";
        mkdir "/home/skel/Documents";
        mkdir "/home/skel/Documents/Ma Musique";
        mkdir "/home/skel/Public";
        mkdir "/home/skel/Téléchargements";
}
####################################
## Lecture de la ligne/du fichier ##
####################################

if(@ARGV[0] eq "-n" || @ARGV[0] eq "--dry-run"){
	$description = 1;
	shift;
}

while(<>) {
    chomp;
	creer($1, $2) if(/(.*)[;,:](.*)/);
}


####################################
## Foncti0on de création d'un user ##
####################################


sub creer {
	$nom = shift;
	$prenom = shift;
	
	if($nom eq "" || $prenom eq ""){
		print "Il manque le prenom ou le nom";
		next;
	}	

	$nom = caractereSpecial($nom);
	$prenom = caractereSpecial($prenom);

    $login = lc( substr($nom, 0, 7) . substr($prenom, 0, 1) );
        
    #On regarde le nombre de ligne que contient le login
    $nombreDeLigne = `getent group | cut -d : -f 1 | grep $login | wc -l`;
    chomp($nombreDeLigne);
    $login .= $nombreDeLigne+1 if ($nombreDeLigne >= 1); #Si c'est >= 1 alors on lui ajoute le chiffre
      
	#Création du mot de passe aléatoire
	$pass = qx / pwgen -sA1 8 /;
	chomp $pass;

	#Cryptage du mot de passe
	$crypt_pass = qx / mkpasswd -m md5 $pass /;
	chomp $crypt_pass;
	
	if($description == 1){
		print "Création du groupe : $login\n";
		print "Création de l'utilisateur : $login\n";
		print "Son mot de passe sera : $pass\n\n";
	}else{
		#On ajoute un groupe au nom du login
        qx/ groupadd $login /;

    	#Ajout de l'utilisateur
    	qx/ useradd $login -p '$crypt_pass' -g $login -G $login,user -d \/home\/user\/$login -k \/home\/skel -m -s \/bin\/bash /;

    	#Ajout du login + mdp de la personne ajoutée
   		open(LOG, ">>log");
    		print LOG "$login;$pass\n";
    	close(LOG);
	}
}

#####################################
## Gestion des caractères spéciaux ##
#####################################

sub caractereSpecial {
	$mot = shift;
	$mot = NFKD($mot); #Normalisation du mot
	$mot =~ s/\p{NonspacingMark}//g; #Suppression des caractères spéciaux
	$mot =~ y/àâäçéèêëîïôöùûü/aaaceeeeiioouuu/; #Suppression des accents
	$mot =~ s/\ //g; #Suppression des espaces
	return $mot;
}
