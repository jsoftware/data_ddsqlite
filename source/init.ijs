
coclass 'jddsqlite'

NB. =========================================================
NB. utils from Inverted Tables essay
ifa_z_=: <@(>"1)@|:  NB. inverted from atomic
afi_z_=: |:@:(<"_1@>)  NB. atomic from inverted
ttally_z_=: *@# * #@>@{.

DateTimeNull=: _1
NumericNull=: _
InitDone=: (InitDone_jddsqlite_"_)^:(0=4!:0<'InitDone_jddsqlite_') 0
UseErrRet=: 0
UseDayNo=: 0
UseUnicode=: 0

create=: 3 : 0
if. 0=InitDone_jddsqlite_ do.
  sqlite3_initialize''
  sqlite3_enable_shared_cache 1
  InitDone_jddsqlite_=: 1
end.
initodbcenv 0
''
)

destroy=: 3 : 0
endodbcenv 0
NB. sqlite3_shutdown''
codestroy''
)

NB. =========================================================
NB. replace z locale names defined by jdd/ODBC locale.

setzlocale=: 3 : 0
wrds=. 'ddsrc ddtbl ddtblx ddcol ddcon dddis ddfch ddend ddsel ddcnm dderr'
wrds=. wrds, ' dddrv ddsql ddcnt ddtrn ddcom ddrbk ddbind ddfetch'
wrds=. wrds ,' dddata ddfet ddbtype ddcheck ddrow ddins ddparm ddsparm dddbms ddcolinfo ddttrn'
wrds=. wrds ,' dddriver ddconfig ddcoltype'
wrds=. wrds ,' userfn createdb exec sqlbad sqlok sqlres sqlresok'
wrds=. wrds , ' ', ;:^:_1 ('get'&,)&.> ;: ' DateTimeNull NumericNull UseErrRet UseDayNo UseUnicode CHALL'
wrds=. > ;: wrds

cl=. '_jddsqlite_'
". (wrds ,"1 '_z_ =: ',"1 wrds ,"1 cl) -."1 ' '

if. 0=InitDone_jddsqlite_ do.
  sqlite3_initialize_jddsqlite_''
  sqlite3_enable_shared_cache 1
  InitDone_jddsqlite_=: 1
end.
endodbcenv_jddsqlite_ 0
initodbcenv_jddsqlite_ 0

EMPTY
)
