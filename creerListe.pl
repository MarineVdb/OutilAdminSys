#!/usr/bin/perl

#Création d'un dossier skelette type
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

#Lecture de la ligne/du fichier
while(<>) {
        chomp;
        ($nom, $prenom)= split(' ', $_);
        creer($nom, $prenom);
}


####################################
## Fonction de création d'un user ##
####################################


sub creer {
        $login                = lc( substr($nom, 0, 7) . substr($prenom, 0, 1) );
        
        #On vérifie que la personne n'existe pas déjà, 
        #si c'est le cas chiffre après son login
        $i                         = 1;
        opendir (DIR, '/home/user');
        while (readdir(DIR)) {
                if($_ eq $login) {
                        $i++;
                }
        }
        $login                 .= $i         if($i != 1);
        
        #On ajoue un groupe au nom du login
        qx/ groupadd $login /;
        
        #Création du mot de passe aléatoire
        $pass                = qx/ pwgen -sA1 8 /;
        chomp $pass;

        #Cryptage du mot de passe
        $crypt_pass = qx/ mkpasswd -m md5 $pass /;
        chomp $crypt_pass;

        #Ajout de l'utilisateur
        qx/ useradd $login -p '$crypt_pass' -g $login -G $login,user -d \/home\/user\/$login -k \/home\/skel -m -s \/bin\/bash /;

        #Ajout du login + mdp de la personne ajoutée
        open(LOG, ">>log");
        print LOG "$login;$pass\n";
        close(LOG);
}