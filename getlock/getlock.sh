#!/bin/bash
#
# 排他を行った上でコマンドを実行し排他解除を行います。
#
# ${1} コマンド
# ${2} 排他キー
# ${3} nowait - 処理を打ち切り、指定なし - 処理を継続
#

# シェル関数
# 　コマンド実行結果を標準出力
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

# 排他SQL
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

#排他エラー
if [[ "${RET_VAL}" =~ "could not obtain lock on row in relation \"lock\"" ]]; then
  exit 2
#排他キー検索エラー
elif  [[ "${RET_VAL}" =~ "LOCK_SHELL_CTRL--LOCK_KEY_NG" ]]; then
  exit 3
#コマンド実行エラー
elif [[ "${RET_VAL}" =~ "LOCK_SHELL_CTRL--CMD_NG" ]]; then
  echo_cmd_stdout "${RET_VAL}"
  exit 1
#PSQLコマンドエラー
elif [[ "${RET_CODE}" -ne 0 ]]; then
  exit 9
fi

#正常
echo_cmd_stdout "${RET_VAL}"
exit 0
