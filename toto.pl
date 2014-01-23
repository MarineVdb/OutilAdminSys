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

print $gidFinal."\n";

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

print $uidFinal."\n";

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

qx/ chmod 644 group /;
qx/ mv group \/etc\/group /;

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

