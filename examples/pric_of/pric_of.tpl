options__
 line==>4
__end

prolog__
 set autocommit 300
__end

repeat__
 INSERT INTO 
 MARKET.MOSORDER(cd_m,nm_m,nm_prod,gp_price,gp_amount,packs,gp_except,flags) 
 VALUES(#0,'#1','#2',#3,#4,'#5',to_date('#8','dd.mm.rr'),decode('#6','',0,1));
__end

epilog__
 commit;
__end
