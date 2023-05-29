#!/bin/bash

END="\033[0m"

function START() {
    db_name="";

    if [ $# -eq 1 ]; then
        db_name="test_for_trigger";
    else
        return ;
    fi
#     if (( $1 != "4" )); then
#         filename='test_for_trigger';
#     else
#         filename='test_for_trigger';
#     fi
#
    printf "###########################################\n";
    printf "\t####### STARTING TEST #######\n";
    printf "###########################################\n";

    prep=$(echo "\i ./utils/umain_test.sql" | psql -d $db_name 2>&1)
    prep=$(echo "\i ./part1.sql" | psql -d $db_name 2>&1)
    output=$(echo "\i ./tests/tpart_$1.sql" | psql -d $db_name 2>&1)
    echo $prep;
    RES=$(echo "$output" | awk '{print}')
    #OUT=$(echo "$RES" | awk  -v ok_o="$OK_OUTPUT" -v f_o="$FAIL_OUTPUT" -v end_o "$END" '{
    OUT=$(echo "$RES" | awk '{

    if (($0 ~ /ОШИБКА:/) || ($0 ~/ASSERT/) || ($0 ~/ERROR:/)) {
        printf "\33[91m \t ----- [ ERRORR ] -----  \033[0m \n"
        printf "\33[91m %s \033[0m \n", $0
    } else if (($0 ~ /ИНФОРМАЦИЯ:/) || ($0 ~ /INFO:/)) {
        printf "\33[92m %s \033[0m \n", $0
    } else {
        printf "%s\n", $0
    }

    }')
    echo "$OUT"

#     echo -e "$(\
#         echo "\i ./tests/tpart_$1.sql" |
#         psql -d $filename 2>&1
#         sed -e "s/^psql.*INFO:[ ]*TEST\s*\(.*\)/${INFO_COLOR}TEST \1${DEFAULT_COLOR}/"\
#             -e "s/^psql.*\(FNC_.*\)/${OUTPUT_COLOR} >>> OUTPUT FOR \1 <<<${DEFAULT_COLOR}/"\
#             -e "s/^psql.*\(PRCDR_.*\)/${OUTPUT_COLOR} >>> OUTPUT FOR \1 <<<${DEFAULT_COLOR}/"\
#             -e "s/^psql.*INFO:[ ]*\(.*\)/${INFO_COLOR} > \1${DEFAULT_COLOR}/"\
#             -e "s/^psql.*INFO:[ ]*OK\.*/${OK_COLOR} > OK${DEFAULT_COLOR}/"\
#             -e "s/^psql.*ERROR:[ ]*\(.*\)/${ERROR_COLOR} > \1${DEFAULT_COLOR}/"\
#             -e "/^psql.*NOTICE:/d"\
#             -e "/ROLLBACK/d"\
#             -e "/DO/d"\
#             -e "/BEGIN/d"\
#             -e "/CALL/d"\
#             -e "/COMMIT/d"\
#             -e "/CONTEXT:/d"
#
#     )"
}

START $1
