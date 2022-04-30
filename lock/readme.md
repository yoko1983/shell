This shell is get lock key and execute the command with using Postgresql.

1. Install postgresql
1. Configre psql
     - Password file: .pgpass
     - Environment variable: PGHOST, PGPORT, PGDATABASE, PGUSER
1. Git clone this shell
    ```
    git clone https://github.com/yoko1983/shell
    ```
1. Create table & insert lock key
    ```
    psql -f "create.sql"
    psql -f "insert.sql"
    ```
1. chmod shell
    ```
    chmod 775 lock.sh
    chmod 775 exec_cmd.sh
    ```
1. Execut shell
    ```
    ./lock.sh "ls -1" sample
    ```



