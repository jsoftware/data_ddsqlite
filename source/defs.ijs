NB. defs

NB. ISI errors - from C code - will be modified
ISI01=: 'ISI01 Too many connections'  NB. COMPATIBLE no preset ODBC'ing limits
ISI02=: 'ISI02 Too many statements'   NB.  ""
ISI03=: 'ISI03 Bad connection handle'
ISI04=: 'ISI04 Bad statement handle'
ISI05=: 'ISI05 Not a select command'
ISI06=: 'ISI06 Transactions not supported'
ISI07=: 'ISI07 Bad transaction state'
ISI08=: 'ISI08 Bad arguments'         NB. COMPATIBLE #'s > 7 - not in ISI C code
ISI09=: 'ISI09 Unsupported data type'
ISI10=: 'ISI10 Unable to bind all columns'
ISI11=: 'ISI11 Unable to initialize ODBC environment'
ISI12=: 'ISI12 Unable to set 3.x ODBC version'
ISI13=: 'ISI13 SQL errors fetching row'
ISI14=: 'ISI14 Not implemented'
ISI15=: 'ISI15 Driver limitation'
ISI16=: 'ISI16 Shared library error'
ISI17=: 'ISI17 Out of memory'
ISI18=: 'ISI18 Database file not found'
ISI19=: 'ISI19 Unable to open database'
ISI50=: 'ISI50 Incorrect number of columns'
ISI51=: 'ISI51 Incorrect data type'
ISI52=: 'ISI52 Incorrect base table'
ISI53=: 'ISI53 No column in query result'
ISI54=: 'ISI54 Column ordinal number error'
ISI55=: 'ISI55 Unable to map data type to ODBC data type'
ISI56=: 'ISI56 Unable to handle parameterized query'

NB. ODBC selected SQLSTATE codes
SQLST_WARNING=: '01000'

NB. defines from sql.h and sqlext.h -----------------------------------
NB. some of these nouns may be removed and others added in the final version
SQL_SUCCESS=: 0
SQL_SUCCESS_WITH_INFO=: 1
SQL_NO_DATA=: 100
SQL_ERROR=: _1
SQL_INVALID_HANDLE=: _2
SQL_STILL_EXECUTING=: 2
SQL_NEED_DATA=: 99
SQL_MAX_DSN_LENGTH=: 32
SQL_COMMIT=: 0
SQL_ROLLBACK=: 1
SQL_BEGIN=: 2          NB. faked
SQL_NTS=: _3                     NB. null terminated string
SQL_HANDLE_ENV=: 1
SQL_HANDLE_DBC=: 2
SQL_HANDLE_STMT=: 3
SQL_HANDLE_DESC=: 4
SQL_FETCH_NEXT=: 1
SQL_FETCH_FIRST=: 2
SQL_ATTR_ODBC_VERSION=: 200
SQL_OV_ODBC3=: 3
SQL_ATTR_ROW_BIND_TYPE=: 5       NB. SQL_BIND_TYPE
SQL_BIND_BY_COLUMN=: 0           NB. C type 0UL
SQL_ATTR_ROWS_FETCHED_PTR=: 26
SQL_ATTR_ROW_ARRAY_SIZE=: 27
SQL_ATTR_ROW_STATUS_PTR=: 25
SQL_ATTR_AUTOCOMMIT=: 102        NB. SQL_AUTOCOMMIT
SQL_AUTOCOMMIT_OFF=: 0           NB. C type 0UL
SQL_ROWSET_SIZE=: 9
SQL_IS_UINTEGER=: _5

SQL_SIGNED_OFFSET=: _20
SQL_C_CHAR=: 1
SQL_C_DOUBLE=: 8
SQL_C_LONG=: 4
SQL_C_SLONG=: (SQL_C_LONG+SQL_SIGNED_OFFSET)
SQL_C_SHORT=: 5
SQL_C_SSHORT=: (SQL_C_SHORT+SQL_SIGNED_OFFSET)
SQL_C_BINARY=: _2
SQL_C_BIGINT=: _5
SQL_C_SBIGINT=: (SQL_C_BIGINT+SQL_SIGNED_OFFSET)

SQL_ADD=: 4
SQL_ATTR_CURSOR_TYPE=: 6
SQL_CURSOR_DYNAMIC=: 2
SQL_ATTR_CONCURRENCY=: 7
SQL_CONCUR_LOCK=: 2
SQL_PARAM_INPUT=: 1

'UCS2 UCS4 UTF8 OEMCP'=: i.4

NB. Note: setting good buffer sizes can signficantly improve performance.
COLUMNBUF=: 1000     NB. default row size of bound column buffers
LONGBUF=: 500000     NB. default buffer size for long datatypes
SHORTBUF=: 255       NB. default buffer size for short datatypes
MAXARRAYSIZE=: 65535
