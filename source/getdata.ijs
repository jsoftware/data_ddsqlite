NB. get and convert various datatypes ----------------------

NB. =========================================================
datnull=: 3 : 0"1
if. SQLITE_TEXT= t=. sqlite3_column_type (b0 y) do. SQL_VARCHAR ,&< datchar y
elseif. SQLITE_BLOB= t do. SQL_LONGVARBINARY ,&< datblob y
elseif. SQLITE_INTEGER= t do. SQL_INTEGER ,&< datinteger y
elseif. SQLITE_FLOAT= t do. SQL_DOUBLE ,&< datdouble y
elseif. SQLITE_NULL= t do. 0 ,&< 0
end.
)

NB. =========================================================
datchar=: 3 : 0"1
p=. sqlite3_column_text (b0 y)
n=. sqlite3_column_bytes (b0 y)
NB. assume varchar family will not contain {.a.
NB. the assert at the end of getdata will check for error
if. (0~:p) *. n>0 do.
  ({.a.),~memr p,0,n,2
else.
  {.a.
end.
)

NB. =========================================================
datblob=: 3 : 0"1
p=. sqlite3_column_blob (b0 y)
n=. sqlite3_column_bytes (b0 y)
if. (0~:p) *. n>0 do.
  <memr p,0,n,2
else.
  <''
end.
)

NB. =========================================================
datdouble=: 3 : 0"1
{.sqlite3_column_double (b0 y)
)

NB. =========================================================
datinteger=: 3 : 0"1
{.sqlite3_column_int`sqlite3_column_int64@.IF64 (b0 y)
)

NB. =========================================================
datdate=: 3 : 0"1
p=. sqlite3_column_text (b0 y)
n=. sqlite3_column_bytes (b0 y)
if. (0~:p) *. n>0 do.
  ({.a.),~ 10{. memr p,0,n,2
else.
  {.a.
end.
)

NB. =========================================================
dattime=: 3 : 0"1
p=. sqlite3_column_text (b0 y)
n=. sqlite3_column_bytes (b0 y)
if. (0~:p) *. n>0 do.
  ({.a.),~ memr p,0,n,2
else.
  {.a.
end.
)

NB. =========================================================
datdatetime=: 3 : 0"1
p=. sqlite3_column_text (b0 y)
n=. sqlite3_column_bytes (b0 y)
if. (0~:p) *. n>0 do.
  ({.a.),~ memr p,0,n,2
else.
  {.a.
end.
)

NB. =========================================================
getdata=: 4 : 0

NB. dyad:  btGetcolinfo getdata ilShRows
NB.
NB.  ci =. getcolinfo sh
NB.  ci getdata sh,10   NB. ten rows
NB.  ci getdata sh,_1   NB. all rows in stmt

'sh r ignorelongdata'=. 3{.y
NB. cat;schema;db;table;column;ordinal;itype;bytelen;digit;nullable
NB. catalog database table org_table name org_name column-id(1-base) typename coltype length decimals nullable def nativetype nativeflags
assert. 15={:$x
oty=. ; 8 {"1 x
ln=. ; 9 {"1 x
ty=. ; 13 {"1 x

NB. columns numbers and stmt handles
cc=. sh,.i.#ty

dat=. 0$<''
if. r=0 do. dat return. end.

pref=. 'BIND',(":sh),'_'
for_i. i.#ty do.
  if. SQL_INTEGER = i{ty do.
    (pref,":i)=. 0$0
  elseif. SQL_DOUBLE = i{ty do.
    (pref,":i)=. 0$1.1-1.1
  elseif. (SQL_CHAR,SQL_WCHAR,SQL_VARCHAR,SQL_WVARCHAR) e.~ i{ty do.
    (pref,":i)=. 0$''
  elseif. (SQL_LONGVARCHAR,SQL_WLONGVARCHAR) e.~ i{ty do.
    (pref,":i)=. 0$<''
  elseif. SQL_LONGVARBINARY = i{ty do.
    (pref,":i)=. 0$<''
  elseif. (SQL_TYPE_DATE,SQL_TYPE_TIME,SQL_TYPE_TIMESTAMP) e.~ i{ty do.
    (pref,":i)=. 0$''
  elseif. do.
    (pref,":i)=. 0$i.0
  end.
end.

z=. sqlite3_step sh
while.do.

  if. (SQLITE_OK,SQLITE_ROW,SQLITE_DONE) -.@e.~ rc=. >{.z do.
    errret sh_to_ch sh return.
  end.
  if. (SQLITE_ROW) -.@e.~ rc do.
NB. TODO: kludge to make it work for UseErrRet
NB. UseErrRet broken unless SQLITE_OMIT_AUTORESET compile-time option is used
NB.     ddend^:(-.UseErrRet) sh
    UseErrRet&ddend sh
    break.
  end.

  for_i. i.#ty do.
    tmp=. (pref,":i)~
    4!:55 <(pref,":i)
    if. SQLITE_NULL= sqlite3_column_type (b0 i{cc) do.
      if. SQL_INTEGER = i{ty do.
        tmp=. tmp, NumericNull
      elseif. SQL_DOUBLE = i{ty do.
        tmp=. tmp, NumericNull
      elseif. (SQL_CHAR,SQL_WCHAR,SQL_VARCHAR,SQL_WVARCHAR) e.~ i{ty do.
        tmp=. tmp, {.a.
      elseif. (SQL_LONGVARCHAR,SQL_WLONGVARCHAR) e.~ i{ty do.
        tmp=. tmp, <{.a.
      elseif. SQL_LONGVARBINARY = i{ty do.
        tmp=. tmp, <''
      elseif. SQL_TYPE_DATE = i{ty do.
        tmp=. tmp, {.a.
      elseif. SQL_TYPE_TIME = i{ty do.
        tmp=. tmp, {.a.
      elseif. SQL_TYPE_TIMESTAMP = i{ty do.
        tmp=. tmp, {.a.
      elseif. do.
        tmp=. tmp, {.a.
      end.
    else.
      if. SQL_INTEGER = i{ty do.
        tmp=. tmp, datinteger i{cc
      elseif. SQL_DOUBLE = i{ty do.
        tmp=. tmp, datdouble i{cc
      elseif. (SQL_CHAR,SQL_WCHAR,SQL_VARCHAR,SQL_WVARCHAR) e.~ i{ty do.
        tmp=. tmp, datchar i{cc
      elseif. (SQL_LONGVARCHAR,SQL_WLONGVARCHAR) e.~ i{ty do.
        tmp=. tmp, (<@:(ucp^:UseUnicode)@:}:@:datchar)`((<'')"_)@.ignorelongdata i{cc
      elseif. SQL_LONGVARBINARY = i{ty do.
        tmp=. tmp, datblob`((<'')"_)@.ignorelongdata i{cc
      elseif. SQL_TYPE_DATE = i{ty do.
        tmp=. tmp, datdate i{cc
      elseif. SQL_TYPE_TIME = i{ty do.
        tmp=. tmp, dattime i{cc
      elseif. SQL_TYPE_TIMESTAMP = i{ty do.
        tmp=. tmp, datdatetime i{cc
      elseif. do.
        't d'=. datnull i{cc
        if. SQL_INTEGER = t do.
          ty=. t i}ty
          tmp=. (0$~#tmp), d
        elseif. SQL_DOUBLE = t do.
          ty=. t i}ty
          tmp=. (0$~#tmp), d
        elseif. (SQL_CHAR,SQL_WCHAR,SQL_VARCHAR,SQL_WVARCHAR) e.~ t do.
          ty=. t i}ty
          tmp=. (({.a.)$~#tmp), d
        elseif. (SQL_LONGVARCHAR,SQL_WLONGVARCHAR) e.~ t do.
          ty=. t i}ty
          tmp=. (({.a.)$~#tmp), d
        elseif. SQL_LONGVARBINARY = t do.
          ty=. t i}ty
          tmp=. ((<'')$~#tmp), d
        elseif. SQL_TYPE_DATE = t do.
          ty=. t i}ty
          tmp=. (({.a.)$~#tmp), d
        elseif. SQL_TYPE_TIME = t do.
          ty=. t i}ty
          tmp=. (({.a.)$~#tmp), d
        elseif. SQL_TYPE_TIMESTAMP = t do.
          ty=. t i}ty
          tmp=. (({.a.)$~#tmp), d
        elseif. do.
          tmp=. tmp, d
        end.
      end.
    end.
    (pref,":i)=. tmp
    4!:55 <'tmp'
  end.

  if. 0=r=. <:r do. break. end.  NB. _1 case ends on SQL_NO_DATA
  z=. sqlite3_step sh
end.
if. 0=#(pref,":0)~ do.
  dat=. (#ty)$<i.0 0
else.
  for_i. i.#ty do.
    if. SQL_INTEGER = i{ty do.
      dat=. dat, < (pref,":i)~
    elseif. SQL_DOUBLE = i{ty do.
      dat=. dat, < (pref,":i)~
    elseif. (SQL_CHAR,SQL_WCHAR,SQL_VARCHAR,SQL_WVARCHAR) e.~ i{ty do.
      dat=. dat, < <;._2 ucp^:UseUnicode (pref,":i)~
    elseif. (SQL_LONGVARCHAR,SQL_WLONGVARCHAR) e.~ i{ty do.
      dat=. dat, < (pref,":i)~
    elseif. SQL_LONGVARBINARY = i{ty do.
      dat=. dat, < (pref,":i)~
    elseif. (SQL_TYPE_DATE,SQL_TYPE_TIME,SQL_TYPE_TIMESTAMP) e.~ i{ty do.
      if. UseDayNo do.
        dat=. dat, < numdate`numtime`numdatetime@.((SQL_TYPE_DATE,SQL_TYPE_TIME,SQL_TYPE_TIMESTAMP)i.i{ty);._2 (pref,":i)~
      else.
        dat=. dat, < <;._2 (pref,":i)~
      end.
    elseif. do.
      dat=. dat, < 0#~#(pref,":i)~
    end.
  end.
end.
assert. 1= # ~. #&> dat
if. UseErrRet do.
  (<<<0),dat
else.
  dat
end.
)

NB. =========================================================
numdate=: 3 : 0
if. 0= #y=. dltb y do.
  DateTimeNull
else.
  86400000%~ tsrep 0 0 0,~ 3{. ". ' 0123456789' ([-.-.)~ ' ' (I. y e. '-:+TZ')}y
end.
)

numtime=: 3 : 0"1
if. 0= #y=. dltb y do.
  DateTimeNull
else.
  86400000%~ tsrep 0 (0 1 2)} 6{. ". ' 0123456789' ([-.-.)~ ' ' (I. y e. '-:+TZ')}y
end.
)

numdatetime=: 3 : 0"1
if. 0= #y=. dltb y do.
  DateTimeNull
else.
  86400000%~ tsrep 6{. ". ' 0123456789' ([-.-.)~ ' ' (I. y e. '-:+TZ')}y
end.
)