#!/bin/bash
# Execute the command.
#
# Arguments: 
#   ${1} command  ex; "ls 1"
# Output:
#   Writes stdout of the command with ctrl string to stdout
# Return:
#   0 - The command terminated normally
#   1 - The command terminated abnormally
#
echo "LOCK_SHELL_CTRL--CMD_START"
eval "${1}"
RET_CODE="${?}"
echo "LOCK_SHELL_CTRL--CMD_END"
if [ "${RET_CODE}" -eq 0 ]; then 
	echo "LOCK_SHELL_CTRL--CMD_OK"
	exit 0
else
	echo "LOCK_SHELL_CTRL--CMD_NG"
	exit 1
fi
