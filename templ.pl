#!/usr/bin/perl
#
# создание выходного файла по шаблону
# на вход - файл шаблона и файл данных разделенных точкой с запятой 
# 
# переменные настройки по умолчанию
$IsBlock = 0;
$version = '2.4a';
$delim =';';
$print_line = 1;
$downstop_match = 0;
$statement_match = 0;

# чтение файлов из командной строки
# $tpl - шаблон, $dta - файл данных, $tgt - файл результата
my ($tpl, $dta, $tgt ) = @ARGV;

print "version       :   $version\n";
print "template file :   $tpl\n";
print "data file     :   $dta\n";
print "result file   :   $tgt\n";

$dbg = "debug.ttt";


open (TGT_F, ">$tgt") || die "cannot create file $tgt: $!";
open (TPL_F, "<$tpl") || die "cannot open file $tpl: $!";
open (DTA_F, "<$dta") || die "cannot open file $dta: $!";
open (DBG_F, ">$dbg") || die "cannot create file $dbg: $!";

################################ читаем шаблон 
$pidx = 0;
$bidx = 0;
$eidx = 0;
$oidx = 0;
while(<TPL_F>) { 

  SWITCH:
  { 
    if ( /prolog__/  ) { $IsBlock = 1; last SWITCH; }
    if ( /__end/     ) { $IsBlock = 0; last SWITCH; }
    if ( /repeat__/  ) { $IsBlock = 2; last SWITCH; }
    if ( /epilog__/  ) { $IsBlock = 3; last SWITCH; }
    if ( /options__/ ) { $IsBlock = 4; last SWITCH; }
    if ( /perlcode__/) { $IsBlock = 5; last SWITCH; }
  }

  if ( $IsBlock == 1 ) {
    if ( $_ !~ /__/ ) { 
     $prolog[$pidx] = $_;
     $pidx++;
    }
  }
  if ( $IsBlock == 2 ) {
    if ( $_ !~ /__/ ) { 
     $body[$bidx] = $_;
     $bidx++;
    }
  }

  if ( $IsBlock == 3 ) {
    if ( $_ !~ /__/ ) { 
     $epilog[$eidx] = $_;
     $eidx++;
    }
  }
  if ( $IsBlock == 5 ) {
    if ( $_ !~ /__/ ) { 
     $perlcode .= $_;
     $statement_match = 1;
    }
  }

  if ( $IsBlock == 4 ) {
    if ( $_ !~ /__/ ) { 
 
     $options[$oidx] = $_;

     if(/line/) {
       @ops = split(/==>/,$_);
       $ljmp = $ops[1];
     }
    
    if(/downstart/) {
      @ops = split(/==>/,$_);
      $downstart = $ops[1];
      $downstart =~ s/\'*//gi;
      chomp($downstart);
    }

    if(/downstop/) {
      @ops = split(/==>/,$_);
      $downstop = $ops[1];
      $downstop =~ s/\'*//gi;
      $downstop_match = 1;
      $print_line = 0;
      chomp($downstop);
    }

    if(/delimiter/) {
       @ops = split(/==>/,$_);
       $delim = $ops[1];
       $delim =~ s/\'*//gi;
       chomp($delim);
     } 

     $oidx++;
    }
  }
}

close TPL_F;
print 'begining line : ',$ljmp,"\n";
print 'delimiter     : ',$delim,"\n";
print DBG_F $delim,"\n";
print DBG_F $downstart,"\n";


for($i=0; $i<$pidx; $i++ ) { 
  chomp($prolog[$i]);
  print TGT_F $prolog[$i],"\n"; 
}


# eval "if(\/Price-list\/) { print TGT_F $_; }" ;

################################ прочитали шаблон 

$lstart = 1;
while(<DTA_F>) {         ## читаем файл данных
  if ($statement_match == 1) { 
    print DBG_F "PERLCODE===== ",$perlcode,"\n";
    eval " $perlcode ";
    print DBG_F "errors===== ",$@,"\n";
  }

  @dstr = split(/$delim/g,$_); ## делим строку  и заносим в массив данных  
  if ( m%$downstop%gi && $downstop_match == 1) {
#      print DBG_F "downstop =",$downstop, "\n";
       $print_line = 0;
    }

  $colnum = scalar(@dstr);  ## определяем кол-во "столбцов" в массиве данных
  
  for($i = 0; $i < $bidx; $i++) {
    $tmp  = $body[$i];
    for($j = 0; $j < $colnum; $j++) {
      chomp($dstr[$j]);
      $dstr[$j] =~ s/\s*//;     ## убираем пробелы
      $ss = '#'.$j;             ## формируем образец для поиска


      if ( $body[$i] =~ /$ss/gi) {   ## присутствует-ли образец для поиска 
                                     ## в шаблоне ?
          $body[$i] =~ s/$ss/$dstr[$j]/gi; 
        }
    }
    chomp($body[$i]);

# AKA
#    print DBG_F $body[$i],"\n";
#    print DBG_F "lstart =",$lstart," print_line =",$print_line,"\n"; # $body[$i],"\n";
    if ($lstart >= $ljmp && $print_line == 1) {
      print TGT_F $body[$i],"\n"; 
#      print DBG_F $body[$i],"\n"; 
    }
    $body[$i] = $tmp;
  }
  $lstart++;
  if ( m%$downstart%gi) {
       $print_line = 1;
    }

} ################################### закончили читать файл данных
close DTA_F; 

for($i=0; $i<$eidx; $i++ ) { 
  chomp($epilog[$i]);
  print TGT_F $epilog[$i],"\n"; 
}
close TGT_F;

