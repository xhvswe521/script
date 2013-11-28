#!/bin/bash
#scriptname=check_lcx_sorl_indel.sh
#AUTHOR:Wangqh

hosts=$@
#
#Judge wether the name of host is right or not;
#
if [ ! -n "$hosts" ];then
	echo "Usage: $0 1 2 ...>"
	echo "enter hosts now (don't worry about padding zeroes), or enter \"all\" for all hosts"
	read hosts
else
	for host in ${hosts}
	do
		if [[ ${host} != srwp0[16]lcx[0-9][0-9][0-9] ]]; then
			echo "You have enter the wrong name please try again"
			read hosts
	        fi 		
	done
fi

types="ticket event genre geo venue cobrand genre0"

for host in $hosts
do
	i=0
	printf "\n\033[35m\033[4m%-15s%10s%10s%23s\033[0m\n" "${host}" "Type"  "numFound" "dateLastIndexed"
#
#Find the url by the type
#
for type in $types
do
if [ "$type" == "genre0" ];then
	numfound="listingCatalog/select/?q=stubhubDocumentType:genre%20AND%20id:0&version=2.2&start=0&rows=10&indent=on"
else
	numfound="listingCatalog/select/?q=%2BstubhubDocumentType:${type}&version=2.2&start=0&rows=10&indent=on"
fi

lastindex="&sort=dateLastIndexed%20desc&fl=dateLastIndexed,id,ancestorGeoIds"
url[$i]="${numfound}${lastindex}"

type_numfound=`wget -O - "http://${host}.stubprod.com/${url[$i]}" 2>&1|egrep numFound|awk '{print $3}'|awk -F\" '{print $2}'`
type_datalastindexed=`wget -O - "http://${host}.stubprod.com/${url[$i]}" 2>&1|egrep dateLastIndexed|grep "<date"|head -1|awk '{print $2}'|cut -c 24-42|sed 's/T/ /g'`
#
#print the result which we get from url;
#
printf "\033[32m%26s%9s%23s\033[0m\n" "${type}:" "${type_numfound}" "${type_datalastindexed}"

let i=$i+1

done
done




