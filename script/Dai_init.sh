#!/bin/bash

Dai_address_array=(0xbbe16a7054c0f1d3b71f4efdb51b9e40974ad651 0x1f494c56c3ad1e6738f3500d19499cd3541160ea 0x09d88e27711e78d2c389eb8f532ccdc9abe43077 0x7159011af634f83f84647ad54c281d42609dd2fe 0xe05b4dbef2b70c251f26752adc995c018764315e 0x4fb700f036dbd8a80940a88df8d9e55705a8ac97 0xf805cc0fdaece77cb724a36dd66047758b47c99d 0xcda895ec53a73fbc3777648cb4c87b38e252f876 0xcab316ebdfef9fd9a959171baec2bb91d9fa5481 0xf74c2c7131c2461db2e67362a8e7fca6dc0a66bf 0xb7a506877cd874b0dc0ed1a43762193b60a7b6d4)

DaiV2_address=0xbbe16a7054c0f1d3b71f4efdb51b9e40974ad651

reciver_address=0x35ea6ab6035449acc289fdc313835e7c154ddb41

sender_address=0x95198b93705e394a916579e048c8a32ddfb900f7

for((integer=0; integer<4; integer++))
do
{
   #if [ $integer -lt 2 ];then
	   #./console.py sendtx Dai 0xe05b4dbef2b70c251f26752adc995c018764315e mint 0x35ea6ab6035449acc289fdc313835e7c154ddb41 100000
   #else
	   #./console.py sendtx Dai 0x7159011af634f83f84647ad54c281d42609dd2fe mint 0x35ea6ab6035449acc289fdc313835e7c154ddb41 100000
	   #./console.py sendtx Dai ${Dai_address_array[$integer]} mint $sender_address 900000000
   #fi
   	./console.py deploy DaiV2 1

}
done


