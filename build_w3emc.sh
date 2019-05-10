#!/bin/sh

 (( $# == 0 )) && {
   echo "*** Usage: $0 wcoss|dell|cray|theia|intel_general|gnu_general [debug|build] [[local]install[only]]"
   exit 1
 }

 sys=${1,,}
 [[ $sys == wcoss || $sys == dell || $sys == cray ||\
    $sys == theia || $sys == intel_general || $sys == gnu_general ]] || {
   echo "*** Usage: $0 wcoss|dell|cray|theia|intel_general|gnu_general [debug|build] [[local]install[only]]"
   exit 1
 }
 debg=false
 inst=false
 skip=false
 local=false
 (( $# > 1 )) && {
   [[ ${2,,} == build ]] && debg=false
   [[ ${2,,} == debug ]] && debg=true
   [[ ${2,,} == install ]] && inst=true
   [[ ${2,,} == localinstall ]] && { local=true; inst=true; }
   [[ ${2,,} == installonly ]] && { inst=true; skip=true; }
   [[ ${2,,} == localinstallonly ]] && { local=true; inst=true; skip=true; }
 }
 (( $# > 2 )) && {
   [[ ${3,,} == build ]] && debg=false
   [[ ${3,,} == debug ]] && debg=true
   [[ ${3,,} == install ]] && inst=true
   [[ ${3,,} == localinstall ]] && { local=true; inst=true; }
   [[ ${3,,} == installonly ]] && { inst=true; skip=true; }
   [[ ${3,,} == localinstallonly ]] && { local=true; inst=true; skip=true; }
 }
 if [[ ${sys} == "intel_general" ]]; then
   sys6=${sys:6}
   source ./Conf/W3emc_${sys:0:5}_${sys6^}.sh
 elif [[ ${sys} == "gnu_general" ]]; then
   sys4=${sys:4}
   source ./Conf/W3emc_${sys:0:3}_${sys4^}.sh
 else
   source ./Conf/W3emc_intel_${sys^}.sh
 fi
 [[ -z $W3EMC_VER || -z $W3EMC_LIB4 ]] && {
   echo "??? W3EMC: module/environment not set."
   exit 1
 }

 source ./Conf/Collect_info.sh
 source ./Conf/Gen_cfunction.sh

set -x
 w3emcLib4=$(basename $W3EMC_LIB4)
 w3emcLib8=$(basename $W3EMC_LIB8)
 w3emcLibd=$(basename $W3EMC_LIBd)
 w3emcInc4=$(basename $W3EMC_INC4)
 w3emcInc8=$(basename $W3EMC_INC8)
 w3emcIncd=$(basename $W3EMC_INCd)

#################
 cd src
#################

 $skip || {
#-------------------------------------------------------------------
# Start building libraries
#
 echo
 echo "   ... build (i4/r4) w3emc library ..."
 echo
   make clean LIB=$w3emcLib4 MOD=$w3emcInc4
   mkdir -p $w3emcInc4
   MPIFFLAGS4="$I4R4 $MPIFFLAGS -I${NEMSIO_INC} -I${SIGIO_INC4} ${MODPATH}$w3emcInc4"
   collect_info w3emc 4 OneLine4 LibInfo4
   w3emcInfo4=w3emc_info_and_log4.txt
   $debg && make debug MPIFFLAGS="$MPIFFLAGS4" LIB=$w3emcLib4 &> $w3emcInfo4 \
         || make build MPIFFLAGS="$MPIFFLAGS4" LIB=$w3emcLib4 &> $w3emcInfo4
   make message MSGSRC="$(gen_cfunction $w3emcInfo4 OneLine4 LibInfo4)" \
                LIB=$w3emcLib4

 echo
 echo "   ... build (i8/r8) w3emc library ..."
 echo
   make clean LIB=$w3emcLib8 MOD=$w3emcInc8
   mkdir -p $w3emcInc8
   MPIFFLAGS8="$I8R8 $MPIFFLAGS -I${NEMSIO_INC} -I${SIGIO_INC4} ${MODPATH}$w3emcInc8"
   collect_info w3emc 8 OneLine8 LibInfo8
   w3emcInfo8=w3emc_info_and_log8.txt
   $debg && make debug MPIFFLAGS="$MPIFFLAGS8" LIB=$w3emcLib8 &> $w3emcInfo8 \
         || make build MPIFFLAGS="$MPIFFLAGS8" LIB=$w3emcLib8 &> $w3emcInfo8
   make message MSGSRC="$(gen_cfunction $w3emcInfo8 OneLine8 LibInfo8)" \
                LIB=$w3emcLib8

 echo
 echo "   ... build (i4/r8) w3emc library ..."
 echo
   make clean LIB=$w3emcLibd MOD=$w3emcIncd
   mkdir -p $w3emcIncd
   MPIFFLAGSd="$I4R8 $MPIFFLAGS -I${NEMSIO_INC} -I${SIGIO_INC4} ${MODPATH}$w3emcIncd"
   collect_info w3emc d OneLined LibInfod
   w3emcInfod=w3emc_info_and_logd.txt
   $debg && make debug MPIFFLAGS="$MPIFFLAGSd" LIB=$w3emcLibd &> $w3emcInfod \
         || make build MPIFFLAGS="$MPIFFLAGSd" LIB=$w3emcLibd &> $w3emcInfod
   make message MSGSRC="$(gen_cfunction $w3emcInfod OneLined LibInfod)" \
                LIB=$w3emcLibd
 }

 $inst && {
#
#     Install libraries and source files 
#
   $local && {
              LIB_DIR4=..
              LIB_DIR8=..
              LIB_DIRd=..
             } || {
                   LIB_DIR4=$(dirname ${W3EMC_LIB4})
                   LIB_DIR8=$(dirname ${W3EMC_LIB8})
                   LIB_DIRd=$(dirname ${W3EMC_LIBd})
                  }
   [ -d $LIB_DIR4 ] || mkdir -p $LIB_DIR4
   [ -d $LIB_DIR8 ] || mkdir -p $LIB_DIR8
   [ -d $LIB_DIRd ] || mkdir -p $LIB_DIRd
   INCP_DIR4=$(dirname $W3EMC_INC4)
   [ -d $W3EMC_INC4 ] && rm -rf $W3EMC_INC4 || mkdir -p $INCP_DIR4
   INCP_DIR8=$(dirname $W3EMC_INC8)
   [ -d $W3EMC_INC8 ] && rm -rf $W3EMC_INC8 || mkdir -p $INCP_DIR8
   INCP_DIRd=$(dirname $W3EMC_INCd)
   [ -d $W3EMC_INCd ] && rm -rf $W3EMC_INCd || mkdir -p $INCP_DIRd
   SRC_DIR=$W3EMC_SRC
   $local && SRC_DIR=
   [ -d $SRC_DIR ] || mkdir -p $SRC_DIR
   make clean LIB=
   make install LIB=$w3emcLib4 MOD=$w3emcInc4 \
                LIB_DIR=$LIB_DIR4 INC_DIR=$INCP_DIR4 SRC_DIR=
   make install LIB=$w3emcLib8 MOD=$w3emcInc8 \
                LIB_DIR=$LIB_DIR8 INC_DIR=$INCP_DIR8 SRC_DIR=
   make install LIB=$w3emcLibd MOD=$w3emcIncd \
                LIB_DIR=$LIB_DIRd INC_DIR=$INCP_DIRd SRC_DIR=$SRC_DIR
 }