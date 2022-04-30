#!/bin/bash
#
# Get lock key and execute the command.
# After the command is completed, the lock key is released.
# This shell is using Postgressql.
#
# Arguments: 
#   ${1} command  ex; "ls 1"
#   ${2} lockkey
#   ${3} nowait(Optional) If locked, the command is terminated.
# Output:
#   Writes stdout of the command to stdout
# Return:
#   0 - The command terminated normally
#   1 - The command terminated abnormally
#   2 - Unable to get lock key
#   3 - Lock key not found
#   9 - DB error
#

# Function
# 　Stdout of command execution results
function echo_cmd_stdout() {
  CMD_FLAG=false
  echo "${1}" | while read -r LINE; do
    if [[ "${LINE}" == "LOCK_SHELL_CTRL--CMD_START" ]]; then
      CMD_FLAG=true
    elif [[ "${LINE}" == "LOCK_SHELL_CTRL--CMD_END" ]]; then
      break
    elif [[ "${CMD_FLAG}" == true ]]; then
      echo -e "${LINE}"
    fi
  done

}

# SQL for getting lock key
SQL_LOCK="
   begin;
   select exists(select * from lock where key='${2}' for update ${3}) as is_locked;
   \gset
   \if :is_locked
     \echo 'LOCK_SHELL_CTRL--LOCK_KEY_OK'
   \else
     \echo 'LOCK_SHELL_CTRL--LOCK_KEY_NG'
     \q
   \endif
   \! ./run_cmd.sh \"${1}\"
   end;
   "

RET_VAL=$(psql -tA -v ON_ERROR_STOP=true -f <(echo "${SQL_LOCK}") 2>&1)
RET_CODE="${?}"

# Unable to get lock key
if [[ "${RET_VAL}" =~ "could not obtain lock on row in relation \"lock\"" ]]; then
  exit 2
# Lock key not found
elif  [[ "${RET_VAL}" =~ "LOCK_SHELL_CTRL--LOCK_KEY_NG" ]]; then
  exit 3
# The command terminated abnormally
elif [[ "${RET_VAL}" =~ "LOCK_SHELL_CTRL--CMD_NG" ]]; then
  echo_cmd_stdout "${RET_VAL}"
  exit 1
# DB error
elif [[ "${RET_CODE}" -ne 0 ]]; then
  exit 9
fi

# The command terminated normally
echo_cmd_stdout "${RET_VAL}"
exit 0
