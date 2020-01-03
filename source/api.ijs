NB. api

3 : 0''
fnd=. 0
if. -. (USEJSQLITE"_)^:(0=4!:0<'USEJSQLITE') 0 do.
NB. default not using libjsqlite3
elseif. UNAME-:'Android' do.
  arch=. LF-.~ 2!:0'getprop ro.product.cpu.abi'
  if. IF64 < arch-:'arm64-v8a' do.
    arch=. 'armeabi-v7a'
  elseif. IF64 < arch-:'x86_64' do.
    arch=. 'x86'
  end.
  t=. (jpath'~bin/../libexec/android-libs/',arch,'/libjsqlite3.so')
  fnd=. 0-.@-:(t, ' sqlite3_extversion > ',(IFWIN#'+'),' x')&cd ::0: ''
elseif. do.
  ext=. (('Darwin';'Linux') i. <UNAME) pick ;:'dylib so dll'
  t=. 'libjsqlite3',((-.IF64)#'_32'),'.',ext
  if. 0-.@-:(t, ' sqlite3_extversion > ',(IFWIN#'+'),' x')&cd ::0: '' do.
    fnd=. 1
  else.
NB. retry in addons folder
    t=. jpath '~addons/data/sqlite/lib/libjsqlite3',((-.IF64)#'_32'),'.',ext
    fnd=. 0-.@-:(t, ' sqlite3_extversion > ',(IFWIN#'+'),' x')&cd ::0: ''
  end.
end.
if. fnd do.
  libsqlite=: t
else.
  if. IFUNIX do.
    libsqlite=: unxlib 'sqlite3'
    if. 'Darwin'-:UNAME do.
      if. fexist t=. '/opt/local/lib/libsqlite3.dylib' do.
        libsqlite=: t
      end.
    end.
  else.
    libsqlite=: 'sqlite3.dll'
  end.
end.
i.0 0
)

NB. CAPI3REF: Fundamental Datatypes
SQLITE_INTEGER=: 1
SQLITE_FLOAT=: 2
SQLITE_TEXT=: SQLITE3_TEXT=: 3
SQLITE_BLOB=: 4
SQLITE_NULL=: 5

NB. CAPI3REF: Result Codes
SQLITE_OK=: 0            NB. Successful result
SQLITE_ERROR=: 1         NB. SQL error or missing database
SQLITE_INTERNAL=: 2      NB. Internal logic error in SQLite
SQLITE_PERM=: 3          NB. Access permission denied
SQLITE_ABORT=: 4         NB. Callback routine requested an abort
SQLITE_BUSY=: 5          NB. The database file is locked
SQLITE_LOCKED=: 6        NB. A table in the database is locked
SQLITE_NOMEM=: 7         NB. A malloc() failed
SQLITE_READONLY=: 8      NB. Attempt to write a readonly database
SQLITE_INTERRUPT=: 9     NB. Operation terminated by sqlite3_interrupt()
SQLITE_IOERR=: 10        NB. Some kind of disk I/O error occurred
SQLITE_CORRUPT=: 11      NB. The database disk image is malformed
SQLITE_NOTFOUND=: 12     NB. Unknown opcode in sqlite3_file_control()
SQLITE_FULL=: 13         NB. Insertion failed because database is full
SQLITE_CANTOPEN=: 14     NB. Unable to open the database file
SQLITE_PROTOCOL=: 15     NB. Database lock protocol error
SQLITE_EMPTY=: 16        NB. Database is empty
SQLITE_SCHEMA=: 17       NB. The database schema changed
SQLITE_TOOBIG=: 18       NB. String or BLOB exceeds size limit
SQLITE_CONSTRAINT=: 19   NB. Abort due to constraint violation
SQLITE_MISMATCH=: 20     NB. Data type mismatch
SQLITE_MISUSE=: 21       NB. Library used incorrectly
SQLITE_NOLFS=: 22        NB. Uses OS features not supported on host
SQLITE_AUTH=: 23         NB. Authorization denied
SQLITE_FORMAT=: 24       NB. Auxiliary database format error
SQLITE_RANGE=: 25        NB. 2nd parameter to sqlite3_bind out of range
SQLITE_NOTADB=: 26       NB. File opened that is not a database file
SQLITE_ROW=: 100         NB. sqlite3_step() has another row ready
SQLITE_DONE=: 101        NB. sqlite3_step() has finished executing

NB. CAPI3REF: Flags For File Open Operations
SQLITE_OPEN_READONLY=: 16b00000001
SQLITE_OPEN_READWRITE=: 16b00000002
SQLITE_OPEN_CREATE=: 16b00000004
SQLITE_OPEN_NOMUTEX=: 16b00008000
SQLITE_OPEN_FULLMUTEX=: 16b00010000
SQLITE_OPEN_SHAREDCACHE=: 16b00020000
SQLITE_OPEN_PRIVATECACHE=: 16b00040000

NB. CAPI3REF: File Locking Levels
SQLITE_LOCK_NONE=: 0
SQLITE_LOCK_SHARED=: 1
SQLITE_LOCK_RESERVED=: 2
SQLITE_LOCK_PENDING=: 3
SQLITE_LOCK_EXCLUSIVE=: 4

NB. CAPI3REF: Text Encodings
SQLITE_UTF8=: 1
SQLITE_UTF16LE=: 2
SQLITE_UTF16BE=: 3
SQLITE_UTF16=: 4            NB. Use native byte order
SQLITE_ANY=: 5              NB. sqlite3_create_function only
SQLITE_UTF16_ALIGNED=: 8    NB. sqlite3_create_collation only

SQLITE_STATIC=: 0
SQLITE_TRANSIENT=: _1

NB. =========================================================
NB. standard sqlite:
lib=. '"',libsqlite,'"'

sqlite3_bind_blob=: (lib, ' sqlite3_bind_blob > ',(IFWIN#'+'),' i x i *c i x' ) &cd
sqlite3_bind_double=: (lib, ' sqlite3_bind_double > ',(IFWIN#'+'),' i x i d' ) &cd
sqlite3_bind_int64=: (lib, ' sqlite3_bind_int64 > ',(IFWIN#'+'),' i x i x' ) &cd
sqlite3_bind_int=: (lib, ' sqlite3_bind_int > ',(IFWIN#'+'),' i x i i' ) &cd
sqlite3_bind_null=: (lib, ' sqlite3_bind_null > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_bind_parameter_count=: (lib, ' sqlite3_bind_parameter_count > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_bind_text=: (lib, ' sqlite3_bind_text > ',(IFWIN#'+'),' i x i *c i x' ) &cd
sqlite3_bind_zeroblob=: (lib, ' sqlite3_bind_zeroblob > ',(IFWIN#'+'),' i x i i' ) &cd
sqlite3_busy_timeout=: (lib, ' sqlite3_busy_timeout > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_changes=: (lib, ' sqlite3_changes > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_close=: (lib, ' sqlite3_close > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_column_blob=: (lib, ' sqlite3_column_blob > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_bytes=: (lib, ' sqlite3_column_bytes > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_column_count=: (lib, ' sqlite3_column_count > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_column_database_name=: (lib, ' sqlite3_column_database_name > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_decltype=: (lib, ' sqlite3_column_decltype > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_double=: (lib, ' sqlite3_column_double > ',(IFWIN#'+'),' d x i' ) &cd
sqlite3_column_int64=: (lib, ' sqlite3_column_int64 > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_int=: (lib, ' sqlite3_column_int > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_column_name=: (lib, ' sqlite3_column_name > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_origin_name=: (lib, ' sqlite3_column_origin_name > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_table_name=: (lib, ' sqlite3_column_table_name > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_text=: (lib, ' sqlite3_column_text > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_type=: (lib, ' sqlite3_column_type > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_db_handle=: (lib, ' sqlite3_db_handle > ',(IFWIN#'+'),' x x' ) &cd
sqlite3_enable_shared_cache=: (lib, ' sqlite3_enable_shared_cache > ',(IFWIN#'+'),' i i' ) &cd
sqlite3_errcode=: (lib, ' sqlite3_errcode > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_errmsg=: (lib, ' sqlite3_errmsg > ',(IFWIN#'+'),' x x' ) &cd
sqlite3_exec=: (lib, ' sqlite3_exec   ',(IFWIN#'+'),' i x *c x x *x' ) &cd
sqlite3_extended_result_codes=: (lib, ' sqlite3_extended_result_codes > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_finalize=: (lib, ' sqlite3_finalize > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_free=: (lib, ' sqlite3_free > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_free_table=: (lib, ' sqlite3_free_table > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_get_autocommit=: (lib, ' sqlite3_get_autocommit > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_get_table=: (lib, ' sqlite3_get_table > ',(IFWIN#'+'),' i x *c *x *i *i *x' ) &cd
sqlite3_initialize=: (lib, ' sqlite3_initialize > ',(IFWIN#'+'),' i') &cd
sqlite3_last_insert_rowid=: (lib, ' sqlite3_last_insert_rowid > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_libversion=: (lib, ' sqlite3_libversion > ',(IFWIN#'+'),' x' ) &cd
sqlite3_libversion_number=: (lib, ' sqlite3_libversion_number > ',(IFWIN#'+'),' i' ) &cd
sqlite3_open=: (lib, ' sqlite3_open   ',(IFWIN#'+'),' i *c *x' ) &cd
sqlite3_open_v2=: (lib, ' sqlite3_open_v2   ',(IFWIN#'+'),' i *c *x i *c' ) &cd
sqlite3_prepare=: (lib, ' sqlite3_prepare   ',(IFWIN#'+'),' i x *c i *x *x' ) &cd
sqlite3_prepare_v2=: (lib, ' sqlite3_prepare_v2   ',(IFWIN#'+'),' i x *c i *x *x' ) &cd
sqlite3_reset=: (lib, ' sqlite3_reset > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_shutdown=: (lib, ' sqlite3_shutdown > ',(IFWIN#'+'),' i') &cd
sqlite3_step=: (lib, ' sqlite3_step > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_table_column_metadata=: (lib, ' sqlite3_table_column_metadata   ',(IFWIN#'+'),' i x *c *c *c *x *x *i *i *i' ) &cd
sqlite3_total_changes=: (lib, ' sqlite3_total_changes > ',(IFWIN#'+'),' i x' ) &cd

NB. =========================================================
NB. sqlite extensions:
sqlite3_extopen=: (lib, ' sqlite3_extopen ',(IFWIN#'+'),' i *c *x i x d *c *c' ) &cd
sqlite3_extversion=: (lib, ' sqlite3_extversion > ',(IFWIN#'+'),' x') &cd
sqlite3_exec_values=: (lib, ' sqlite3_exec_values > ',(IFWIN#'+'),' i x *c i i *i *i *c') &cd
sqlite3_free_values=: (lib, ' sqlite3_free_values > ',(IFWIN#'+'),' i *') &cd
sqlite3_read_values0=: (lib, ' readvalues ',(IFWIN#'+'),' i x *') &cd
sqlite3_read_values=: (lib, ' sqlite3_read_values ',(IFWIN#'+'),' i x *c *') &cd
sqlite3_select_values=: (lib, ' sqlite3_select_values ',(IFWIN#'+'),' i x *c * i *i *i *c') &cd

4!:55 <'lib'

NB. stock android libsqlite.so did not compiled with the SQLITE_ENABLE_COLUMN_METADATA
3 : 0''
has_sqlite3_extversion=: 107 <: sqlite3_extversion ::0: ''
if. (IFIOS +. UNAME-:'Android')>has_sqlite3_extversion do.
  sqlite3_column_database_name=: 0:
  sqlite3_column_origin_name=: 0:
  sqlite3_column_table_name=: 0:
  sqlite3_table_column_metadata=: 1:
end.
EMPTY
)
