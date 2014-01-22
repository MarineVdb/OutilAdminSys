#!/usr/bin/perl

$uidDebut = 1000;
$gidFinal = 1000;
$login = "vandenbs";
chomp ($login);
$cheminLogin = "/home/user/$login";
chomp($cheminLogin);

#Création du mot de passe aléatoire
$pass = qx / pwgen -sA1 8 /;
chomp $pass;

#Cryptage du mot de passe
$crypt_pass = qx / mkpasswd -m md5 $pass /;
chomp $crypt_pass;


open(GROUP, "/etc/group") || die("Ouverture du fichier group impossible");
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

print $gidFinal."\n";

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

		print $uidFinal."\n";

open(GROUP, ">>/etc/group") || die("Ouverture du fichier /etc/group impossible");
while(<GROUP>){
	$ligne = $_; 
	chomp($ligne);
	if($ligne =~ /user:/){
		print GROUP "$ligne,$login\n";
	}else{
		print GROUP "$ligne\n";
	}
}
close (GROUP);

print "modifier\n";

#open(GROUP, ">>/etc/group") || die("Ouverture du fichier /etc/group impossible");
#	print GROUP "$login:x:$gidFinal:$login\n";
#close (GROUP);
#	print "$login:x:$gidFinal:$login\n";

#open(PASSWD, ">>/etc/passwd") || die("Ouverture du fichier /etc/passwd impossible");
#	print PASSWD "$login:x:$uidFinal:$gidFinal: :$cheminLogin:/bin/bash\n";
#close(PASSWD);
#	print "$login:x:$uidFinal:$gidFinal: :$cheminLogin:/bin/bash\n";

#open(SHADOW, ">>/etc/shadow") || die("Ouverture du fichier /etc/shadow impossible");
#	print SHADOW "$login:$crypt_pass:16092:0:99999:7:::\n";
#close(SHADOW);
#	print "$login:$crypt_pass:16092:0:99999:7:::\n";
#	print "$login $pass\n";

