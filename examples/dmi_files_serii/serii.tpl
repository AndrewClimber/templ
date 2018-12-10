options__
 downstart==>'Серии'
 downstop==>'\*'
 delimiter==>';'
__end

prolog__
 spool c:\spool_dir\serii.txt
__end

repeat__
insert into aka.csert 
values(#0,'#1',to_date('#2','dd.mm.yyyy'),to_date('#3','dd.mm.yyyy'));
__end

epilog__
commit;
__end
