#!/bin/bash

Help(){
    echo -n -e "\nUsage: sahw2.sh {--sha256 hashes ... | --md5 hashes ...} -i files ...\n\n--sha256: SHA256 hashes to validate input files.\n--md5: MD5 hashes to validate input files.\n-i: Input files.\n"
}
SHA(){
    echo "shaaaaa"
}
FILE(){
    echo "---input file---"
    echo "---$1"
    local file_md=$(md5sum $1 | awk '{print $1}')
    echo "---$file_md"
    shift
}


Error_type(){
    echo "Error: Only one type of hash function is allowed."
}
Error_value(){
    echo "Error: Invalid values."
}
Error_checksum(){
    echo "Error: Invalid checksum."
}

# Var
ARGS=("-h" "-i" "--md5" "--sha256")

FILE_NUM=0
FILE_LIST=()

PSW_NUM=0
PSW_LIST=()
PSW_FLAG=0
PSW_ALG=""

# Main func.

while [ $# -gt 0 ] ; do
    # echo "Now is $1"
    case $1 in
        -i)
            shift
            for i in "$@" ; do
                if [[ " ${ARGS[*]} " =~ " $i " ]]; then
                    # echo "$i is arguments."
                    break
                fi
                FILE_LIST[$FILE_NUM]=$i
                FILE_NUM=$(( $FILE_NUM + 1 )) 

                # Test if file exists
                # if [ test -e "$i" ] ; then 
                #     echo "$i DNE"
                #     exit
                # fi
            done
            for i in `seq 1 $FILE_NUM` ; do shift ; done
            # echo "---All file num: ${#FILE_LIST[@]}"
            # echo "---All input file:"
            # echo ${FILE_LIST[@]}
            ;;
        --md5)
            # Error verify
            if [ $PSW_FLAG -ne 0 ] ; then
                Error_type
                exit
            else
                PSW_FLAG=1
                PSW_ALG="md5sum"
            fi

            shift
            # echo "MD5"
            for i in "$@" ; do
                if [[ " ${ARGS[*]} " =~ " $i " ]]; then
                    # echo "$i is arguments."
                    break
                fi
                PSW_LIST[$PSW_NUM]=$i
                PSW_NUM=$(( $PSW_NUM + 1 )) 
            done
            for i in `seq 1 $PSW_NUM` ; do shift ; done
            # echo "---All PSW num: ${#PSW_LIST[@]}"
            # echo "---All input PSW:"
            # echo ${PSW_LIST[@]}
            ;;
        --sha256)
            # Error verify
            if [ $PSW_FLAG -ne 0 ] ; then
                Error_type
                exit
            else
                PSW_FLAG=2
                PSW_ALG="sha256sum"
            fi

            shift
            # echo "SHA"
            for i in "$@" ; do
                if [[ " ${ARGS[*]} " =~ " $i " ]]; then
                    # echo "$i is arguments."
                    break
                fi
                PSW_LIST[$PSW_NUM]=$i
                PSW_NUM=$(( $PSW_NUM + 1 )) 
            done
            for i in `seq 1 $PSW_NUM` ; do shift ; done
            ;;
        -h)
            Help
            exit ;;
        *)
            echo -e "Error: Invalid arguments."
            Help
            exit ;;
    esac
done

# Verify
if [ $FILE_NUM -ne $PSW_NUM ] ; then Error_value ; exit ; fi

for i in `seq 1 $FILE_NUM`; do
    # if [ ${PSW_LIST[$i]} ]
    n=$(($i-1))
    TMP=$($PSW_ALG ${FILE_LIST[$n]} | awk '{print $1}')
    # echo "------"
    # echo "PSW : ${PSW_LIST[$n]}"
    # echo "FILE: ${FILE_LIST[$n]}"
    # echo "TMP : ${TMP}"
    # echo "------"
    if [ ${PSW_LIST[$n]} != ${TMP} ] ; then
        Error_checksum
        exit
    fi
done

# local file_md=$(md5sum $1 | awk '{print $1}')
        
# ./sahw2.sh -i 1.json 2.csv --md5 922b742e3e697b337d4213a523e66535 fb5b2067f25c89df0fad575a08f22f7a