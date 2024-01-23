#!/bin/bash
scriptname="specs.sh"
clear

#CPU Variables
CPUsocket="$(lscpu | sed -n 's/^Socket(s): *//p')"
CPUmodel="$(lscpu | sed -n 's/^Model name: *//p')"
CPUcores="$(lscpu | sed -n 's/^Core(s) per socket: *//p')"
CPUthreadspercore="$(lscpu | sed -n 's/^Thread(s) per core: *//p')"
CPUcount="$(lscpu | sed -n 's/^CPU(s): *//p')"
CPUminfreq="$(lscpu | sed -n 's/^CPU min MHz: *//p')"
CPUmaxfreq="$(lscpu | sed -n 's/^CPU max MHz: *//p')"
CPUBogoMIPS="$(lscpu | sed -n 's/^BogoMIPS: *//p')"

#Memory Variables
memtotal="$(grep MemTotal: /proc/meminfo | uniq | awk '{ print $2 }')"
memfree="$(grep MemFree: /proc/meminfo | uniq | awk '{ print $2 }')"
memavailable="$(grep MemAvailable: /proc/meminfo | uniq | awk '{ print $2 }')"

#GPU Variables
#GPUcount="$(lspci | awk '$2 == "VGA" && $5 != "ASPEED" { print $2 }')"
#GPUarray=($GPUcount)
#GPUtotal=${#GPUarray[@]}

#for i in "${GPUarray[@]}"; do
#echo ${GPUarray[$i]}
#done

GPUcount="$(nvidia-smi -L | wc -l)"
GPUlist="$(nvidia-smi --query-gpu=name --format=csv,noheader)"
GPUarray=($GPUlist)
#GPUtotal=${#GPUarray[@]}


#echo $GPUcount
#exit

#echo ${GPUarray[@]}
#exit

#for i in "${GPUarray[@]}"; do
#echo ${GPUarray[$i]}
#done
#exit

echo "====================================="
echo "CPU Specs:"
echo "====================================="
echo ""
echo "Socket Count:     " $CPUsocket
echo "Model:            " $CPUmodel
echo "Cores:            " $CPUcores
echo "Threads per Core: " $CPUthreadspercore
echo "Total Threads:    " $CPUcount
echo "CPU Min MHz:      " $CPUminfreq
echo "CPU Max MHz:      " $CPUmaxfreq
echo "BogoMIPS:         " $CPUBogoMIPS
echo ""
echo "====================================="
echo "DRAM Specs:"
echo "====================================="
echo ""
echo "Total Memory:     " $memtotal
echo "Free Memory:      " $memfree
echo "Available Memory: " $memavailable
echo ""
echo "====================================="
echo "GPU Specs:"
echo "====================================="
echo ""
echo "GPU Count:         " $GPUcount
echo "GPU List:          " ${GPUarray[0]}

