#!/bin/bash
#
# tpcdsenv.sh - UNIX Environment Setup
#

#######################################################################
# This is a mandatory parameter. Please provide the location of
# spark installation.
#######################################################################
export SPARK_HOME=

#######################################################################
# Script environment parameters. When they are not set the script
# defaults to paths relative from the script directory.
#######################################################################

export TPCDS_ROOT_DIR=
export TPCDS_LOG_DIR=
export TPCDS_DBNAME=
export TPCDS_WORK_DIR=

export ADDITION_SPARK_OPTIONS=
export SKIP_TABLE_CHECK=false
#######################################################################
# Use beeline to submit benchmark sql.
# By default, use `spark-sql` to submit benchmark tests.
# If you want to use beeline instead of `spark-sql`, please
# set USE_BEELINE=true, and set appropriate values for the remaining
# settings.
#######################################################################
export USE_BEELINE=false
export BEELINE=
export SPARK_HISTORY_SERVER=
