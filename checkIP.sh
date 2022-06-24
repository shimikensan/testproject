#!/bin/bash
clear
echo "-----NETWORK CONFIG-----"
echo "[1] Kiểm tra kết nối Internet"
echo "[2] Kiểm tra địa chỉ IP"
echo "[3] Tắt card mạng"
echo "[4] Mở card mạng"
echo "[5] Reset lại card mạng"
echo "[6] Cấu hình địa chỉ mạng"
echo "========================"
echo "Bạn muốn làm gì:"
read number
if [ $number -eq 1 ]
	then
		clear
		ping -c 4 8.8.8.8
		if [ `echo $?` -eq 0 ]
			then
	echo "-----------------------------------------"	
	echo "MÁY TÍNH CỦA BẠN ĐÃ KẾT NỐI ĐƯỢC INTERNET"
	echo "-----------------------------------------"
		else
	echo "-----------------------------------------"	
	echo "MÁY TÍNH CỦA BẠN KHÔNG KẾT NỐI ĐƯỢC INTERNET"	
	echo "-----------------------------------------"	
	fi	
elif [ $number -eq 2 ]
	then 
		echo -e "Địa chỉ IP của bạn là:\n`ifconfig ens33 | grep inet`"
elif [ $number -eq 3 ]
	then
		ifdown ens33
		echo "Card mạng của bạn đã tắt"
elif [ $number -eq 4 ]
	then 
		ifup ens33
		echo "Card mạng của bạn đã bật"
elif [ $number -eq 5 ]
	then
		systemctl restart network
		echo "Card mạng của bạn đã được reset lại"
elif [ $number -eq 6 ]
	then
		echo "Nhập địa chỉ IP đi bạn:"
		read IPA
		ifconfig ens33 $IPA
		echo "Nhập NETMASK đi bạn:"
		read NETM
		ifconfig ens33 netmask $NETM
		systemctl restart network
fi
