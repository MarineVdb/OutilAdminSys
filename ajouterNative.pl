#!/usr/bin/perl

########################
## Gestion de l'utf-8 ##
########################

use encoding 'utf8';
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

	#Création du chemin de l'utilisateur
	$cheminLogin = "/home/user/$login";
	chomp($cheminLogin);
	
	if($description == 1){
		print "Création du groupe : $login\n";
		print "Création de l'utilisateur : $login\n";
		print "Son mot de passe sera : $pass\n\n";
		print "Création du répertoire : $cheminLogin\n";
	}else{
		#Déclaration du début des UID et GID
		$uidDebut = 1000;
		$gidFinal = 1000;

		#Recheche du GID final
		open(GROUP, "/etc/group") || die("Ouverture du fichier group impossible");
		while(<GROUP>) {
			$ligne = $_;
			chomp($ligne);
			$gid = `echo $ligne | cut -d : -f 3`;
			chomp $gid;
			if($gid >= $gidfinal && $gid != 65534) {
				$gidFinal = $gid + 1;
			}
		}
		close(GROUP); 

		#Recheche du UID final
		open PASSWD, "/etc/passwd" || die("Ouverture du fichier passwd impossible");
		while(<PASSWD>) { 
			$ligne = $_;
			$ligne =~ s/\(//g;
			$ligne =~ s/\)//g;
			chomp($ligne); 
			$uid = `echo $ligne | cut -d : -f 3`;
			chomp $gid;
			if($uid >= $uidFinal && $uid != 65534) {
				$uidFinal = $uid + 1;
			}
		}
		close(PASSWD); 

		#Ajout de l'utilisateur au groupe USER
		open(GROUP, "/etc/group") || die("Ouverture du fichier /etc/group impossible");
		open(GR, ">group") || die("ouverture du fichier local group impossible");
		while(<GROUP>) {
			chomp;
			if($_ =~ /^(user:)/) {
				print GR $_;
				if($_ !~ /(:)$/) {
					print GR ",";
				}
				print GR "$login\n";
			} else {
				print GR $_."\n";
			}
		}
		close (GROUP);
		close (GR);

		qx/ chmod 644 group /; #Modificaion des droit du fichier
		qx/ mv group \/etc\/group /; #On remplace le vrai par le temporaire

		#Ajout du groupe au nom de l'utilisateur au fichier /etc/group
		open(GROUP, ">>/etc/group") || die("Ouverture du fichier /etc/group impossible");
			print GROUP "$login:x:$gidFinal:$login\n";
		close (GROUP);
		print "$login:x:$gidFinal:$login\n";

		#Ajout de l'utilisateur au fichier /etc/passwd
		open(PASSWD, ">>/etc/passwd") || die("Ouverture du fichier /etc/passwd impossible");
			print PASSWD "$login:x:$uidFinal:$gidFinal: :$cheminLogin:/bin/bash\n";
		close(PASSWD);
		print "$login:x:$uidFinal:$gidFinal: :$cheminLogin:/bin/bash\n";

		#Ajout du mot de passe de l'utilisateur au fichier /etc/shadow
		open(SHADOW, ">>/etc/shadow") || die("Ouverture du fichier /etc/shadow impossible");
			print SHADOW "$login:$crypt_pass:16093:0:99999:7:::\n";
		close(SHADOW);
		print "$login:$crypt_pass:16093:0:99999:7:::\n";
		print "$login $pass\n";

		#Création des répertoire dédié ) l'utilisateur
		qx / mkdir -p $cheminLogin /;
        mkdir "$cheminLogin/Bureau";
        mkdir "$cheminLogin/Documents";
        mkdir "$cheminLogin/Documents/Ma Musique";
        mkdir "$cheminLogin/Public";
        mkdir "$cheminLogin/Téléchargements";
        print "Le répertoire a été créé.\n";

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
