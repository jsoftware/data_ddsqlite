NB. ddins
NB.

NB.*ddcolinfo v get column type of result of a statement handle
NB. y sh
NB. return  catalog database table org_table name org_name column-id(1-base) typename coltype length decimals nullable def nativetype nativeflags
ddcolinfo=: 3 : 0
clr 0
if. -. isia y=. fat y do. errret ISI08 return. end.
if. -.y e. 1{"1 CSPALL do. errret ISI04 return. end.
if. 2{CSPALL{~ y i.~ 1{"1 CSPALL do. errret ISI04 return. end.   NB. defunct
sh=. y
if. 0= #ci=. getallcolinfo sh do.
  z=. errret sh_to_ch sh
else.
  assert. 15={:@$ci
  assert. 1= #@$&> ,ci
  z=. ret_DD_OK ci
end.
z
)

NB.ddcoltype v get column type of result of a select statement
NB. base table name appended
NB. x select statement
NB. return  catalog database table org_table name org_name column-id(1-base) typename coltype length decimals nullable def nativetype nativeflags
ddcoltype=: 4 : 0
if. -.y e.CHALL do. errret ISI03 return. end.
if. -. iscl sql=. x do. errret ISI08 return. end.

if. SQLITE_OK = >@{. z=. x preparestmt y do.
  sh=. 1{::z
  if. #ci=. getallcolinfo sh do.
    freestmt sh
    ret_DD_OK ci
  else.
    z=. errret y
    freestmt sh
    z
  end.
else.
  errret y
end.
)

NB. emulate sqlbulkoperation
NB. sql eg.  'select docnum,linenum,pcode,pqty from arinvl'
NB. (sql;data1;data2) ddins ch
ddins=: 4 : 0
clr DDROWCNT=: 0
if. -.(isia y) *. isbx x do. errret ISI08 return. end.
if. -.y e.CHALL do. errret ISI03 return. end.
if. 2>#x do. errret ISI08 return. end.
if. -. *./ 2>: #@$&> }.x do. errret ISI08 return. end.
if. 1<#rows=. ~. > {.@$&>}.x do. errret ISI08 return. end.
if. 0=rows=. fat rows do. SQL_NO_DATA; 0 return. end.
sql=. dltb utf8 , 0{::x
if. SQL_ERROR-: z=. y ddcoltype~ sql do. z return. end.
if. (<SQL_ERROR)-: {.z do. z return. end.
'oty ty lns'=. |: _3]\;8 13 9{("1) z=. 1&{::^:UseErrRet z
flds=. 4{("1) z
tbl=. ~. 2{("1) z
NB. if table name can not be determined, try parsing the sql statement to get table name
if. (,a:)-:tbl do.
NB. discard "select"
  if. 'select'-.@-: tolower 6{.sql0=. deb sql do. errret ISI08 return. end.
  sql0=. dlb 6}.sql0
NB. discard " where ..." clause
  if. 1 e. r=. ' where ' E. s=. tolower sql0 do. sql0=. sql0{.~ r i: 1
  elseif. 1 e. r=. ' where(' E. s do. sql0=. sql0{.~ r i: 1
  elseif. 1 e. r=. ')where ' E. s do. sql0=. sql0{.~ r i: 1
  elseif. 1 e. r=. ')where(' E. s do. sql0=. sql0{.~ r i: 1
  end.
NB. parse fields and table name
  if. 1 e. r=. ' from ' E. s=. tolower sql0 do.
    tbl=. dltb sql0}.~ a + #' from ' [[ a=. r i: 1
  elseif. 1 e. r=. ' from(' E. s do.
    tbl=. dltb sql0}.~ a + #' from(' [[ a=. r i: 1
  elseif. 1 e. r=. ')from ' E. s do.
    tbl=. dltb sql0}.~ a + #')from ' [[ a=. r i: 1
  elseif. 1 e. r=. ')from(' E. s do.
    tbl=. dltb sql0}.~ a + #')from(' [[ a=. r i: 1
  elseif. do. errret ISI08 return. end.
NB. filter extra invalid characters
  tbl=. < tbl -. '+/()*,-.:;=?@\^_`{|}'''
end.
if. (1~:#tbl) +. a: e. tbl do.  NB. more than one base table or column with base table
  errret ISI52 return.
end.
if. (<:#x)~:#ty do.
  errret ISI50 return.
end.
inssql=. 'insert into ', (>@{.tbl), '(', (}. ; (<',') ,("0) flds), ') values (', (}. ; (#flds)#<',?'), ')'
if. has_sqlite3_extversion *. 1=#tbl do.
  sql2=. 'select ', (}. ; (<',') ,&.> (flds)), ' from ', (>@{.tbl), ' limit 0'
  if. SQL_ERROR-: z=. y ddcoltype~ sql2 do. z return. end.
  if. (<SQL_ERROR)-: {.z do. z return. end.
  'oty ty lns'=. |: _3]\;8 13 9{("1) z=. 1&{::^:UseErrRet z
  typ=. gettyp"0 oty
  if. _1 e. typ do. errret ISI51 return. end.
  r=. y execparm inssql;flds;typ;oty;< }.x
  return.
end.
z=. (inssql ; (|: oty,.lns,.ty) ; (}.x)) ddparm y
)

NB. find base table and parameter in parameterised sql query like
NB. only applicable to single base table and one ? for each field
NB. return box array: table ; parm0 ; parm1 ; ...
NB. test
NB. 'update t set pa1=?,pa2=? where key=?'
NB. 'update t set a=12,b=b+?,c=(?),k=''abc'',p=right(t,3),q=trim(?,4),d=? where e1=foo(?) and e2=? or and e3<>4 and e4=?'
NB. 'insert into t (a,b,c,d,e,f) values (?,''?'',1,?,?,''aa'')'
parsesqlparm=: 3 : 0
fmt=. 0  NB. 1 (...) values (?,?,?)
if. ('insert into' ; 'select into') e.~ <tolower 11{.y=. dlb y do. ix=. 11 [ fmt=. 1
elseif. 'insert ' -: tolower 7{.y do. ix=. 6 [ fmt=. 1
elseif. 'delete from' -: tolower 11{.y do. ix=. 11
elseif. 'update' -: tolower 6{.y do. ix=. 6
elseif. do. ix=. _1
end.
if. _1~:ix do.
  table=. ({.~ i.&' ') dlb ix}. ' ' (I.y e.'()')}y
else.
  table=. ''
end.
if. 1=fmt do.
  if. 1 e. ivb=. ' values ' E. tolower ' ' (I.y e.'()')}y do. iv=. {.I.ivb else. fmt=. 0 end.
end.
if. 0=fmt do.
  y1=. y
  f1=. (0=(2&|)) +/\ ''''=y1  NB. outside quote but including trailing quote
  f2=. (> 0:,}:) f1           NB. firstones of f1
  f2=. 0,}.f2                 NB. no leading quote
  y1=. ' ' (I.-.f1)}y1        NB. replace string with blanks
  y1=. ' ' (I.f2)}y1          NB. replace trailing quote
  f1=. 0< (([: +/\ '('&=) - ([: +/\ ')'&=)) y1    NB. inside ()
  y1=. ' ' (I.f1 *. ','=y1)}y1    NB. replace , within () with blanks
  y1=. ' ' (I.y1 e.'()')}y1    NB. replace () with blanks
  y1=. (' where ';', where ';' WHERE ';', WHERE ';' and ';', and ';' AND ';', AND ';' or ';', or ';' OR ';', OR ') stringreplace (deb y1) , ','  NB. add delimiter for the last field
  a=. (',' = y1) <;._2 y1
  b=. (#~ ('='&e. *. '?'&e.)&>) a
  c=. ({.~ i:&'=')&.> b
  parm=. dtb&.> ({.~ i.&' ')&.|.&.> c
else.
  fld=. <@dltb;._1 ',', ' ' (I.a e.'()')} a=. (}.~ i.&'(') y{.~ iv

  y1=. y}.~ iv + #' values '
  f1=. (0=(2&|)) +/\ ''''=y1  NB. outside quote but including trailing quote
  f2=. (> 0:,}:) f1           NB. firstones of f1
  f2=. 0,}.f2                 NB. no leading quote
  y1=. ' ' (I.-.f1)}y1        NB. replace string with blanks
  y1=. ' ' (I.f2)}y1          NB. replace trailing quote
  y1=. }.}:dltb y1            NB. remove outermost ()
  f1=. 0< (([: +/\ '('&=) - ([: +/\ ')'&=)) y1    NB. inside ()
  y1=. ' ' (I.f1 *. ','=y1)}y1    NB. replace , within () with blanks
  y1=. ' ' (I.y1 e.'()')}y1    NB. replace () with blanks
  y1=. (deb y1),','   NB. add delimiter for the last field
  a=. <;._2 y1
  msk=. ('?'&e.)&> a
  parm=. ((#fld){.msk)#fld
end.
table;parm
)

NB.* ddsparm v
NB. parameterised query (no rows returned),  useful for insert/update blob
NB. will add column type and call ddparm, single base table only
NB.    ch ddsparm~ 'insert into blobs (jjname,jjbinary) values (?,?)';'abc';2345678$a.
ddsparm=: 4 : 0
clr 0
if. -.(isiu y) *. (isbx x) do. errret ISI08 return. end.
if. -.y e.CHALL do. errret ISI03 return. end.
if. 2>#x do. errret ISI08 return. end.
sql=. dltb utf8 ,0{::x
if. -.(iscl sql) do. errret ISI08 return. end.
if. ''-:table=. 0{:: tp=. parsesqlparm sql do. errret ISI08 return. end.
if. tp ~:&# x do. errret ISI08 return. end.
sql2=. 'select ', (}. ; (<',') ,&.> (}.tp)), ' from ', table, ' limit 0'
if. SQL_ERROR-: z=. y ddcoltype~ sql2 do. z return. end.
if. (<SQL_ERROR)-: {.z do. z return. end.
'oty ty lns'=. |: _3]\;8 13 9{("1) z=. 1&{::^:UseErrRet z
a=. (2 131072 262144 e.~ 3!:0)&> x1=. }.x
b=. (2>(#@$))&> x1
if. 1 e. r=. a *. b do.
  x=. (,:@:,&.> (1+I.r){x) (1+I.r)}x
end.
y ddparm~ (<|:oty,.lns,.ty) ,&.(1&|.) x
)

NB.* ddparm v
NB. parameterised query (no rows returned),  useful for insert/update blob
NB. (sql;((sqltype1, sqltype2, sqltype3) ., len1 , len2, len3);param1;param2;parm3) ddparm ch
NB. (sql;(sqltype1, sqltype2, sqltype3);param1;param2;parm3) ddparm ch
NB. create a longbinary field for testing because access memo field has max length about 64k
NB.    ch=: ddcon 'dsn=jblob'
NB.    ch ddsql~ 'alter table blobs add column jjbinary longbinary'
NB.    ch ddsql~ 'delete from blobs'
NB.    ch ddparm~ 'insert into blobs (jjname,jjbinary) values (?,?)';(SQL_VARCHAR_jdd_, SQL_LONGVARBINARY_jdd_);'abc';2345678$a.
NB.    sh=: ch ddsel~ 'select jjbinary from blobs where jjname=''abc'''
NB.    (2345678$a.) -: >{.{.ddfet sh, 1
NB.    dddis ch
ddparm=: 4 : 0
clr DDROWCNT=: 0
if. -.(isiu y) *. (isbx x) do. errret ISI08 return. end.
if. -.y e.CHALL do. errret ISI03 return. end.
if. 3>#x do. errret ISI08 return. end.
sql=. dltb utf8 , >0{x
tyln=. >1{x
if. -.(iscl sql) *. (isiu tyln) do. errret ISI08 return. end.
if. 1 e. 2< #@$&> 2}.x do. errret ISI08 return. end.
if. 1 < #@:~. #&> 2}.x do. errret ISI08 return. end.
f=. >x{~ of=. 2
arraysize=. rows=. #f
ty=. ''
if. 2=$$tyln do.
  if. 2=#tyln do.
    'sqlty lns'=. tyln
  elseif. 3=#tyln do.
    'sqlty lns ty'=. tyln
  elseif. do.
    assert. 0
  end.
else.
  sqlty=. tyln [ lns=. (#tyln)#_2 NB. _2 mean undefined, _1 may be reserved for null in the future
end.
if. ''-:ty do.
  try.
    ty=. (odbc_type_table i. sqlty){native_type_table
  catch.
    errret ISI55 return.
  end.
end.

if. (#x) ~: of+#ty do. errret ISI50 return. end.
if. 0=rows do. ret_DD_OK SQL_NO_DATA return. end.

if. ''-:table=. 0{:: tp=. parsesqlparm sql do. errret ISI08 return. end.
if. has_sqlite3_extversion *. (0=+./ ' ,' e. (deb table)) *. ('update'-:6{.sql)+.('insert'-:6{.sql)+.('delete'-:6{.sql) do.
  typ=. gettyp"0 sqlty
  if. _1 e. typ do. errret ISI51 return. end.
  r=. y execparm sql;(}.tp);typ;sqlty;< 2}.x
  return.
end.

loctran=. 0
if. y -.@e. CHTR do.
  if. sqlok SQL_BEGIN transact y do.
    loctran=. 1
  else.
    errret y return.
  end.
end.

if. SQLITE_OK ~: >@{. z=. sql preparestmt y do.
  r=. errret y
  if. loctran do. SQL_ROLLBACK transact y end.
  r return.
end.
sh=. 1{::z
if. (#ty) ~: sqlite3_bind_parameter_count sh do.
  freestmt sh [ r=. errret ISI50
  if. loctran do. SQL_ROLLBACK transact y end.
  r return.
end.

NB. bind column, need erasebind in freestmt/ddend
ncol=. #ty
bytelen=. ''
boxs=. ncol#0

bindname=. 'BIND',(":sh)
assert. 0~: nc <bindname

('BINDN',":sh)=: #ty
('BINDIO',":sh)=: 0        NB. input parametere

ec=. SQLITE_OK
for_i. i.ncol do.
  bname=. 'BIND',(":sh),'_',":i
  bnamel=. 'BINDLN',(":sh),'_',":i
  select. t=. i{ty
  case. SQL_INTEGER do.
    nul=. (0~:IntegerNull) *. IntegerNull= da=. ,(i+of){::x
    nul=. nul +. (0~:NumericNull) *. NumericNull= da
    nr=. #(bname)=: <. 0 (I.nul)}da
    (bnamel)=: nr$IF64{4 8
    (bnamel)=: SQL_NULL_DATA (I. nul)} bnamel~
  case. SQL_DOUBLE do.
    nul=. (0~:NumericNull) *. NumericNull= da=. (1.1-1.1)+ ,(i+of){::x
    nr=. #(bname)=: (1.1-1.1) (I.nul)}da
    (bnamel)=: nr$8
    (bnamel)=: SQL_NULL_DATA (I. nul)} bnamel~
  case. SQL_CHAR;SQL_WCHAR;SQL_VARCHAR;SQL_WVARCHAR;SQL_LONGVARCHAR;SQL_WLONGVARCHAR do.
    if. L. da=. (i+of){::x do.
      if. 0 e. (2 e.~ 3!:0)&> da do.
        ec=. SQL_ERROR break.
      end.
      nr=. #(bname)=: da=. ,da
      boxs=. 1 i}boxs
      (bnamel)=: #&> da
    else.
      if. 2>#@$ da do. da=. ,: ,da end.
      nr=. #(bname)=: da
      lns=. (ls=. {:@$ da) i}lns
NB. incompatible change, rtrim string before inserting
NB.       (bnamel)=: nr$ls
      (bnamel)=: #@dtb"1 (bname)=: utf8"1 da
    end.
  case. SQL_LONGVARBINARY do.
    if. L. da=. (i+of){::x do.
      if. 0 e. (2 e.~ 3!:0)&> da do.
        ec=. SQL_ERROR break.
      end.
      nr=. #(bname)=: da=. ,da
      boxs=. 1 i}boxs
      (bnamel)=: #&> da
    else.
      if. 2>#@$ da do. da=. ,: ,da end.
      nr=. #(bname)=: da
      lns=. (ls=. {:@$ da) i}lns
      (bnamel)=: nr$ls
    end.
  case. SQL_TYPE_DATE;SQL_TYPE_TIME;SQL_TYPE_TIMESTAMP do.
    if. UseDayNo do.
      if. 1 4 8 -.@e.~ 3!:0 da=. (i+of){::x do.
        ec=. SQL_ERROR break.
      end.
      nul=. DateTimeNull= da=. ,da
      da=. isotimestamp 1 tsrep <.86400000* 0 (I.nul)}da
      if. SQL_TYPE_TIMESTAMP= t do. (bname)=: da=. 23{."1 da
      elseif. SQL_TYPE_DATE= t do. (bname)=: da=. 10{."1 da
      elseif. SQL_TYPE_TIME= t do. (bname)=: da=. 11}."1 da
      end.
      lns=. (ls=. {:@$ da) i}lns
      nr=. #da
      (bnamel)=: nr$ls
      (bnamel)=: SQL_NULL_DATA (I. nul)} bnamel~
    else.
      if. 2 131072 262144 -.@e.~ 3!:0 da=. (i+of){::x do.
        ec=. SQL_ERROR break.
      end.
      if. 2>#@$ da do. da=. ,: ,da end.
      if. SQL_TYPE_TIMESTAMP= t do. (bname)=: da=. 23{."1 da
      elseif. SQL_TYPE_DATE= t do. (bname)=: da=. 10{."1 da
      elseif. SQL_TYPE_TIME= t do. (bname)=: da
      end.
      lns=. (ls=. {:@$ da) i}lns
      nr=. #da
      (bnamel)=: nr$ls
      if. 1 e. nul=. (*./"1 e.&' '"1 da) +. (+./"1 '1800-01-01'&E."1 da) +. (+./"1 'NULL'&E."1 da) do.
        (bnamel)=: SQL_NULL_DATA (I. nul)} bnamel~
      end.
    end.
  case. do.
    freestmt sh [ r=. errret ISI51
    if. loctran do. SQL_ROLLBACK transact y end.
    r return.
  end.
end.
if. (SQLITE_OK) -.@e.~ ec do.
  freestmt sh [ r=. errret ISI51
  if. loctran do. SQL_ROLLBACK transact y end.
  r return.
end.

rowcnt=. 0
k=. 0
ec=. SQLITE_OK
while. k<rows do.
  for_i. i.ncol do.
    bname=. 'BIND',(":sh),'_',":i
    bnamel=. 'BINDLN',(":sh),'_',":i
NB. sqlite3_column... start from 0 ; sqlite_bind_.. start from 1
    if. SQL_NULL_DATA = klen=. k{bnamel~ do.
      ec=. sqlite3_bind_null sh;(>:i)
    else.
      select. t=. i{ty
      case. SQL_INTEGER do.
        ec=. sqlite3_bind_int`sqlite3_bind_int64@.IF64 sh;(>:i);k{bname~
      case. SQL_DOUBLE do.
        ec=. sqlite3_bind_double sh;(>:i);k{bname~
      case. SQL_CHAR;SQL_WCHAR;SQL_VARCHAR;SQL_WVARCHAR do.
NB. incompatible change, rtrim string before inserting
NB.         ec=. sqlite3_bind_text sh;(>:i);(utf8 ,>k{bname~);_1;SQLITE_TRANSIENT
        ec=. sqlite3_bind_text sh;(>:i);(,>k{bname~);klen;SQLITE_TRANSIENT
      case. SQL_LONGVARCHAR;SQL_WLONGVARCHAR do.
        blob=. ,>k{bname~
        ec=. sqlite3_bind_text sh;(>:i);blob;(#blob);SQLITE_TRANSIENT
      case. SQL_LONGVARBINARY do.
        if. #blob=. ,>k{bname~ do.
          ec=. sqlite3_bind_blob sh;(>:i);blob;(#blob);SQLITE_TRANSIENT
        else.
          ec=. sqlite3_bind_zeroblob sh;(>:i);_1
        end.
      case. SQL_TYPE_DATE;SQL_TYPE_TIME;SQL_TYPE_TIMESTAMP do.
        ec=. sqlite3_bind_text sh;(>:i);(utf8 ,>k{bname~);klen;SQLITE_TRANSIENT
      case. do.
        assert. 0
      end.
    end.
    if. SQLITE_OK~:ec do. break. end.
  end.
  if. SQLITE_OK~:ec do. break. end.
  if. (SQLITE_OK,SQLITE_DONE) -.@e.~ ec=. sqlite3_step sh do. break. end.
  rowcnt=. rowcnt + sqlite3_changes y
  if. SQLITE_OK~:ec=. sqlite3_reset sh do. break. end.
  k=. >:k
end.
if. (SQLITE_OK,SQLITE_DONE) -.@e.~ ec do.
  freestmt sh [ r=. errret y
  if. loctran do. SQL_ROLLBACK transact y end.
  r return.
end.
assert. k=rows
DDROWCNT=: rowcnt
freestmt sh
if. loctran do. SQL_COMMIT transact y end.
ret_DD_OK DD_OK
)

NB. execparm

NB. =========================================================
NB.*execparm v execute parameterized query
execparm=: 4 : 0
'sel nms typ oty dat'=. y
ch=. x
rws=. #0 pick dat
val=. (<"1 typ,.oty) fixparm each dat
if. 1 e. a:&-:&>val do.
  errret ISI10
  return.
end.
rc=. sqlite3_exec_values ch;sel;rws;(#typ);typ;(#&>val);;val
if. 0~:rc do.
  errret ISI10
  return.
end.
ret_DD_OK DD_OK
)

NB. =========================================================
NB.*fixparm v fix data for parm exec
NB. fix data for write
fixparm=: 4 : 0
'x x0'=. x
t=. 3!:0 y
if. x=1 do.
  if. NumericNull e. ,y do.
    t=. 3!:0 y=. <. IntegerNull (I. NumericNull=,y)},y
  end.
  if. t e. 1 4 do. (2+IF64) (3!:4) (-~2)&+ ,y else. a: end. return.
end.
if. x=2 do.
  if. t e. 1 4 8 do. 2 (3!:5) (-~1.5)&+ ,y else. a: end. return.
end.
if. x=3 do.
  if. x0 -.@e. SQL_TYPE_DATE,SQL_TYPE_TIME,SQL_TYPE_TIMESTAMP do.
    if. 32=t do.
      if. 0 e. 2 = 3!:0 &> y do. a: return. end.
      ; (,&({.a.))@dtb&.> y return.
    elseif. 2=t do.
      ; (,&({.a.))@dtb&.> <"1 y return.
    elseif. do.
      a: return.
    end.
  else.
    if. UseDayNo do.
      if. 1 4 8 -.@e.~ 3!:0 da=. y do.
        a: return.
      end.
      nul=. DateTimeNull= da=. ,da
      da=. isotimestamp 1 tsrep <.86400000* 0 (I.nul)}da
      if. SQL_TYPE_TIMESTAMP= t do. da=. 23{."1 da
      elseif. SQL_TYPE_DATE= t do. da=. 10{."1 da
      elseif. SQL_TYPE_TIME= t do. da=. 11}."1 da
      end.
    else.
      if. 2 131072 262144 -.@e.~ 3!:0 da=. y do.
        a: return.
      end.
      if. 2>#@$ da do. da=. ,: ,da end.
      nul=. (*./"1 e.&' '"1 da) +. (+./"1 '1800-01-01'&E."1 da) +. (+./"1 'NULL'&E."1 da)
      if. SQL_TYPE_TIMESTAMP= t do. da=. 23{."1 da
      elseif. SQL_TYPE_DATE= t do. da=. 10{."1 da
      elseif. SQL_TYPE_TIME= t do. da
      end.
    end.
    if. #nul do.
      if. (#SQLITE_NULL_TEXT)>{:@$da do.
        da=. (#SQLITE_NULL_TEXT){."1 da
      end.
      da=. (({:@$da){.SQLITE_NULL_TEXT) (I. nul)} da
    end.
    ; (,&({.a.))@dtb&.> <"1 da return.
  end.
end.
if. x=4 do.
  if. 32=t do.
    if. 0 e. 2 = 3!:0 &> y do. a: return. end.
    (2 (3!:4) # &> y),;y
  elseif. 2=t do.
    if. 2>$$y do. n1=. 1 else. n1=. {.@$ y end.
    (2 (3!:4) n1#{:@$y), ,y
  elseif. do.
    a:
  end.
  return.
end.
a:
)

NB. types: 1 int 2 float 3 text 4 blob
gettyp=: 3 : 0
select. y
case. SQL_INTEGER do. 1
case. SQL_DOUBLE do. 2
case. SQL_CHAR;SQL_WCHAR;SQL_VARCHAR;SQL_WVARCHAR;SQL_LONGVARCHAR;SQL_WLONGVARCHAR do. 3
case. SQL_LONGVARBINARY do. 4
case. SQL_TYPE_DATE;SQL_TYPE_TIME;SQL_TYPE_TIMESTAMP do. 3
case. do. _1
end.
)

