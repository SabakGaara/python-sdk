#!/bin/bash


con_func = $1
non_con_func = $2
contract_address = $3
trans = $5

user = ('a','b', 'c')


contract_name = $4 


rate = $5


con_num = $trans * $rate


uncon_num = $trans - $con_num


for((integer = 1; integer <= $con_num; integer++));
do
{
	if ["$($integer % $rate)" -ne "0"];

       	then
		./console.py sendtx  $contract_name $contract_address $con_func ${user[0]} ${user[1]} 10;
	else
		./console.py sendtx $contract_name $contract_address $uncon_func;

	fi
}&
done





