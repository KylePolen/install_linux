#!/bin/bash
scriptname="test.sh"
clear

sudo mkdir /lib/firmware/mediatek/mt7925
sudo cp WIFI_MT7925_PATCH_MCU_1_1_hdr.bin /lib/firmware/mediatek/mt7925
sudo cp WIFI_RAM_CODE_MT7925_1_1.bin /lib/firmware/mediatek/mt7925
sudo cp BT_RAM_CODE_MT7925_1_1_hdr.bin /lib/firmware/mediatek/mt7925