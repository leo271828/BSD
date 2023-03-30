#!/bin/bash 

Help(){
    echo -n -e "\nUsage: sahw2.sh {--sha256 hashes ... | --md5 hashes ...} -i files ...\n\n--sha256: SHA256 hashes to validate input files.\n--md5: MD5 hashes to validate input files.\n-i: Input files.\n"
}
Func(){
    for i in "$@" ; do
        if [[ " ${ARGS[*]} " =~ " $i " ]]; then break ; fi
        FILE_LIST[$FILE_NUM]=$i
        FILE_NUM=$(($FILE_NUM + 1))
    done
    for i in `seq 1 $FILE_NUM` ; do shift ; done
}

Error_file_format(){
    echo -n -e "Error: Invalid file format." 1>&2
}
Error_arg(){
    echo -n -e "Error: Invalid arguments." 1>&2
}
Error_type(){
    if [ $PSW_FLAG -ne 0 ] ; then 
        echo -n -e "Error: Only one type of hash function is allowed." 1>&2
        exit 1
    else 
        PSW_FLAG=$1 
        PSW_ALG=$2 
    fi
}
Error_value(){
    echo -n -e "Error: Invalid values." 1>&2
}
Error_checksum(){
    echo -n -e "Error: Invalid checksum." 1>&2
}

Add_user(){
    echo "add"
    # for i in ${FILE_LIST[@]} ; do
    #     ;;
    # done
}
# Var
set -e

ARGS=("-h" "-i" "--md5" "--sha256")

FILE_NUM=0
FILE_LIST=()

PSW_NUM=0
PSW_LIST=()
PSW_FLAG=0
PSW_ALG=""

# Main func.

while [ $# -gt 0 ] ; do
    case $1 in
        -i)
            shift
            for i in "$@" ; do
                if [[ " ${ARGS[*]} " =~ " $i " ]]; then break ; fi
                FILE_LIST[$FILE_NUM]=$i
                FILE_NUM=$(($FILE_NUM+1))
            done
            for i in `seq 1 $FILE_NUM` ; do shift ; done
            ;;
        --md5|--sha256)
            # Error verify
            if [[ $1 = "--md5" ]] ; then 
                Error_type 1 "md5sum" 
            else 
                Error_type 2 "sha256sum"
            fi

            shift
            for i in "$@" ; do
                if [[ " ${ARGS[*]} " =~ " $i " ]]; then break ; fi
                PSW_LIST[$PSW_NUM]=$i
                PSW_NUM=$(($PSW_NUM+1))
            done
            for i in `seq 1 $PSW_NUM` ; do shift ; done
            ;;
        -h)
            Help
            exit ;;
        *)
            Error_arg
            Help
            exit 1 ;;
    esac
done

# Verify
if [ $FILE_NUM -ne $PSW_NUM ] ; then Error_value ; exit 1 ; fi

USR=''
USR_LIST=()
USR_NUM=0

for i in `seq 1 $FILE_NUM`; do
    n=$(($i-1))
    FILE=${FILE_LIST[$n]}
    TMP=$($PSW_ALG $FILE | awk '{print $1}')
    if [ ${PSW_LIST[$n]} != ${TMP} ] ; then
        Error_checksum
        exit 1
    fi

    # Check file format
    FTYPE=$(file ${FILE_LIST[$n]} | awk '{print $2}' )
    if [[ $FTYPE = "JSON" ]] ; then
        # echo "json"
        LIST=$( cat $FILE | jq -r ".[] | .username" )
    elif [[ $FTYPE = "CSV" ]] ; then
        # echo "csv"
        LIST=$( cat $FILE | tail -n +2 | cut -d , -f 1 )
    else 
        Error_file_format
        exit 1
    fi

    # Read username
    for j in ${LIST[@]} ; do
        USR_LIST[$USR_NUM]=$j
        USR_NUM=$(($USR_NUM+1))
    done
done

# Question to create users
echo -n -e "This script will create the following user(s): "
for i in "${USR_LIST[@]}" ; do
    echo -n -e "$i "
done
echo -n -e "Do you want to continue? [y/n]:"
rep=""
read rep 
case $rep in
    [Yy]) 
        exit 0 
    ;;
    [Nn]) 
        exit 0 
    ;;
    "") 
        exit 0 
    ;;
    *)
    ;;
esac

# Add_user

# Create user
# for i in "${USR_LIST[@]}" ; do
#     grep -i "^$i:" /etc/passwd >/dev/null 2>&1;
 
#     if [ $? -eq 0 ]; then
#         echo -e "Warning: user $i already exists."
#     fi
# done


# file ${FILE_LIST[@]} | awk '{print $2}'
# local file_md=$(md5sum $1 | awk '{print $1}')
        
# ./r_sahw2.sh -i 1.json 2.csv --md5 922b742e3e697b337d4213a523e66535 fb5b2067f25c89df0fad575a08f22f7a
# ./r_sahw2.sh -i 1.json --md5 922b742e3e697b337d4213a523e66535
# bash r_sahw2.sh --md5 99914b932bd37a50b983c5e7c90ae93b -i /tmp/8e802c09 /tmp/f955f93e
# tr -d '\r' < r_sahw2.sh > sahw2.sh