#!/usr/bin/env perl

# ProfVisitoR Version 0.27

#no warnings 'experimental::re_strict';
#use re 'strict';
#use strict;
use warnings;
use utf8;

if ($^O eq "MSWin32") {
    binmode STDOUT, ':encoding(cp866)';
} else {
    binmode STDOUT, ':encoding(UTF-8)';
}

##################################################
############ Interesting filesets ################
##################################################
my $copypaste = "EMC.CLARiiON.aix.rte
EMC.CLARiiON.fcp.MPIO.rte
EMC.CLARiiON.fcp.rte
EMC.CLARiiON.ha.rte
EMC.CLARiiON.iscsi.rte
EMC.INVISTA.aix.rte
EMC.INVISTA.fcp.rte
EMC.Symmetrix.aix.rte
EMC.Symmetrix.fcp.MPIO.rte
EMC.Symmetrix.fcp.PowerMPIO.rte
EMC.Symmetrix.fcp.rte
EMC.Symmetrix.ha.rte
EMC.Symmetrix.iscsi.rte
HP.aix.support.rte
Hitachi.aix.support.rte";
@odm=split("\n",$copypaste);

my $copypaste2 = "VRTSvcs
VRTSvxfs
VRTSvxvm";
@vrts=split("\n",$copypaste2);

my $copypaste3 = "DLManager.mpio.rte
EMCpower.base";
@multipath=split("\n",$copypaste3);

##################################################
##	Main program
##################################################

$dir="./snap";

# GLOBALS
$recom_dump_small=0; #

snap_header($dir);
snap_mcode($dir);
snap_oslevel($dir);
snap_dumpdev($dir);
snap_kernel($dir);
snap_kernel_no($dir);
snap_jfs($dir);
snap_vxfs($dir);
snap_soft($dir);
snap_errpt($dir);
snap_physical_res($dir);
snap_hdisk($dir);
snap_rmt($dir);
snap_recommendations($dir);

if ($^O eq "MSWin32") {
    $win = <STDIN>;
}

##################################################
##	End of main program
##################################################

sub snap_header
{
	my $type;
	my $sn;
	#my $firm;
	$filedump = "@_/general/general.snap";
	open($fd, '<:encoding(UTF-8)', $filedump)
	  or print "WARNING: could not open file '$filedump' $!\n";
	while ($row = <$fd>) {
	  chomp $row;
	  # if( unpack("x0 A12",$row) eq "sys0!system:"){
	  #   $firm=substr($row,12);
	  # }
	  if($row eq "      System VPD:"){
	  my $ct=0;
	    while($ct<=6){
	    if($ct==5) {$sn=substr($row,36)};
	    if($ct==6) {$type=substr($row,36)};
	    do {$row = <$fd>};
		$ct++;

	    }
	  }
	}
	chomp $sn;
	chomp $type;
	@type_model=split('-',$type);

	print "### Отчет по диагностике сервера $type SN-$sn\n\n";
	print "#### 1.Обзор аппаратных компонентов машины и окружения\n\n";
	print "|Тип|Модель|Серийный номер|\n";
	print "|:-:|:-:|:-:|\n";
	print "|$type_model[0]|$type_model[1]|$sn|\n";
	print "\n|Статус компонентов|Температура|Влажность|\n";
	print "|:-:|:-:|:-:|\n";
	print "|норма|норма|норма|\n";
}
sub snap_mcode
{
	open($general, '<:encoding(UTF-8)', "@_/general/general.snap")
	or print "WARNING: could not open file ./general/general.snap $!\n";
	while ($row = <$general>) {
	    if($row =~ /^sys0!system:/){
	     chomp $row;
	     @mcod = split (":",$row);
	     @mcode = split (" ",$mcod[1]);
	     last;
	    }
	}
	close $general;

	open($mcode_flrt, '<:encoding(UTF-8)', "./mcode.flrt")
	or print "WARNING: could not open file ./mcode.flrt $!\n";
	while ($row = <$mcode_flrt>) {
	    chomp $row;
	    my @arr=split(":",$row);
	    if($arr[0] eq $mcode[0]){
	        print "\n##### Версия микрокода и ОС\n\n";
	        print "|Установленная (T)|Установленная (P)|Загруженная (IPL)|Рекомендованный апдейт|Рекомендованный апгрейд|\n|:-:|:-:|:-:|:-:|:-:|\n";
	        print "|", $mcode[0], "|", $mcode[2], "|", $mcode[4],"|",$arr[2],"|",$arr[3],"|\n";
	        last;
	    }
	}
	close $mcode_flrt;
}
sub snap_physical_res
{
	print "\nФизические ресурсы \n";
	print "\nEthernet адаптеры\n\n";
	print "|Адаптер|Location|Тип|Part Number|FRU|\n|:-:|:-:|:-:|:-:|:-:|\n";
	open($general, '<:encoding(UTF-8)', "@_/general/general.snap")
	or print "WARNING: could not open file @_/general/general.snap $!\n";
	while ($row = <$general>) {
		chomp $row;
 		#next unless length($row);
 		if($row =~ /^\s\sent/){
			$row =~ s/\s+$//;
			$row =~ s/^\s+//;
			my @arr_tmp=split(/\s{4,}/,$row);
			push(@arr_ent,[$arr_tmp[0],$arr_tmp[1],$arr_tmp[2]]);
			#$i=readline <>;
			#print $i;
		};
	}
	$i = 0;
	while ($i <= $#arr_ent) {
		print "|$arr_ent[$i][0]|$arr_ent[$i][1]|$arr_ent[$i][2]|||\n";
		$i++;
	}
	close $general;

	print "\nFC адаптеры\n\n";
	print "|Адаптер|Location|Тип|\n|:-:|:-:|:-:|\n";
	open($general, '<:encoding(UTF-8)', "@_/general/general.snap")
	or print "WARNING: could not open file @_/general/general.snap $!\n";
	while ($row = <$general>) {
		chomp $row;
 		#next unless length($row);
 		if($row =~ /^\s\sfcs/){
			$row =~ s/\s+$//;
			$row =~ s/^\s+//;
			my @arr_tmp=split(/\s{4,}/,$row);
			push(@arr_fcs,[$arr_tmp[0],$arr_tmp[1],$arr_tmp[2]]);

		};
	}
	$i = 0;
	while ($i <= $#arr_fcs) {
		print "|$arr_fcs[$i][0]|$arr_fcs[$i][1]|$arr_fcs[$i][2]|\n";
		$i++;
	}
	close $general;
}
sub snap_oslevel
{
	open(my $oslevel, '<:encoding(UTF-8)', "@_/general/oslevel.info")
	or print "WARNING: could not open file @_/general/oslevel.info $!\n";
	$ver = <$oslevel>; #throw away
	$ver = <$oslevel>;
	chomp($ver);
	$version = substr($ver,0,10);
	close $oslevel;

	open(my $aix_flrt, '<:encoding(UTF-8)', "./aix.flrt");
	while ($row = <$aix_flrt>) {
	    chomp $row;
	    my @arr=split(":",$row);
	    if($arr[0] eq $version){
	        print "\n";
	        print "Текущая версия операционной системы: $version  \n";
	        print "Рекомендуемый апдейт  (SP)    : $arr[1]  \n";
	        print "Рекомендуемый апгрейд (TL+SP) : $arr[2]  \n";
	        last;
	    }
	}
	close $aix_flrt;
}
sub snap_dumpdev
{
	my $l=0;
	my %th=('byte'=>'1',
	'kilobyte'=>'1024',
	'megabyte'=>'1048576',
	'gigabyte'=>'1073741824');
	print "\n";
	print "##### Устройство системного дампа\n\n";
	$filedump = "@_/general/survdump.settings";
	open($fd, '<:encoding(ISO-8859-1)', $filedump)
	  or print "WARNING: could not open file '$filedump' $!\n";
	$dmp_es=0;
	while (my $row = <$fd> || $dmp_es==0) {
	  if (unpack("x0 A21",$row) eq "primary" || unpack("x0 A21",$row) eq "secondary" || unpack("x0 A21",$row) eq "copy directory" || unpack("x0 A21",$row) eq "forced copy flag" || unpack("x0 A21",$row) eq "always allow dump" || unpack("x0 A21",$row) eq "dump compression" || unpack("x0 A21",$row) eq "type of dump")
	  {
	    chomp $row;
	    print "$row  \n";
 	  }
	  if (unpack("x0 A29",$row) eq "Estimated dump size in bytes:")
	  {
	    #print "\n",$row;
	    $dmp_es=substr($row,30);
	    chomp $dmp_es;
	    print "\n| |байт|";
	    print "\n|:-:|:-:|";
	    print "\n|Ожидаемый размер системного дампа:|$dmp_es|\n";
	  }
	}
	close $fd;
	$filedump = "@_/lvm/rootvg.snap";
	open($fd, '<:encoding(ISO-8859-1)', $filedump)
	  or print "WARNING: could not open file '$filedump' $!\n";
	while($l<7){
	  do {$row = <$fd>};
	  $l++;
	}
	my $size_str=substr($row,61);
	my $orig_size;
	my $dmpflag=0;
	while($size_str=~ /(\w+)\s/g){$orig_size=$1;}
	while($size_str=~ /\s(\w+)/g){$dmp_size=$orig_size*$th{$1};}
	while ($row = <$fd>) {
	  if (unpack("x0 A7",$row) eq "rootvg:")
	  {
	    do {$row = <$fd>};
	    while (unpack("x0 A5",$row) ne "") {
	      if(unpack("x20 A7",$row) eq "sysdump"){
	            $l=0;
	            $dmpflag=1;
	            while($row=~ /(\w+)\s/g)
	            {
	              $str[$l]=$1;
	              $l++;
	            }
	            my $dumplv_name=unpack("x0 A20",$row);
	      }
	     do {$row = <$fd>};
	    }
	  }
	}
	close $fd;
	if ($dmpflag==1){
		chomp($size_str);
		print "|Размер первичного устройства системного дампа:|",$dmp_size*$str[2],"|\n";
		#$recom_dump_small=0;
		if ($dmp_es > ($dmp_size*$str[2])) {
		$recom_dump_small=1
	  }
	}
}
sub snap_jfs
{
	my $inputfname=$_[0];
	my @arr_vg;
	my @arr_fstr;
	my $row;
	my $temp_gr_name;
	my $vgct=0;
	my $i1;
	my $pv;
	my $ffrow;
	my $arrct;
	my $spc;
	my $ius;
	my $curvgct;
	my $stop;
	my $filedump = "@_/lvm/lvm.snap";
	open(my $fd, '<:encoding(ISO-8859-1)', $filedump)
	  or print "WARNING: could not open file '$filedump' $!\n";
	while ($row = <$fd>) {
	  chomp $row;
	  if ($row eq ".....    lsvg -o" && $vgct==0)
	  {
	    #print "\n",$row,"\n";
	    print "\n##### AIX LVM\n";
	    do {$row = <$fd>}; do {$row = <$fd>}; do {$row = <$fd>};
	    while($row ne "\n"){
	      chomp $row;
	      #print $row,"\n";
	      $arr_vg[$vgct]=$row;
	      $vgct++;
	      do {$row = <$fd>};
	    }
	  }
	}
	close $fd;
	print "\n";
	for($i1=0; $i1<$vgct; $i1++){
	  $curvgct=0;
	  $temp_gr_name="@_/lvm/".$arr_vg[$i1].".snap";
	  open(my $fd, '<:encoding(ISO-8859-1)', $temp_gr_name)
	    or print "WARNING: could not open file '$temp_gr_name' $!\n";
	  while ($row = <$fd>) {
	      chomp $row;
	      if ($row eq $arr_vg[$i1].":" && $curvgct==0){
	        $curvgct++;
	        print $row,"\n\n";
	        print "|Имя тома|Точка монтирования|Статус|Кол-во копий|Резервирование на уровне LVM|Тип|Используется|Используется inode|\n|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|\n";
	        do {$row = <$fd>}; do {$row = <$fd>};
	        while ($row ne "\n"){
	          chomp $row;
	          @arr_fstr=split(" ",$row);
			  $arrct=$#arr_fstr;
#			  print $arrct;
			  if($arrct<6){
				my $i2;
				for($i2=5; $i2>1; $i2--)
				{
					$arr_fstr[$i2+1]=$arr_fstr[$i2];
				}
				$arr_fstr[1]="none";
			  }
	          my @stat=split("/",$arr_fstr[5]);
	         #**************** inode + fsys size *********************
	         open(my $ff, '<:encoding(ISO-8859-1)', "@_/filesys/filesys.snap")
	            or print "WARNING: could not open file /snap/filesys/filesys.snap $!\n";
	          while ($ffrow = <$ff>) {
	            chomp $ffrow;
	            $stop=0;
	              if($ffrow eq ".....    df -k"){
	              do {$ffrow = <$ff>}; do {$ffrow = <$ff>};  do {$ffrow = <$ff>};
	              while($ffrow ne "\n"){
	                do {$ffrow = <$ff>};
	                my @arr_ffrow=split(" ",$ffrow);
	                $arrct=$#arr_ffrow;
	                if($arrct>=6){
	                  if($arr_ffrow[6] eq $arr_fstr[6]){
	                    $spc=$arr_ffrow[3];
	                    $ius=$arr_ffrow[5];
	                    $arr_fstr[7]=$arr_ffrow[3];
	                    $arr_fstr[8]=$arr_ffrow[5];
	                    $stop=1;
	                    }
	                    elsif($stop!=1){
	                      $arr_fstr[7]="";
	                      $arr_fstr[8]="";
	                    }
	                  }
	                }
	              }
	            }
	          close $ff;
	          if($arr_fstr[3]/$arr_fstr[2]>1) {$pv="Yes"} else {$pv="No"};
	          print "|",$arr_fstr[0],"|",$arr_fstr[6],"|",$stat[1],"|",$arr_fstr[3]/$arr_fstr[2],"|",$pv,"|",$arr_fstr[1],"|",$arr_fstr[7],"|",$arr_fstr[8],"|\n";
	          do {$row = <$fd>};
	        }
	        print "\n";
	      }
	  }
	}
}
sub snap_vxfs
{
	my @arr_fs;
	my @arr_tmpdg;
	my @arr_vxdg;
	my @arr_resfs;
	my $row;
	my $vxct=0;
	my $i;
	my $ii;
	my $searchun;
	undef my @arr_un_vxdg;
	open(my $ff, '<:encoding(ISO-8859-1)', "@_/filesys/filesys.snap")
	or print "WARNING: could not open file @_/filesys/filesys.snap $!\n";
	while ($row = <$ff>) {
	  chomp $row;
	  if($row eq ".....    df -k" && $vxct==0){
	    do {$row = <$ff>}; do {$row = <$ff>};  do {$row = <$ff>};
	    while($row ne "\n"){
	      do {$row = <$ff>};
	      my @arr_fs=split(" ",$row);
	      if($#arr_fs>=6){
	        if(unpack("x0 A7",$arr_fs[0]) eq "/dev/vx"){
	          @arr_tmpdg=split("/",$arr_fs[0]);
	          push(@arr_resfs,[$arr_fs[0],$arr_tmpdg[4],$arr_tmpdg[5],$arr_fs[3],$arr_fs[5],$arr_fs[6]]);
	          $vxct++;
	          @arr_tmpdg=split("/",$arr_fs[0]);
		  for($i=0; $i<$vxct;$i++){
		    $searchun=0;
		    if($#arr_un_vxdg>=0){
		      for($ii=0;$ii<=$#arr_un_vxdg;$ii++){
		        if($arr_tmpdg[4] eq $arr_un_vxdg[$ii]){
			  $searchun=1;
		        }
		      }
		    }
		    else{
		      push @arr_un_vxdg, $arr_tmpdg[4];
		      $searchun=1;
		    }
		    if($searchun==0){
		      push @arr_un_vxdg, $arr_tmpdg[4];
		    }
		  }
	        }
	      }
	    }
	  }
	  if($row eq ".....    mount" && $vxct>0){
	    do {$row = <$ff>}; do {$row = <$ff>};  do {$row = <$ff>};  do {$row = <$ff>};
	    while($row ne "\n"){
	      do {$row = <$ff>};
	      my @arr_fs=split(" ",$row);
	      if($#arr_fs>=6){
	        for($i=0;$i<$vxct;$i++){
	          if($arr_fs[0] eq $arr_resfs[$i][0]){
	            $arr_resfs[$i][6]=$arr_fs[2];
	          }
	        }
	      }
	    }
	  }
	}
	close $ff;
	#close $fin;
	my $counter = 0;
	print "\n##### Veritas Volume Manager\n\n|Имя тома|Точка монтирования|Тип|Используется|Используется inode|\n|:-:|:-:|:-:|:-:|:-:|\n";
	for($ii=0;$ii<=$#arr_un_vxdg;$ii++){
	#  print $arr_un_vxdg[$ii],"\n";
		for ($i=0;$i<$vxct;$i++){
			if($arr_un_vxdg[$ii] eq $arr_resfs[$i][1]){
				print "|",$arr_resfs[$i][0],"|",$arr_resfs[$i][5],"|",$arr_resfs[$i][6],"|",$arr_resfs[$i][3],"|",$arr_resfs[$i][4],"|\n";
				$counter++;
	    }
	  }
	}
	if ($counter == 0){print "|none|none|none|none|none|\n"};
}
sub snap_kernel
{
	open($general, '<:encoding(UTF-8)', "@_/kernel/kernel.snap")
	or print "WARNING: could not open file @_/kernel/kernel.snap $!\n";
	while ($row = <$general>) {
		chomp $row;
		if($row =~ /^maxfree/ || $row =~ /^maxpin%/ || $row =~ /^minfree/ ||$row =~ /^maxclient%/ || $row =~ /^maxperm%/ || $row =~ /^maxperm%/ || $row =~ /^minperm%/){
			#$row =~ s/^\s+//;
			@arr_tmp=split(/\s{3,}/,$row);
			@arr_tmp2=split(" ",$arr_tmp[5]);
			push(@arr_kernel_vmo,[$arr_tmp[0],$arr_tmp[1],$arr_tmp[2],$arr_tmp[3],$arr_tmp[4],$arr_tmp2[0]]);
		}
	}
	close $general;
	print "\n##### Параметры настройки ядра\n";
	print "\nВиртуальная память\n\n|Параметр|Текущее значение|Значение по умолчанию|Значение после след. перезагрузки|Min|Max|\n|:-:|:-:|:-:|:-:|:-:|:-:|\n";
	my $i=0;
	while ($i <= $#arr_kernel_vmo) {
		print "|$arr_kernel_vmo[$i][0]|$arr_kernel_vmo[$i][1]|$arr_kernel_vmo[$i][2]|$arr_kernel_vmo[$i][3]|$arr_kernel_vmo[$i][4]|$arr_kernel_vmo[$i][5]|\n";
		#@sorted_hdisk_arr_kernel_vmo = sort { $a->[0] <=> $b->[0] } @arr_kernel_vmo;
		$i++
	}
}
sub snap_kernel_no
{
	open($general, '<:encoding(UTF-8)', "@_/tcpip/tcpip.snap")
	or print "WARNING: could not open file @_/tcpip/tcpip.snap $!\n";
	print "\nПараметры TCP/IP\n\n";
	while ($row = <$general>) {
		chomp $row;
		if($row =~ /^[^\t]\s+rfc1323/ || $row =~ /^[^\t]\s+tcp_sendspace/ || $row =~ /^[^\t]\s+tcp_recvspace/ || $row =~ /^[^\t]\s+udp_sendspace/ || $row =~ /^[^\t]\s+udp_recvspace/){
		$row =~ s/^\s+//;
		print "$row  \n"
		}
	}
	close $general
}
sub snap_soft
{
	#ODM definition search

	$counter=0;
	open($general, '<:encoding(UTF-8)', "@_/general/general.snap")
	or print "WARNING: could not open file @_/tcpip/tcpip.snap $!\n";
	print "\n##### Дополнительное системное ПО\n\nODM definitions для систем хранения данных\n\n|ПО|Файлсет|Версия|\n|:-:|:-:|:-:|\n";
	while ($row = <$general>) {
	  chomp $row;
	  if($row eq ".....    lslpp -lc"){
	#Ugly shit
	    do {$row = <$general>}; do {$row = <$general>};  do {$row = <$general>};
	    while($row ne "\n"){
	      do {$row = <$general>};
	      @arr=split(":",$row);
	      foreach $odm_fileset (@odm) {
			next unless ($arr[1] && $arr[0]); # check for undef
	        if ($arr[1] eq $odm_fileset and $arr[0] eq "/usr/lib/objrepos"){
	          print "|",$arr[6],"|",$arr[1],"|",$arr[2],"|\n";
	          $counter++
	        }
	      }
	    }
	  }
	}
	if ($counter == 0){print "|none|none|none|\n"};
	close $general;

	#Veritas Search by lslpp -lc
	$counter=0;
	open($general, '<:encoding(UTF-8)', "@_/general/general.snap")
	or print "WARNING: could not open file @_/general/general.snap $!\n";
	print "\nПО Veritas\n\n|ПО|Файлсет|Версия|\n|:-:|:-:|:-:|\n";
	while ($row = <$general>) {
	  chomp $row;
	  if($row eq ".....    lslpp -lc"){
	#Ugly shit
	    do {$row = <$general>}; do {$row = <$general>};  do {$row = <$general>};
	    while($row ne "\n"){
	      do {$row = <$general>};
	      @arr=split(":",$row);
	      foreach $vrts_fileset (@vrts) {
			next unless ($arr[1] && $arr[0]);# check for undef
	        if ($arr[1] eq $vrts_fileset and $arr[0] eq "/usr/lib/objrepos"){
	          print "|",$arr[6],"|",$arr[1],"|",$arr[2],"|\n";
	          $counter++
	        }
	      }
	    }
	  }
	}
	if ($counter == 0){print "|none|none|none|\n"};
	close $general;

	#Multipathing Software Search by lslpp -lc
	$counter=0;
	open($general, '<:encoding(UTF-8)', "@_/general/general.snap")
	or print "WARNING: could not open file @_/general/general.snap $!\n";
	print "\nПО Multipathing\n\n|ПО|Файлсет|Версия|\n|:-:|:-:|:-:|\n";
	while ($row = <$general>) {
	  chomp $row;
	  if($row eq ".....    lslpp -lc"){
	#Ugly shit
	    do {$row = <$general>}; do {$row = <$general>};  do {$row = <$general>};
	    while($row ne "\n"){
	      do {$row = <$general>};
	      @arr=split(":",$row);
	      foreach $multipath_fileset (@multipath) {
			next unless ($arr[1] && $arr[0]);# check for undef
	        if ($arr[1] eq $multipath_fileset and $arr[0] eq "/usr/lib/objrepos"){
	          print "|",$arr[6],"|",$arr[1],"|",$arr[2],"|\n";
	          $counter++
	        }
	      }
	    }
	  }
	}
	if ($counter == 0){print "|none|none|none|\n"};
	close $general;


	# Search for Main Veritas filesets by lslpp -La
	#
	# Not usable because of multiversions:
	# Example
	# HP.aix.support.rte         5.0.0.1    C     F    AIX Support for HP Disk Arrays
	#                              5.0.0.5    C     F    AIX Support for HP Disk
	#                                                    Arrays(Update)
	#                             5.0.52.1    C     F    AIX Support for HP Disk
	#                                                    Arrays(Update)
	#                             5.0.52.2    C     F    AIX Support for HP Disk
	#                                                    Arrays(Update)
	#                             5.0.52.3    C     F    AIX Support for HP Disk
	#                                                    Arrays(Update)
	#
	#
	#
	# open($general, '<:encoding(UTF-8)', "./general/general.snap")
	# or print "WARNING: could not open file ./general/general.snap $!\n";
	# print "|ПО|Версия|\n|:-:|:-:|\n";
	# while ($row = <$general>) {
	#   chomp $row;
	#   if($row eq ".....    lslpp -La"){
	#     do {$row = <$general>}; do {$row = <$general>};  do {$row = <$general>}; do {$row = <$general>};
	#     while($row ne "\n"){
	#       do {$row = <$general>};
	#       my @arr=split(/\s+/,$row);
	#       if ($arr[1] eq "VRTSvxfs" or $arr[1] eq "VRTSvxvm" or $arr[1] eq "VRTSvcs"){
	#         print "|",$arr[1],"|",$arr[2],"|\n";
	#       }
	#     }
	#   }
	# }
	# close $general;
}
sub snap_errpt
{
	my $filename = "@_/general/errpt.out";
	open(my $fh, '<:encoding(UTF-8)', $filename)
	  or print "WARNING: could not open file '$filename' $!\n";

	$count=0;
	while (my $row = <$fh>) {
	  my $err_fl=0;
	  my $desc_fl=0;
	  if ($row eq "---------------------------------------------------------------------------\n")
	  {
	    while($err_fl!=1){
	      do {$row = <$fh>};
	      $tmp_char=unpack("x0 A17",$row);
	      if($row=~/LABEL:/){
	        chomp $row;
	        $arr_la[$count]=substr($row,8);
	        }
	      if($row=~/IDENTIFIER:/){
	        chomp $row;
	        $arr_id[$count]=substr($row,12);
	        }
	       if($tmp_char eq "Date/Time:"){
	        chomp $row;
	        #$orig_time=substr($row,17);
	        $arr_dt[$count]=substr($row,17);
	        }
	      if($tmp_char eq "Node Id:"){
	        chomp $row;
	#        $arr_nid[$count]=substr($row,17);
	        }
	      if($tmp_char eq "Class:"){
	        chomp $row;
	        $arr_class[$count]=substr($row,17);
	        }
	      if($tmp_char eq "Type:"){
	        chomp $row;
	        $arr_type[$count]=substr($row,17);
	        }
	      if($tmp_char eq "Resource Name:"){
	        chomp $row;
	        $arr_resn[$count]=substr($row,17);
	        if($arr_la[$count] eq "NONE"){
	            $arr_desc[$count]="none";
	            $err_fl=1;
	            $desc_fl=1;
	          }
	        }
	      if($desc_fl==0 && $row=~/Description/){
	        do {$row = <$fh>};
	        chomp $row;
	        $arr_desc[$count]=$row;
	        $err_fl=1;
	        $desc_fl=1;
	        }
	        $arr_flag[$count]="O";
	      }
	    $count++;
	  }
	}
	close $fh;
	$i=0;
	#while ($i<$count){
	#  $garr_1[$i]=[$arr_la[$i],$arr_id[$i],$arr_dt[$i],$arr_nid[$i],$arr_class[$i],$arr_type[$i],$arr_resn[$i],$arr_desc[$i],$arr_flag[$i]];
	#  $i++;
	#}
	print "\n###### Журнал ошибок\n\n";
	print "|Кол-во|ID|Первая регистрация|Последняя регистрация|Тип|Класс|Ресурс|Описание|\n";
	print "|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|\n";
	my $i=0;
	$count_res=0;
	$count_str=0;
	while ($i<$count){
	my $i1=$i+1;
	$count_str=1;
	  if($arr_flag[$i] ne "X"){
	     while($i1<$count){
	              if($arr_id[$i] eq $arr_id[$i1] && $arr_resn[$i] eq $arr_resn[$i1] && $arr_flag[$i1] ne "X"){
	                                $arr_flag[$i1]="X";
	                                $arr_flag[$i]="X";
	                                $count_str++;
	                                $temp_time=$arr_dt[$i1];
	              }
	     $i1++;
	     }
	  if($count_str==1){
	    $temp_time=$arr_dt[$i];
	  }
	  push(@arr_countn,$count_str);
	  #push(@arr_lan,$arr_la[$i]);
	  push(@arr_idn,$arr_id[$i]);
	  push(@arr_dtn,$arr_dt[$i]);
	  push(@arr_dtn1,$temp_time);
	  #push(@arr_nidn,$arr_nid[$i]);
	  push(@arr_classn,$arr_class[$i]);
	  push(@arr_typen,$arr_type[$i]);
	  push(@arr_resnn,$arr_resn[$i]);
	  push(@arr_descn,$arr_desc[$i]);
	  print "|",$arr_countn[$count_res],"|",$arr_idn[$count_res],"|",time_calc($arr_dtn1[$count_res]),"|",time_calc($arr_dtn[$count_res]),"|",$arr_classn[$count_res],"|",$arr_typen[$count_res],"|",$arr_resnn[$count_res],"|",$arr_descn[$count_res],"|","\n";
	#  open($fin, '>>', $outname);
	#  print $fin $arr_countn[$count_res],";",$arr_idn[$count_res],";",time_calc($arr_dtn1[$count_res]),";",time_calc($arr_dtn[$count_res]),";",$arr_classn[$count_res],";",$arr_typen[$count_res],";",$arr_resnn[$count_res],";",$arr_descn[$count_res],"\n";
	#  close $fin;
	  $count_res++;
	  }
	$i++;
	}

	#Counting number of entries for testing purpose
	#
	#open($fh, '<:encoding(UTF-8)', $filename)
	#  or print "WARNING: could not open file '$filename' $!\n";
	#$i=0;
	#while (my $row = <$fh>) {
	#  $tmp_char=unpack("x0 A11",$row);
	#  if ($tmp_char eq "IDENTIFIER:")
	#  {
	#    $i++;
	#  }
	#}
	#close $fh;
	#print "\n",$count," from ",$i,"\n";
}
sub time_calc
{
	my $in_time=$_[0];
	my %month=(
		'Jan'=>'01',
		'Feb'=>'02',
		'Mar'=>'03',
		'Apr'=>'04',
		'May'=>'05',
		'Jun'=>'06',
		'Jul'=>'07',
		'Aug'=>'08',
		'Sep'=>'09',
		'Oct'=>'10',
		'Nov'=>'11',
		'Dec'=>'12');
	my $t_date;

	if(unpack("x7 A3",$in_time)-10>=0){
		$t_date=unpack("x11 A8",$in_time);
		$t_date.=" ";
		$t_date.=unpack("x8 A2",$in_time);
		$t_date.=":";
		$t_date.=$month{unpack("x4 A3",$in_time)};
		$t_date.=":";
		$t_date.=unpack("x20 A4",$in_time);
	}
	else{
		$t_date=unpack("x11 A8",$in_time);
		$t_date.=" ";
		$t_date.="0";
		$t_date.=unpack("x9 A1",$in_time);
		$t_date.=":";
		$t_date.=$month{unpack("x4 A3",$in_time)};
		$t_date.=":";
		$t_date.=unpack("x20 A4",$in_time);

	  }
}
sub snap_hdisk
{
	my $counter=0;
	my @arr_tmp;
	my $rem_tail;
	open($general, '<:encoding(UTF-8)', "@_/general/lsdev.disk")
	or print "WARNING: could not open file ./general/lsdev.disk $!\n";
	print "\nДиски\n\n|Диск|Статус|Location|Тип|queue_depth|\n|:-:|:-:|:-:|:-:|:-:|\n";
	while ($row = <$general>) {
	  chomp $row;
	  if($row =~ /^hdisk/){
	   chomp $row;
	   @arr_tmp=split(/\s{1,}/,$row);
	   $i=4;
	   $rem_tail="";
	   while ($i <= $#arr_tmp) {
		$a="\$arr_tmp\[$i\]";
		$rem_tail="$rem_tail $a";
		$i++;
	   }
	   $rem_tail =~ s/^\s+//;
	   $rem_tail =~ s/\s+$//;
	   #brian d foy :)
	   $rem_tail =~ s/(\$arr_tmp\[[0-9]\])/$1/eeg;
	   push(@arr_hdisk,[substr($arr_tmp[0],5),$arr_tmp[1],$arr_tmp[3],$rem_tail]);
	   $counter++;
	   @sorted_hdisk = sort { $a->[0] <=> $b->[0] } @arr_hdisk;
	  }
	}
	close $general;

	my $hdisk_tmp;
	my $queue_tmp;
	my @queue_tmp;
	my @arr_queue;
	if ($counter == 0){print "|none|none|none|\n"};
	close $general;
	open($general, '<:encoding(UTF-8)', "@_/general/general.snap")
	or print "WARNING: could not open file @_/general/general.snap $!\n";
	while ($row = <$general>) {
		chomp $row;
		if($row =~ /^.....    lsattr -El hdisk/){
			$hdisk_tmp = substr ($row,25);
		}
		if($row =~ /^queue_depth/){
			@queue_tmp=split(/\s{2,}/,$row);
			$queue_tmp=$queue_tmp[1];
		@arr_tmp=($hdisk_tmp,$queue_tmp);
		push(@arr_queue,[$arr_tmp[0],$arr_tmp[1]]);
		@sorted_queue = sort { $a->[0] <=> $b->[0] } @arr_queue;
		}
	}
	close $general;
	$i = 0;
	while ($i <= $#sorted_hdisk) {
		# or @sorted ??
		push($sorted_hdisk[$i],$sorted_queue[$i][1]);
	$i++;
	}
	$i = 0;
	while ($i <= $#sorted_hdisk) {
		print "|hdisk$sorted_hdisk[$i][0]|$sorted_hdisk[$i][1]|$sorted_hdisk[$i][2]|$sorted_hdisk[$i][3]|$sorted_hdisk[$i][4]|\n";
		$i++;
	}
}
sub snap_rmt
{
	my $counter=0;
	my @arr_tmp;
	open($general, '<:encoding(UTF-8)', "@_/general/general.snap")
	or print "WARNING: could not open file @_/general/general.snap $!\n";
	print "\nЛенточные накопители\n\n|Драйв|Location|Тип|\n|:-:|:-:|:-:|\n";
	while ($row = <$general>) {
	  chomp $row;
	  if($row =~ /^\s\srmt/){
	   chomp $row;
	   $row =~ s/^\s+//;
	   @arr_tmp=split(/\s{4,}/,$row);
	   push(@arr_rmt,["rmt",substr($arr_tmp[0],3),$arr_tmp[1],$arr_tmp[2]]);
	   $counter++;
	   @sorted_rmt = sort { $a->[1] <=> $b->[1] } @arr_rmt;
	  }
	}
	my $i = 0;
	while ($i <= $#sorted_rmt) {
		print "|$sorted_rmt[$i][0]$sorted_rmt[$i][1]|$sorted_rmt[$i][2]|$sorted_rmt[$i][3]|\n";
		$i++
	}

	if ($counter == 0){print "|none|none|none|\n"};
	close $general;
}
sub snap_recommendations
{
	print "\n";
	print "#### 4. Рекомендации\n\n";
	print "IBM настоятельно советует использовать рекомендованную на данный момент времени\nверсию микрокода сервера и ОС AIX (VIOS). Использование устаревших версий ПО  может\nпривести к отказам оборудования, значительно затруднить диагностику и увеличить время\nвосстановления после сбоя. Выбор конкретной версии ПО рекомендуется осуществлять на момент\nпринятия стратегии обновления.\n\n";
	if ($recom_dump_small == 1){
	print "- Рекомендуется увеличить размер первичного устройства системного дампа\n";
	}
}
