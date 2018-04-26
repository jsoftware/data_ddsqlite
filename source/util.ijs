NB. util

NB. The odbc locale is designed to be independent of the contents of
NB. the (z) locale.  Hence there will be a few utilities that overlap
NB. the standard utilities that are loaded in the (z) locale.

SZI=: IF64{4 8     NB. sizeof integer - 4 for 32 bit and 8 for 64 bit
SFX=: >IF64{'32';'64'

NB. handy ddl argument utils
b0=: <"0
bs=: ];#

NB. bits to index #'s

NB. first atom - the dll interface likes pure atoms
fat=: ''&$@:,

NB. convert to lower case
tolower=: 3 : '(y i.~''ABCDEFGHIJKLMNOPQRSTUVWXYZ'',a.){''abcdefghijklmnopqrstuvwxyz'',a.'

NB. trim leading and trailing blanks
alltrim=: ] #~ [: -. [: (*./\. +. *./\) ' '&=

NB. tests of sql dll returns - small ints forced to standard form
src=: ]
sqlbad=: 13 : '(src >{. y) e. DD_ERROR'
sqlok=: 13 : '(src >{. y) e. DD_SUCCESS'

NB. returns 1 if argument is a character list or atom 0 otherwise
iscl=: e.&(2 131072 262144)@(3!:0) *. 1: >: [: # $

NB. returns 1 if argument is an atom 0 otheXrwise
isua=: 0: = [: # $

NB. returns 1 if argument is integer (booleans accepted) 0 otherwise
isiu=: 3!:0 e. 1 4"_

NB. returns 1 if argument is an integer atom 0 otherwise
isia=: isua *. isiu

NB. convert short integer columns to integer columns
ifs=: [: ,. [: _1&ic ,

NB. convert 4 bit integer columns to 8 bit integer columns (for 64bit)
i64fs=: [: ,. _2 ic 2 ic ,

NB. convert short float columns (real) to double float columns
ffs=: [: ,. [: _1&fc ,

NB. decode C datetime structures
dts=: 13 : '((#y),6) $ _1&ic , 12{."1 y'

NB. format (getlasterror) messages as char lists
fmterr=: [: ; ([: ":&.> ]) ,&.> ' '"_

NB. test all sqlgetdata return codes for a row
badrow=: 13 : '0 e. (src ;{.&> y) e. DD_SUCCESS'

NB. returns 1 if argument is a box 0 otherwise
isbx=: 3!:0 e. 32"_

NB. returns 1 if argument is a character 0 otherwise
isca=: 3!:0 e. 2 131072 262144"_

NB. convert integer to string
cvt2str=: 'a'&,@":

NB. return result assuming no error
sqlres=: 3 : 0
1&{::^:UseErrRet y
)

NB. test if result ok
sqlresok=: 3 : 0
([: -. SQL_ERROR&-:)`(SQLITE_OK = >@{.)@.UseErrRet y
)

NB. return success
ret_DD_OK=: 3 : 0
if. UseErrRet do. (<DD_OK), <y else. if. y do. y else. DD_OK end. end.
)

NB. translate sh to its ch
sh_to_ch=: 3 : 0
if. y e. shs=. 1{"1 CSPALL do.
  if. 2{CSPALL{~ y i.~ shs do. _1 return. end.   NB. defunct
end.
NB. (shs i.y) { 0{"1 CSPALL
NB. use sqlite api
sqlite3_db_handle y
)

NB. =========================================================
fmtfch=: >`(,.@:,)@.(1 4 8 e.~ 3!:0)

fmtfchres=: 3 : 0
if. UseErrRet do.
  if. sqlresok y do. y=. ({.y), fmtfch&.>&.>{:y end.
else.
  fmtfch&.> y
end.
)

NB. =========================================================
NB. helper verb to get number in string 'varchar(123)'
declchar=: 3 : 0
s=. (}.~ i.&'(') y
(z;0){::~ ''-: z=. 0 ". ({.~ i.&')') }.s
)

NB. =========================================================
NB. 'data_type type_name col_size'=. parse_sqlite_typename typenamex
parse_sqlite_typename=: 3 : 0
ly=. tolower type_name=. y
if. 1 e. 'int' E. ly do. aff=. 'int'
elseif. (1 e. 'char' E. ly) +. (1 e. 'clob' E. ly) +. (1 e. 'text' E. ly) do. aff=. 'text'
elseif. 1 e. 'blob' E. ly do. aff=. 'none'
elseif. (1 e. 'real' E. ly) +. (1 e. 'flo' E. ly) +. (1 e. 'doub' E. ly) +. (1 e. 'real' E. ly) do. aff=. 'real'
elseif. do. aff=. 'numeric'
end.
col_size=. 0
if. aff-:'int' do. col_size=. IF64{4 8
elseif. (<aff) e. 'text';'none' do. col_size=. declchar ly
elseif. (<aff) e. 'real';'numeric' do. col_size=. 8
end.
if. aff -: 'int' do. data_type=. SQL_INTEGER
elseif. aff -: 'text' do. data_type=. (0=col_size){::SQL_WVARCHAR,SQL_WLONGVARCHAR
elseif. aff -: 'none' do. data_type=. SQL_LONGVARBINARY
elseif. aff -: 'real' do. data_type=. SQL_DOUBLE
elseif. 'numeric'-:aff do.
  if. 1 e. 'timestamp' E. ly do. data_type=. SQL_TYPE_TIMESTAMP [ col_size=. 23
  elseif. 1 e. 'datetime' E. ly do. data_type=. SQL_TYPE_TIMESTAMP [ col_size=. 23
  elseif. 1 e. 'date' E. ly do. data_type=. SQL_TYPE_DATE [ col_size=. 10
  elseif. 1 e. 'time' E. ly do. data_type=. SQL_TYPE_TIME [ col_size=. 13
  elseif. do. data_type=. SQL_DOUBLE
  end.
end.
data_type ; type_name ; col_size
)

NB. =========================================================
NB. 'buflen char_octlen radix sql_data_type sub'=. guess_sqlite_buffer data_type; col_size
guess_sqlite_buffer=: 3 : 0
sub=. 0
'ty sz'=. y
char_octlen=. 0 [ radix=. 0 [ sql_data_type=. ty
select. ty
case. SQL_DOUBLE do. buflen=. 8 [ radix=. 10
case. SQL_INTEGER do. buflen=. IF64{4 8 [ radix=. 10 [ char_octlen=. 0
case. SQL_LONGVARBINARY do. buflen=. sz [ char_octlen=. sz
case. SQL_LONGVARCHAR do. buflen=. sz [ char_octlen=. sz
case. SQL_TYPE_DATE do. buflen=. 10 [ sql_data_type=. SQL_DATE [ sub=. 1
case. SQL_TYPE_TIME do. buflen=. 13 [ sql_data_type=. SQL_TIME [ sub=. 2
case. SQL_TYPE_TIMESTAMP do. buflen=. 23 [ sql_data_type=. SQL_DATETIME [ sub=. 3
case. SQL_VARCHAR do. buflen=. sz [ char_octlen=. sz
case. SQL_WLONGVARCHAR do. buflen=. sz [ char_octlen=. sz
case. SQL_WVARCHAR do. buflen=. 4*sz [ char_octlen=. 4*sz
case. do. 13!:8[3
end.
buflen, char_octlen, radix, sql_data_type, sub
)

NB. =========================================================
NB. download and install sqlite3 dll for windows
install=: 3 : 0
if. -. IFWIN do. return. end.
require 'pacman'
for_lib. <;._1 ' sqlite3.dll sqlite3.exe' do.
  'rc p'=. httpget_jpacman_ 'http://www.jsoftware.com/download/', z=. 'winlib/',(IF64{::'x86';'x64'),'/',,>lib
  if. rc do.
    smoutput 'unable to download: ',z return.
  end.
  (<jpath'~bin/',>lib) 1!:2~ 1!:1 <p
  1!:55 ::0: <p
end.
smoutput 'done'
EMPTY
)

