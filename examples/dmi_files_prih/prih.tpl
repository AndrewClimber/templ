options__
 delimiter==>'\s+'
 downstart==>'Тело документа'
 downstop==>'Серии'
__end

perlcode__
  if(/Price-list/) {
    @s=split(/:/,$_); 
    @ss=split(/\s/,$s[1]);
    $s0 = 'Приход, накладная № '."$ss[0]".' от '."$ss[4]";
    print TGT_F "execute :a:=abc.insdoc(1,2,'$ss[0]','$s0',2,2,1);\n";
    print TGT_F "select cd_a,num from abc.doc where cd_c=:a;\n";
  }
__end

prolog__
 spool C:\perl.ak\Template\prihod.txt
 var a number
__end

repeat__
 execute abc.insdocbody(:a,#0,#1);
__end

epilog__
 spool off
__end
