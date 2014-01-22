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
        #($nom, $prenom) = split(/;/, $_);
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
        $uidFinal = 1000;
		$gidFinal = 1000;

		open(GROUP, ">>/etc/group") || die("Ouverture du fichier group impossible");
		while(<GROUP>){
			$ligne = $_;
			chomp($ligne);
			$gid = `echo $ligne | cut -d : -f 3`;
			chomp $gid;
			while($gid >= $gidFinal && $gid != 65534){
				$gidFinal++;
			}
		}
		close(GROUP);

		open PASSWD, "/etc/passwd" || die("Ouverture du fichier passwd impossible");
		while(<PASSWD>){ 
			$ligne = $_;
			$ligne =~ s/\(//g;
			$ligne =~ s/\)//g;
			chomp($ligne); 
			$uid = `echo $ligne | cut -d : -f 3`;
			chomp $gid;
			while($uid >= $uidFinal && $uid != 65534){
				$uidFinal++;
			}
		}
		close(PASSWD);

    	#Ajout du groupe au nom de l'utilisateur
    	open(GROUP, ">>/etc/group") || die("Ouverture du fichier /etc/group impossible");
			print GROUP "$login:x:$gidFinal:$login\n";
		close (GROUP);
			print "$login:x:$gidFinal:$login\n";

		#Ajout du compte au nom de l'utilisateur
		open(PASSWD, ">>/etc/passwd") || die("Ouverture du fichier /etc/passwd impossible");
			print PASSWD "$login:x:$uidFinal:$gidFinal: :$cheminLogin:/bin/bash\n";
		close(PASSWD);
			print "$login:x:$uidFinal:$gidFinal: :$cheminLogin:/bin/bash\n";

		#Ajout du mot de passe de l'utilisateur
		open(SHADOW, ">>/etc/shadow") || die("Ouverture du fichier /etc/shadow impossible");
			print SHADOW "$login:$crypt_pass:16092:0:99999:7:::\n";
		close(SHADOW);
		
		#Affichage
		print "$login:$crypt_pass:16092:0:99999:7:::\n";
		print "$login $pass\n";

		#Ajout du login au groupe USER
		open(GROUP, ">>/etc/group") || die("Ouverture du fichier /etc/group impossible");
		while(<GROUP>){
			$ligne = $_; 
			chomp($ligne);
			if($ligne =~ /^user\:/){
				print GROUP "$ligne,$login\n";
			}else{
				print GROUP "$ligne\n";
			}
		}
		close (GROUP);

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
