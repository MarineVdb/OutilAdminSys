#!/usr/bin/perl

#Traiter mdp (-p) , path ( -c ), shell ( -s )
#usermod


$login=shift;
$change=0;

if(@ARGV[0] eq "--dry-run" || @ARGV[0] eq "-n"){
	shift;
	$change=1;
}

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
	if($change == 0){
		qx / usermod -p '$pw' $login /;
	}
	
}

sub changePath(){
	print "New path for $login:  $newPath\n";
	if($change == 0){
		qx / usermod -m -d $newPath $login /;
	}
}

sub changeShell(){
	print "New shell for $login: $newShell\n";
	if($change == 0){
		qx / usermod -s $newShell $login /;
	}
}


