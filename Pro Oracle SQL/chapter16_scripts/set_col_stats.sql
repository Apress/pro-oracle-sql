exec dbms_stats.set_column_stats(ownname => '&owner', tabname => '&table_name', colname => '&col_name', distcnt => &NDV, density => &density, nullcnt => &nullcnt, no_invalidate => false);
/*
PROCEDURE SET_COLUMN_STATS
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 OWNNAME                        VARCHAR2                IN
 TABNAME                        VARCHAR2                IN
 COLNAME                        VARCHAR2                IN
 PARTNAME                       VARCHAR2                IN     DEFAULT
 STATTAB                        VARCHAR2                IN     DEFAULT
 STATID                         VARCHAR2                IN     DEFAULT
 DISTCNT                        NUMBER                  IN     DEFAULT
 DENSITY                        NUMBER                  IN     DEFAULT
 NULLCNT                        NUMBER                  IN     DEFAULT
 SREC                           RECORD                  IN     DEFAULT
   EPC                          NUMBER                  IN     DEFAULT
   MINVAL                       RAW(2000)               IN     DEFAULT
   MAXVAL                       RAW(2000)               IN     DEFAULT
   BKVALS                       DBMS_STATS              IN     DEFAULT
   NOVALS                       DBMS_STATS              IN     DEFAULT
   CHVALS                       DBMS_STATS              IN     DEFAULT
   EAVS                         NUMBER                  IN     DEFAULT
 AVGCLEN                        NUMBER                  IN     DEFAULT
 FLAGS                          NUMBER                  IN     DEFAULT
 STATOWN                        VARCHAR2                IN     DEFAULT
 NO_INVALIDATE                  BOOLEAN                 IN     DEFAULT
 FORCE                          BOOLEAN                 IN     DEFAULT
*/
