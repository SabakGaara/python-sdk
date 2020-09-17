#!/bin/bash

((num=0xb231ee30f68db033bb876c57452ef55c2da1e53b))
zero=0

#for((integer=1; integer<=10; integer++))
#do
#{
	#temp2=$((16#${num}+integer))
	#let m=$num+integer;
	#echo $m
        
#	./console.py sendtx Paras 0x4608749177bdcea3f2fd13807f5412e6cde150b6 transfer "a" "b" 1

#}&
#done

for((integer=0; integer<4; integer++))
do
{
        condition=`expr $integer % 2`
        if [ "$condition" == 0 ]

        then
		#./console.py sendtx TestV2 0xf805cc0fdaece77cb724a36dd66047758b47c99d try_one  0x7159011af634f83f84647ad54c281d42609dd2fe 0x95198b93705e394a916579e048c8a32ddfb900f7 1000
                ./console.py sendtx Paras 0x24b6de08844982fb3dbaf659110cee3998a54a01 set "a" 20000
        else
		#./console.py sendtx TestV2 0xf805cc0fdaece77cb724a36dd66047758b47c99d try_one  0x7159011af634f83f84647ad54c281d42609dd2fe 0x95198b93705e394a916579e048c8a32ddfb900f7 2000
                ./console.py sendtx Paras 0x4608749177bdcea3f2fd13807f5412e6cde150b6 transfer "a" "b" 2

        fi
}&
done
