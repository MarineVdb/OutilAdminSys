#!/usr/bin/perl
use File::Copy;
#Traiter mdp (-p) , path ( -c ), shell ( -s ) dry-run ( -n )


$login=shift;
$change=0;

if(@ARGV[0] eq "--dry-run" || @ARGV[0] eq "-n"){
	shift;
	$change=1;
	print "Dry run !\n";
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
	$pw= qx/ mkpasswd -m md5 '$newPw' /;
	chomp($pw);
	if($change == 0){
		#qx / usermod -p '$pw' $login /;
		
		open(SHADOW,"/etc/shadow")|| die("shadow inexistant ou inaccessible");
		open(SHADOWTMP,">shadow")|| die("création du fichier temporaire impossible");
		while(<SHADOW>){
			if(/$login:[^:]*:(.*)/){
				$ligne= "$login:$pw:$1";
				chomp($ligne);
				print SHADOWTMP "$ligne\n";
			}else{
				$ligne=$_;
				chomp($ligne);
				print SHADOWTMP "$ligne\n";
			}
		}
		close(SHADOWTMP);
		close(SHADOW);
		qx / chmod 644 shadow /;
		qx / mv shadow \/etc\/shadow /;
	}else{
		print "New password for $login: $newPw\n";
	}
	
}

sub changePath(){
	if($change == 0){
		#qx / usermod -m -d $newPath $login /;
		open(PASSWD,"/etc/passwd")||die("passwd inexistant ou inaccessible");
		open(PASSWDTMP,">passwd")||die("création du fichier temporaire impossible");
		while(<PASSWD>){
			if(/$login:([^:]*:[^:]*:[^:]*:[^:]*):([^:]*):([^:]*)/){
				$ligne= "$login:$1:$newPath:$3";
				$oldPath=$2;
				chomp($oldPath);
				chomp($ligne);
				print PASSWDTMP "$ligne\n";
				
			}else{
				$ligne = $_;
				chomp($ligne);
				print PASSWDTMP "$ligne\n";
			}
		}
	
		close(PASSWDTMP);
		close(PASSWD);
		qx / chmod 644 passwd /;
		qx / mv passwd \/etc\/passwd /;	

		mkdir $newPath;
		qx / cp -r $oldPath\/* $newPath /;
		qx / rm -rf $oldPath /;
		
	}else{
		print "New path for $login:  $newPath\n";
	}
}

sub changeShell(){
	
	if($change == 0){
		#qx / usermod -s $newShell $login /;

		open(PASSWD,"/etc/passwd")||die("passwd inexistant ou inaccessible");
		open(PASSWDTMP,">passwd")||die("création du fichier temporaire impossible");
		while(<PASSWD>){
			if(/$login:(.*):.*$/){
				$ligne="$login:$1:$newShell";
				chomp($ligne);
				print PASSWDTMP "$ligne\n";
			}else{
				$ligne=$_;
				chomp($ligne);
				print PASSWDTMP "$ligne\n";
			}
		}
		close(PASSWDTMP);
		close(PASSWD);
		qx / chmod 644 passwd /;
		qx / mv passwd \/etc\/passwd /;
	}else{
		print "New shell for $login: $newShell\n";
	}
}

