#!/usr/bin/perl

$login=shift;

#Parcourt des parametres
while(scalar @ARGV>0){
	print "$_\n";
	if(@ARGV[0] eq "-p"){#Changement du password
		shift;
		$newPw=@ARGV[0]; #on recupere le nouveau mdp
		changePw();
	}
	elsif(@ARGV[0] eq "-c"){#Changement du path
		shift;
		$newPath=@ARGV[0];#on recupere le nouveau path
		changePath();
	}
	elsif(@ARGV[0] eq "-s"){#Changement du shell
		shift;
		$newShell=@ARGV[0];#on recupere le nouveau Shell
		changeShell();
	}
	shift;
}

sub changePw(){
	print "New password for $login: $newPw\n";
	$pw= qx/ mkpasswd -m md5 '$newPw' /;
	chomp($pw);
	modifierListe($login, $newPw);
	qx / usermod -p '$pw' $login /;
}

sub changePath(){
	print "New path for $login:  $newPath\n";
	qx / usermod -m -d $newPath $login /;
}

sub changeShell(){
	print "New shell for $login: $newShell\n";
	qx / usermod -s $newShell $login /;
}

sub modifierListe() {
	$login = shift;
	$mdp = shift;
	#Création du fichier log2 et ouverture du fichier log
    open(LOG2, ">>log2") || die ("impossible d'ourir le fichier LOG. \n");
    open(LOG, "log") || die ("Fichier LOG inexistant. \n");
            while (my $ligne = <LOG>){
                    #Si le début de la ligne ne correspond pas au login de la personne que l'on supprime
                    #On l'ajoute au fichier lg2
                    if ($ligne =~ /^$login;/){ 
                           print LOG2 "$login;$mdp";
                    }
            } 
    close(LOG); 
    close(LOG2);

    #On supprime l'ancien log pour en ouvrir un autre
    `rm log`; 
    #On modifie l'ancien fichier en le nouveau !
    `mv log2 log`;
}


