NB. api

3 : 0''
fnd=. 0
if. -. (USEJSQLITE"_)^:(0=4!:0<'USEJSQLITE') 0 do.
NB. default not using libjsqlite3
elseif. UNAME-:'Android' do.
  arch=. LF-.~ 2!:0'getprop ro.product.cpu.abi'
  t=. (jpath'~bin/../libexec/android-libs/',arch,'/libjsqlite3.so')
  fnd=. 0-.@-:(t, ' sqlite3_extversion > ',(IFWIN#'+'),' x')&cd ::0: ''
elseif. do.
NB. no 32-bit libjsqlite3 binary for Darwin/Linux except raspberry
  if. -. ((<UNAME) e.'Darwin';'Linux')>IF64+.IFRASPI do.
    ext=. (('Darwin';'Linux') i. <UNAME) pick ;:'dylib so dll'
    t=. 'libjsqlite3',((-.IF64+.IFRASPI)#'_32'),'.',ext
    if. 0-.@-:(t, ' sqlite3_extversion > ',(IFWIN#'+'),' x')&cd ::0: '' do.
      fnd=. 1
    else.
NB. retry in addons folder
      t=. jpath '~addons/data/sqlite/lib/libjsqlite3',((-.IF64+.IFRASPI)#'_32'),'.',ext
      fnd=. 0-.@-:(t, ' sqlite3_extversion > ',(IFWIN#'+'),' x')&cd ::0: ''
    end.
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

sqlite3_bind_blob=: (libsqlite, ' sqlite3_bind_blob > ',(IFWIN#'+'),' i x i *c i x' ) &cd
sqlite3_bind_double=: (libsqlite, ' sqlite3_bind_double > ',(IFWIN#'+'),' i x i d' ) &cd
sqlite3_bind_int64=: (libsqlite, ' sqlite3_bind_int64 > ',(IFWIN#'+'),' i x i x' ) &cd
sqlite3_bind_int=: (libsqlite, ' sqlite3_bind_int > ',(IFWIN#'+'),' i x i i' ) &cd
sqlite3_bind_null=: (libsqlite, ' sqlite3_bind_null > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_bind_parameter_count=: (libsqlite, ' sqlite3_bind_parameter_count > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_bind_text=: (libsqlite, ' sqlite3_bind_text > ',(IFWIN#'+'),' i x i *c i x' ) &cd
sqlite3_bind_zeroblob=: (libsqlite, ' sqlite3_bind_zeroblob > ',(IFWIN#'+'),' i x i i' ) &cd
sqlite3_busy_timeout=: (libsqlite, ' sqlite3_busy_timeout > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_changes=: (libsqlite, ' sqlite3_changes > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_close=: (libsqlite, ' sqlite3_close > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_column_blob=: (libsqlite, ' sqlite3_column_blob > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_bytes=: (libsqlite, ' sqlite3_column_bytes > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_column_count=: (libsqlite, ' sqlite3_column_count > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_column_database_name=: (libsqlite, ' sqlite3_column_database_name > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_decltype=: (libsqlite, ' sqlite3_column_decltype > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_double=: (libsqlite, ' sqlite3_column_double > ',(IFWIN#'+'),' d x i' ) &cd
sqlite3_column_int64=: (libsqlite, ' sqlite3_column_int64 > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_int=: (libsqlite, ' sqlite3_column_int > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_column_name=: (libsqlite, ' sqlite3_column_name > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_origin_name=: (libsqlite, ' sqlite3_column_origin_name > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_table_name=: (libsqlite, ' sqlite3_column_table_name > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_text=: (libsqlite, ' sqlite3_column_text > ',(IFWIN#'+'),' x x i' ) &cd
sqlite3_column_type=: (libsqlite, ' sqlite3_column_type > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_db_handle=: (libsqlite, ' sqlite3_db_handle > ',(IFWIN#'+'),' x x' ) &cd
sqlite3_enable_shared_cache=: (libsqlite, ' sqlite3_enable_shared_cache > ',(IFWIN#'+'),' i i' ) &cd
sqlite3_errcode=: (libsqlite, ' sqlite3_errcode > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_errmsg=: (libsqlite, ' sqlite3_errmsg > ',(IFWIN#'+'),' x x' ) &cd
sqlite3_exec=: (libsqlite, ' sqlite3_exec   ',(IFWIN#'+'),' i x *c x x *x' ) &cd
sqlite3_extended_result_codes=: (libsqlite, ' sqlite3_extended_result_codes > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_finalize=: (libsqlite, ' sqlite3_finalize > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_free=: (libsqlite, ' sqlite3_free > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_free_table=: (libsqlite, ' sqlite3_free_table > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_get_autocommit=: (libsqlite, ' sqlite3_get_autocommit > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_get_table=: (libsqlite, ' sqlite3_get_table > ',(IFWIN#'+'),' i x *c *x *i *i *x' ) &cd
sqlite3_initialize=: (libsqlite, ' sqlite3_initialize > ',(IFWIN#'+'),' i') &cd
sqlite3_last_insert_rowid=: (libsqlite, ' sqlite3_last_insert_rowid > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_libversion=: (libsqlite, ' sqlite3_libversion > ',(IFWIN#'+'),' x' ) &cd
sqlite3_libversion_number=: (libsqlite, ' sqlite3_libversion_number > ',(IFWIN#'+'),' i' ) &cd
sqlite3_open=: (libsqlite, ' sqlite3_open   ',(IFWIN#'+'),' i *c *x' ) &cd
sqlite3_open_v2=: (libsqlite, ' sqlite3_open_v2   ',(IFWIN#'+'),' i *c *x i *c' ) &cd
sqlite3_prepare=: (libsqlite, ' sqlite3_prepare   ',(IFWIN#'+'),' i x *c i *x *x' ) &cd
sqlite3_prepare_v2=: (libsqlite, ' sqlite3_prepare_v2   ',(IFWIN#'+'),' i x *c i *x *x' ) &cd
sqlite3_reset=: (libsqlite, ' sqlite3_reset > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_shutdown=: (libsqlite, ' sqlite3_shutdown > ',(IFWIN#'+'),' i') &cd
sqlite3_step=: (libsqlite, ' sqlite3_step > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_table_column_metadata=: (libsqlite, ' sqlite3_table_column_metadata   ',(IFWIN#'+'),' i x *c *c *c *x *x *i *i *i' ) &cd
sqlite3_total_changes=: (libsqlite, ' sqlite3_total_changes > ',(IFWIN#'+'),' i x' ) &cd

NB. =========================================================
NB. sqlite extensions:
sqlite3_extversion=: (libsqlite, ' sqlite3_extversion > ',(IFWIN#'+'),' x') &cd
sqlite3_free_values=: (libsqlite, ' sqlite3_free_values > ',(IFWIN#'+'),' i *') &cd
sqlite3_read_values=: (libsqlite, ' sqlite3_read_values ',(IFWIN#'+'),' i x *') &cd

NB. stock android libsqlite.so did not compiled with the SQLITE_ENABLE_COLUMN_METADATA
3 : 0''
has_sqlite3_extversion=: 0 -.@-: sqlite3_extversion ::0: ''
if. (IFIOS +. UNAME-:'Android')>has_sqlite3_extversion do.
  sqlite3_column_database_name=: 0:
  sqlite3_column_origin_name=: 0:
  sqlite3_column_table_name=: 0:
  sqlite3_table_column_metadata=: 1:
end.
EMPTY
)
