#!/bin/bash


if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "MAC"
    sed -i "" "s/TESTING/$(pwd | sed 's/\//\\\//g')\/csv\//g" part1.sql
    sed -i "" "s/TROLOLO/$(pwd | sed 's/\//\\\//g')\/export_csv\//g" part1.sql
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    sed -i "s/TESTING/$(pwd | sed 's/\//\\\//g')\/csv\//g" part1.sql
    sed -i "s/TROLOLO/$(pwd | sed 's/\//\\\//g')\/export_csv\//g" part1.sql
else
    sed -i "s/TESTING/$(pwd | sed 's/\//\\\//g')\/csv\//g" part1.sql
    sed -i "s/TROLOLO/$(pwd | sed 's/\//\\\//g')\/export_csv\//g" part1.sql
fi


if [[ $1 != 1 && $1 != 2 && $1 != 3 && ! -z "$1" ]]; then
    printf "\33[91mERROR \033[0m \33[94mEXAMPLE   -- ./run_test 1 \033[0m"
    exit ;
fi

function create_db() {
        local name="s21_info";
    return $name;
}

function START() {
    db_name="s21_info";

    if ! psql -lqt | cut -d \| -f 1 | grep -qw db_name; then
        prep=$(echo "CREATE DATABASE $db_name" | psql 2>&1)
    else
        prep=$(echo "DROP DATABASE $db_name" | psql 2>&1)
        prep=$(echo "CREATE DATABASE $db_name" | psql 2>&1)
    fi

    printf "###########################################\n";
    printf "\t####### STARTING TEST #######\n";
    printf "###########################################\n";

    prep=$(echo "\i ./utils/umain_helps.sql" | psql -d $db_name 2>&1)



    if [ -z "$1" ]; then
        prep=$(echo "\i ./part1.sql" | psql -d $db_name 2>&1)
        prep=$(echo "\i ./part2.sql" | psql -d $db_name 2>&1)
        prep=$(echo "\i ./part3.sql" | psql -d $db_name 2>&1)
    elif [ $1 -eq 2 ]; then
        prep=$(echo "\i ./part1.sql" | psql -d $db_name 2>&1)
        prep=$(echo "\i ./part2.sql" | psql -d $db_name 2>&1)
    elif [ $1 -eq 3 ]; then
        echo "3";
        prep=$(echo "\i ./part1.sql" | psql -d $db_name 2>&1)
        prep=$(echo "\i ./part2.sql" | psql -d $db_name 2>&1)
        prep=$(echo "\i ./part3.sql" | psql -d $db_name 2>&1)
    elif [ $1 -eq 1 ]; then
        prep=$(echo "\i ./part1.sql" | psql -d $db_name 2>&1)
    fi


    if [ -z "$1" ]; then
        output+=$(echo "\i ./tests/tpart_1.sql" | psql -d $db_name 2>&1);
        output+=$(echo "\i ./tests/tpart_2.sql" | psql -d $db_name 2>&1);
        output+=$(echo "\i ./tests/tpart_3.sql" | psql -d $db_name 2>&1);
    else
        output=$(echo "\i ./tests/tpart_$1.sql" | psql -d $db_name 2>&1)
    fi

   echo $prep;
   RES=$(echo "$output" | awk '{print}')

   OUT=$(echo "$RES" | awk '{

   if (($0 ~ /ОШИБКА/) || ($0 ~/ASSERT/) || ($0 ~/ERROR/) || ($0 ~/FAIL/)) {
       printf "\33[91m \t ----- [ ERRORR ] -----  \033[0m \n"
       printf "\33[91m %s \033[0m \n", $0
       exit(-1)
   } else if (($0 ~ /ИНФОРМАЦИЯ:/) || ($0 ~ /INFO:/)) {
       printf "\33[92m %s \033[0m \n", $0
   } else {
       printf "%s\n", $0
   }

   }')
   echo "$OUT"

}

START $1
