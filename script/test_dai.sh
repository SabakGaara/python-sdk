#!/bin/bash

num=$1
zero=0

for((integer=1; integer<=5; integer++))
do
{
	condition=`expr $integer % 2`
	if [ "$condition" == 0 ]
	
	then
		./console.py sendtx Dai 0xcda895ec53a73fbc3777648cb4c87b38e252f876 mint 0x24b6de08844982fb3dbaf659110cee3998a54a01 10
	else
		./console.py sendtx Dai 0xcab316ebdfef9fd9a959171baec2bb91d9fa5481 mint 0x24b6de08844982fb3dbaf659110cee3998a54a01 100
	fi
}&
done
