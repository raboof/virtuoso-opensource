#!/bin/sh
#
#  $Id$
#
#  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
#  project.
#
#  Copyright (C) 1998-2021 OpenLink Software
#
#  This project is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation; only version 2 of the License, dated June 1991.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#

# ----------------------------------------------------------------------
#  Fix issues with LOCALE
# ----------------------------------------------------------------------
LANG=C
LC_ALL=POSIX
export LANG LC_ALL

MODE=$1
LOGDIR=`pwd`
VERSION="1.0.0"
LOGFILE="${LOGDIR}/vad_make.log"
STICKER_DAV="vad_dav.xml"
STICKER_FS="vad_filesystem.xml"
PACKDATE=`date +"%Y-%m-%d %H:%M"`
SERVER=${SERVER-virtuoso}
THOST=${THOST-localhost}
PORT=${PORT-1940}
TPORT=${TPORT-`expr $PORT + 1000`}
ISQL=${ISQL-isql}
VAD_NAME="ods_briefcase"
VAD_DAV="$VAD_NAME"_dav.vad
VAD_FS="$VAD_NAME"_filesystem.vad
DSN="$HOST:$PORT"
HOST_OS=`uname -s | grep WIN`
NEED_VERSION=05.09.3035

if [ "x$HOST_OS" != "x" ]
then
  TEMPFILE="`cygpath -m $TMP/isql.$$`"
  if [ "x$SRC" != "x" ]
  then
    HOME=$SRC
  else
    HOME="`cygpath -m $HOME`"
  fi
  LN="cp -rf"
  RM="rm -rf"
else
  TEMPFILE=/tmp/isql.$$
  LN="ln -fs"
  RM="rm -f"
fi

if [ "z$SERVER" = "z" ]  
then
    if [ "x$HOST_OS" != "x" ]
    then
	SERVER=virtuoso-odbc-t.exe
    else
	SERVER=virtuoso
    fi
fi


if [ "z$SERVER" = "z" ]  
then
    if [ "x$HOST_OS" != "x" ]
    then
	SERVER=virtuoso-odbc-t.exe
    else
	SERVER=virtuoso
    fi
fi


rm -rf vad

. $HOME/binsrc/tests/suite/test_fn.sh

if [ -f /usr/xpg4/bin/rm ]
then
  myrm=/usr/xpg4/bin/rm
else
  myrm=$RM
fi


VOS=0
if [ -f ../../autogen.sh ]
then
    VOS=1
fi

version_init()
{
  if [ $VOS -eq 1 ]
  then
      if [ -f vad_version ]
      then
	  VERSION=`cat vad_version`
      else
        LOG "The vad_version does not exist, please verify your checkout"
	exit 1
      fi
  else
      rm -f version.tmp
      for i in `find . -name 'Entries' | grep -v "vad/" | grep -v "/tests/"`; do
	  cat "$i" | grep -v "version\."| grep "^[^D].*" | cut -f 3 -d "/" | sed -e "s/1\.//g" >> version.tmp
      done
      LANG=POSIX
      export LANG

      BASE="0"
#      echo $BASE
      if [ -f version.base ] ; then
	  BASE=`cat version.base`
      fi

      VERSION=`cat version.tmp | awk ' BEGIN { cnt=10 } { cnt = cnt + $1 } END { print cnt }'`

      VERSION=`expr $BASE + $VERSION`
      CURR_VERSION=$VERSION
      if [ -f version.curr ] ; then
	  CURR_VERSION=`cat version.curr`
      fi
      if [ $CURR_VERSION -gt $VERSION ] ; then
	  BASE=`expr $CURR_VERSION - $VERSION + 1`
	  echo $BASE > version.base
	  VERSION=$CURR_VERSION
      fi
      echo $VERSION > version.curr
      VERSION=`echo $VERSION | awk ' { printf "1.%02.02f", $1/100 }'`
      rm -f version.tmp
      echo "$VERSION" > vad_version
  fi
}

virtuoso_start() {
    timeout=120

    ECHO "Starting Virtuoso server ..."
    if [ "z$HOST_OS" != "z" ]
    then
	"$SERVER" +foreground &

	starth=`date | cut -f 2 -d :`
	starts=`date | cut -f 3 -d :|cut -f 1 -d " "`

	while true
	do
	    sleep 6
	    if (netstat -an | grep "[\.\:]$PORT" | grep LISTEN > /dev/null)
	    then
		break
	    fi
	    nowh=`date | cut -f 2 -d :`
	    nows=`date | cut -f 3 -d : | cut -f 1 -d " "`

	    nowh=`expr $nowh - $starth`
	    nows=`expr $nows - $starts`

	    nows=`expr $nows + $nowh \*  60`
	    if test $nows -ge $timeout
	    then
		ECHO "***FAILED: Could not start Virtuoso Server within $timeout seconds"
		exit 1
	    fi
	done
    else
	"$SERVER" +wait
	if test $? -ne 0
	then
	    ECHO "***FAILED: Could not start Virtuoso Server"
	    exit 1
        fi
    fi

    ECHO "Virtuoso server started"
    return 0
}

do_command_safe () {
  _dsn=$1
  command=$2
  shift
  shift
  echo "+ " $ISQL $_dsn dba dba ERRORS=STDOUT VERBOSE=OFF PROMPT=OFF "EXEC=$command" $*	>> $LOGFILE
  if [ "x$HOST_OS" != "x" -a "z$BUILD" != "z" ]
	then
	  $BUILD/../bin/isql.exe $_dsn dba dba ERRORS=STDOUT VERBOSE=OFF PROMPT=OFF "EXEC=$command" $* > "${LOGFILE}.tmp"
	else
	  $ISQL $_dsn dba dba ERRORS=STDOUT VERBOSE=OFF PROMPT=OFF "EXEC=$command" $* > "${LOGFILE}.tmp"
	fi
  if test $? -ne 0
  then
    LOG "***FAILED: starting $command"
  else
    if egrep -e '^\*\*\*' "${LOGFILE}.tmp" > /dev/null
    then
      LOG "***FAILED: execution of $command"
      msg=`cat ${LOGFILE}.tmp`
      echo "------------ SQL ERROR -------------"
      echo "$msg"
      echo "------------------------------------"
      echo "------------ SQL ERROR -------------"	>> $LOGFILE
      echo "$msg"	>> $LOGFILE
      echo "------------------------------------"	>> $LOGFILE
    else
      LOG "PASSED: $command"
    fi
  fi
  rm "${LOGFILE}.tmp" 2>/dev/null
}

do_command() {
  _dsn=$1
  command=$2
  shift
  shift
  echo "+ " $ISQL $_dsn dba dba ERRORS=STDOUT VERBOSE=OFF PROMPT=OFF "EXEC=$command" $*	>> $LOGFILE
  $ISQL $_dsn dba dba ERRORS=STDOUT VERBOSE=OFF PROMPT=OFF "EXEC=$command" $* >> $LOGFILE
  if test $? -ne 0
  then
    LOG "***FAILED: $command"
  else
    LOG "PASSED: $command"
  fi
}

directory_clean() {
  $myrm -rf vad 2>/dev/null
  $myrm -rf vad.* 2>/dev/null
  $myrm -rf vad_*.* 2>/dev/null
  $myrm -rf virtuoso.* 2>/dev/null
}

directory_init() {
  mkdir vad
  mkdir vad/data
  mkdir vad/data/oDrive

  for dir in `find new schemas www xslt -type d -print | LC_ALL=C sort | grep -v CVS`
  do
    mkdir vad/data/oDrive/$dir
  done

  for file in `find new schemas www xslt -type f -print | LC_ALL=C sort | grep -v CVS | grep -v '.vspx-m' | grep -v '.vspx-sql'`
  do
    cp $file vad/data/oDrive/$file
  done
}

virtuoso_shutdown() {
  LOG "Shutdown $DSN ..."
  do_command_safe $DSN "shutdown" 2>/dev/null
  sleep 5
}

sticker_init() {
  ISDAV=$1
  if [ "$ISDAV" = "1" ] ; then
    TYPE="dav"
    STICKER=$STICKER_DAV
    BASE_PATH_CODE="/DAV/VAD"
  else
    TYPE="http"
    STICKER=$STICKER_FS
    BASE_PATH_CODE="/vad/vsp"
  fi
  LOG "Briefcase VAD Sticker $STICKER creation..."
  echo "<?xml version=\"1.0\" encoding=\"ASCII\"?>" > $STICKER
  echo "<!DOCTYPE sticker SYSTEM \"vad_sticker.dtd\">" >> $STICKER
  echo "<sticker version=\"1.0.010505A\" xml:lang=\"en-UK\">" >> $STICKER
  echo "<caption>" >> $STICKER
  echo "  <name package=\"Briefcase\">" >> $STICKER
  echo "    <prop name=\"Title\" value=\"ODS Briefcase\"/>" >> $STICKER
  echo "    <prop name=\"Developer\" value=\"OpenLink Software\"/>" >> $STICKER
  echo "    <prop name=\"Copyright\" value=\"(C) 1998-2021 OpenLink Software\"/>" >> $STICKER
  echo "    <prop name=\"Download\" value=\"http://www.openlinksw.com/virtuoso\"/>" >> $STICKER
  echo "    <prop name=\"Download\" value=\"http://www.openlinksw.co.uk/virtuoso\"/>" >> $STICKER
  echo "  </name>" >> $STICKER
  echo "  <version package=\"$VERSION\">" >> $STICKER
  echo "    <prop name=\"Release Date\" value=\"$PACKDATE\" />" >> $STICKER
  echo "    <prop name=\"Build\" value=\"Release, optimized\"/>" >> $STICKER
  echo "  </version>" >> $STICKER
  echo "</caption>" >> $STICKER
  echo "<dependencies>" >> $STICKER
  echo "  <require>" >> $STICKER
  echo "    <name package=\"Framework\"/>" >> $STICKER
  echo "    <versions_later package=\"1.88.99\">" >> $STICKER
  echo "      <prop name=\"Date\" value=\"2012-10-31 12:00\" />" >> $STICKER
  echo "      <prop name=\"Comment\" value=\"An incompatible version of the ODS Framework\" />" >> $STICKER
  echo "    </versions_later>" >> $STICKER
  echo "  </require>" >> $STICKER
  echo "</dependencies>" >> $STICKER
  echo "<procedures uninstallation=\"supported\">" >> $STICKER
  echo "  <sql purpose=\"pre-install\"><![CDATA[" >> $STICKER
  echo "    if (lt (sys_stat ('st_dbms_ver'), '$NEED_VERSION')) " >> $STICKER
  echo "      { " >> $STICKER
  echo "        result ('ERROR', 'The Briefcase package requires server version $NEED_VERSION or greater'); " >> $STICKER
  echo "	      signal ('FATAL', 'The Briefcase package requires server version $NEED_VERSION or greater'); " >> $STICKER
  echo "      } " >> $STICKER
  echo "    if ((VAD_CHECK_VERSION ('oDrive') is not null) and (VAD_CHECK_VERSION ('Briefcase') is null))" >> $STICKER
  echo "      {" >> $STICKER
  echo "        DB.DBA.VAD_RENAME ('oDrive', 'Briefcase');" >> $STICKER
  echo "      }" >> $STICKER
  echo "  ]]></sql>" >> $STICKER
  echo "  <sql purpose=\"post-install\"></sql>" >> $STICKER
  echo "</procedures>" >> $STICKER
  echo "<ddls>" >> $STICKER
  echo "  <sql purpose=\"pre-install\">if (lt (sys_stat ('st_dbms_ver'), '$NEED_VERSION')) { result ('ERROR', 'The conductor package requires server version $NEED_VERSION or greater'); signal ('FATAL', 'The Briefcase package requires server version $NEED_VERSION or greater'); } </sql>" >> $STICKER
  echo "  <sql purpose=\"post-install\">" >> $STICKER
  echo "    <![CDATA[" >> $STICKER
  echo "      if (not exists (select 1 from DB.DBA.SYS_USERS where U_NAME='nobody')) signal ('42VAD', 'This version of Briefcase requires newer version of OpenLink Virtuoso server (at least 4.0 release)');" >> $STICKER
  echo "      registry_set('_oDrive_path_', '"$BASE_PATH_CODE"/oDrive/');" >> $STICKER
  echo "      registry_set('_oDrive_version_', '$VERSION');" >> $STICKER
  echo "      registry_set('_oDrive_build_', '$PACKDATE');" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-a-wa.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-a-ddk.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-a-rdf.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-a-dc.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-a-code.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      -- DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-a-dc-data.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-a-rdf-data.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-a-api.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-a-ods.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-a-update.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/sioc_briefcase.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/DET_GDrive.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/DET_Dropbox.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/DET_SkyDrive.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/DET_Box.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/DET_WebDAV.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/DET_Rackspace.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "    ]]>" >> $STICKER
  echo "  </sql>" >> $STICKER
  echo "  <sql purpose=\"pre-uninstall\">" >> $STICKER
  echo "    <![CDATA[" >> $STICKER
  echo "      DB.DBA.VAD_LOAD_SQL_FILE('"$BASE_PATH_CODE"/oDrive/new/od-d.sql', 1, 'report', $ISDAV);" >> $STICKER
  echo "    ]]>" >> $STICKER
  echo "  </sql>" >> $STICKER
  echo "  <sql purpose=\"post-uninstall\"></sql>" >> $STICKER
  echo "</ddls>" >> $STICKER
  echo "<resources>" >> $STICKER

  for file in `find vad -type f -print | LC_ALL=C sort`
  do
     if echo "$file" | grep -v "\.vsp" >/dev/null
     then
	      perms="110100100NN"
     else
	      perms="111101101NN"
     fi
     name=`echo "$file" | cut -b10-`
     echo "  <file type=\"$TYPE\" overwrite=\"yes\" source=\"data\" target_uri=\"$name\" dav_owner=\"dav\" dav_grp=\"administrators\" dav_perm=\"$perms\" makepath=\"yes\"/>" >> $STICKER
  done

  echo "</resources>" >> $STICKER
  echo "<registry>" >> $STICKER
  echo "</registry>" >> $STICKER
  echo "</sticker>" >> $STICKER
}

virtuoso_init() {
  LOG "Virtuoso.ini creation..."
  echo "
[Database]
DatabaseFile         = vad.db
TransactionFile      = vad.trx
ErrorLogFile         = vad.log
ErrorLogLevel        = 7
FileExtend           = 200
Striping             = 0
LogSegments          = 0
Syslog		           = 0

;
;  Server parameters
;
[Parameters]
ServerPort           = $PORT
ServerThreads        = 100
CheckpointInterval   = 0
NumberOfBuffers      = 2000
MaxDirtyBuffers      = 1200
MaxCheckpointRemap   = 2000
UnremapQuota         = 0
AtomicDive           = 1
PrefixResultNames    = 0
CaseMode             = 2
DisableMtWrite       = 0
MaxStaticCursorRows  = 5000
AllowOSCalls         = 0
DirsAllowed          = .
CallstackOnException = 1

;
; HTTP server parameters
;
; Timeout values are seconds
;

[HTTPServer]
ServerPort           = $TPORT
ServerRoot           = .
ServerThreads        = 5
MaxKeepAlives        = 10
EnabledDavVSP        = 1

[Client]
SQL_QUERY_TIMEOUT    = 0
SQL_TXN_TIMEOUT      = 0
SQL_PREFETCH_ROWS    = 100
SQL_PREFETCH_BYTES   = 16000
SQL_NO_CHAR_C_ESCAPE = 0

[AutoRepair]
BadParentLinks       = 0
BadDTP               = 0

[Replication]
ServerName   = the_big_server
ServerEnable = 1
QueueMax     = 50000

" > virtuoso.ini
  virtuoso_start
}

vad_create() {
  STICKER=$1
  VAD_NAME=$2
  do_command_safe $DSN "DB.DBA.VAD_PACK('$STICKER', '.', '$VAD_NAME')"
  do_command_safe $DSN "commit work"
  do_command_safe $DSN "checkpoint"
}

echo '----------------------'
echo 'Briefcase Application VAD create'
echo '----------------------'

STOP_SERVER
directory_clean
version_init
directory_init
virtuoso_init
if [ "$MODE" = "" ] || [ "$MODE" = "1" ]
then
  sticker_init 1
  vad_create $STICKER_DAV $VAD_DAV
fi
if [ "$MODE" = "" ] || [ "$MODE" = "0" ]
then
  sticker_init 0
  vad_create $STICKER_FS $VAD_FS
fi
virtuoso_shutdown
STOP_SERVER
chmod 644 ods_briefcase_dav.vad
chmod 644 ods_briefcase_filesystem.vad
directory_clean

CHECK_LOG
RUN egrep  '"\*\*.*FAILED:|\*\*.*ABORTED:"' "$LOGFILE"
if test $STATUS -eq 0
then
	$myrm -f *.vad
	exit 1
fi

directory_clean

BANNER "COMPLETED VAD PACKAGING"
exit 0
