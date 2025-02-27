#!/bin/bash
# Since: March, 2021
# Author: gvenzl
# Name: test_container_1840.sh
# Description: Run container test scripts for Oracle DB XE 18.4.0
#
# Copyright 2021 Gerald Venzl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source ./functions.sh

#######################
###### 18c TESTS ######
#######################

#######################
##### Image tests #####
#######################

runContainerTest "18.4.0 FULL image" "1840-full" "gvenzl/oracle-xe:18.4.0-full"
runContainerTest "18 FULL image" "18-full" "gvenzl/oracle-xe:18-full"

runContainerTest "18.4.0 REGULAR image" "1840" "gvenzl/oracle-xe:18.4.0"
runContainerTest "18 REGULAR image" "18" "gvenzl/oracle-xe:18"

runContainerTest "18.4.0 SLIM image" "1840-slim" "gvenzl/oracle-xe:18.4.0-slim"
runContainerTest "18 SLIM image" "18-slim" "gvenzl/oracle-xe:18-slim"


#################################
##### Oracle password tests #####
#################################

# Provide different password
ORA_PWD="MyTestPassword"
ORA_PWD_CMD="-e ORACLE_PASSWORD=${ORA_PWD}"
# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="18-ora-pwd"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="18.4.0 ORACLE_PASSWORD"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="OK"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-xe:18.4.0"

# Test password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s system/"${ORA_PWD}" <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset ORA_PWD_CMD
unset TEST_NAME

########################################
##### Oracle random password tests #####
########################################

# We want a random password for this test
ORA_PWD_CMD="-e ORACLE_RANDOM_PASSWORD=sure"
# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="18-rand-ora-pwd"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="18.4.0 ORACLE_RANDOM_PASSWORD"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="OK"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-xe:18.4.0"

# Let's get the password
rand_pwd=$(podman logs ${CONTAINER_NAME} | grep "ORACLE PASSWORD FOR SYS AND SYSTEM:" | awk '{ print $7 }')

# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s system/"${rand_pwd}"@//localhost/XEPDB1 <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset ORA_PWD_CMD
unset TEST_NAME

#########################
##### App user test #####
#########################

# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="18-app-user"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="18.4.0 APP_USER & PASSWORD"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="Hi from App User"
# App user
APP_USER="test_app_user"
# App user password
APP_USER_PASSWORD="MyAppUserPassword"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-xe:18.4.0"

# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s "${APP_USER}"/"${APP_USER_PASSWORD}"@//localhost/XEPDB1 <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset TEST_NAME
unset EXPECTED_RESULT
unset APP_USER
unset APP_USER_PASSWORD

######################################
##### Oracle Database (PDB) test #####
######################################

# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="18-oracle-db"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="18.4.0 ORACLE_DATABASE"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="Hi from your Oracle PDB"
# Oracle PDB
ORACLE_DATABASE="GERALD_PDB"
# Oracle password
ORA_PWD="MyTestPassword"
ORA_PWD_CMD="-e ORACLE_PASSWORD=${ORA_PWD}"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-xe:18.4.0-slim"

# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s sys/"${ORA_PWD}"@//localhost/"${ORACLE_DATABASE}" as sysdba <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset TEST_NAME
unset EXPECTED_RESULT
unset ORACLE_DATABASE
unset ORA_PWD
unset ORA_PWD_CMD

#################################################
##### Oracle Database (PDB) + APP_USER test #####
#################################################

# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="18-oracle-db"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="18.4.0 ORACLE_DATABASE & APP_USER"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="Hi from your Oracle PDB"
# App user
APP_USER="other_app_user"
# App user password
APP_USER_PASSWORD="ThatAppUserPassword1"
# Oracle PDB
ORACLE_DATABASE="REGRESSION_TESTS"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-xe:18.4.0"

# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s "${APP_USER}"/"${APP_USER_PASSWORD}"@//localhost/"${ORACLE_DATABASE}" <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset TEST_NAME
unset EXPECTED_RESULT
unset APP_USER
unset APP_USER_PASSWORD
unset ORACLE_DATABASE
