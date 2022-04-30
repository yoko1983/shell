#!/bin/bash
echo "LOCK_SHELL_CTRL--CMD_START"
eval "${1}"
RET_CODE="${?}"
echo "LOCK_SHELL_CTRL--CMD_END"
if [ "${RET_CODE}" -eq 0 ]; then 
	echo "LOCK_SHELL_CTRL--CMD_OK"
else
	echo "LOCK_SHELL_CTRL--CMD_NG"
fi
