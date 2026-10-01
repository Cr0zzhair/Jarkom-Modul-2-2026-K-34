#!/bin/sh

echo "=========================================="
echo "       THE MESH - APACHE BENCHMARK"
echo "=========================================="

echo ""
echo "[1] Checking ApacheBench..."

if ! command -v ab >/dev/null 2>&1; then
    echo "ApacheBench belum terinstall."
    echo "Install dengan:"
    echo "apt update && apt install apache2-utils -y"
    exit 1
fi

echo "ApacheBench tersedia."
ab -V

echo ""
echo "=========================================="
echo " TEST 1: www.K34.com"
echo " Requests     : 250"
echo " Concurrency  : 10"
echo "=========================================="

ab -n 250 -c 10 http://www.K34.com/

echo ""
echo "=========================================="
echo " TEST 2: static.K34.com"
echo " Requests     : 250"
echo " Concurrency  : 10"
echo "=========================================="

ab -n 250 -c 10 http://static.K34.com/

echo ""
echo "=========================================="
echo "          BENCHMARK SELESAI"
echo "=========================================="
