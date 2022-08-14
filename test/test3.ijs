dbr 1
cocurrent 'base'
decho=: 0:
sqlcoderes=: >@:{: 
SQL_ERROR=: _1
SQL_NO_DATA=: 100
SQL_SUCCESS_WITH_INFO=: 1
sqlfetchres=: 3 : 0
if. SQL_ERROR-:0{::y do.
 ''
else.
 1{::y
end.
)

load 'data/ddsqlite'

NB. total on column 0
NB. (ldb ; ch) totalsqlcol~ sql
totalsqlcol=: 4 : 0
'db ch'=. y
assert. 0~:ch
total=. 0
err=. SQL_SUCCESS_STR
x=. x
if. SQL_ERROR__db&~: sh=. sqlcoderes res=. ch ddsel__db~ x do.
 if. (0{::res) -.@e. SQL_NO_DATA, SQL_SUCCESS_WITH_INFO do.
  if. res=. ddfch__db sh, _1 do.
   if. {.ttally rs=. sqlfetchres res do.
    total=. +/, 0{::rs
   end.
  else.
  end.
 end.
 ddend__db sh
else.
end.
total
)

NB. =========================================================
testdb=: 3 : 0
db=. '' conew 'jddsqlite'
ddconfig__db 'errret';1;'dayno';1;'unicode';1

f=. jpath '~/db0.sqlite'

if. sqlresok__db rc=. ddcon__db 'database=',f,';nocreate=0' do.
  ch=. sqlres__db rc
  echo 'select count(*) from glcoac' totalsqlcol db;ch
end.
destroy__db''
)

testdb''
