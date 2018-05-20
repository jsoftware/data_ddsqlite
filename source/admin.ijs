NB. =========================================================
NB. administrative routines

NB. =========================================================
NB. create new empty sqlite3
NB. return 0 success
NB.        _1 invalid argument
NB.        _2 already exist
NB.        positive sqlite error code

createdb=: 3 : 0
if. -.iscl y do. _2 return. end.
dbq=. utf8 ,>y
if. fexist dbq do. _1 return. end.
handle=. ,_1
if. has_sqlite3_extversion do.
  nul=. SQLITE_NULL_INTEGER;SQLITE_NULL_FLOAT;SQLITE_NULL_TEXT
  cdrc=. sqlite3_extopen (iospath^:IFIOS dbq);handle;(SQLITE_OPEN_READWRITE+SQLITE_OPEN_CREATE);nul,<<0
else.
  cdrc=. sqlite3_open_v2 (iospath^:IFIOS dbq);handle;(SQLITE_OPEN_READWRITE+SQLITE_OPEN_CREATE);<<0
end.
if. SQLITE_OK~: rc=. >@{. cdrc do.
  rc
else.
  0 [ sqlite3_close {. 2{::cdrc
end.
)

NB. =========================================================
NB. excute sql script
NB. runs zero or more UTF-8 encoded, semicolon-separate SQL statements
NB.
NB. return 0 success
NB.        _1 invalid argument
NB.        positive sqlite error code

exec=: 4 : 0
if. -. isia y do. _1 return. end.
if. -. y e. CHALL do. _1 return. end.
if. -.iscl x do. _1 return. end.
sql=. utf8 ,>x

if. rc=. >@{. cdrc=. sqlite3_exec y;sql;0;0;ep=. ,_1 do.
  ep=. 5{::cdrc
  if. {.ep do. sqlite3_free {.ep end.
end.
rc
)
