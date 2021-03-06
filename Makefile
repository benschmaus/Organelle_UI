CXX = g++

objects =  \
	main.o \
	AppData.o \
	Timer.o \
	MainMenu.o \
	OledScreen.o \
	SLIPEncodedSerial.o \
	Serial.o Socket.o \
	UdpSocket.o \
	OSC/OSCData.o \
	OSC/OSCMatch.o \
	OSC/OSCMessage.o \
	OSC/OSCTiming.o \
	OSC/SimpleWriter.o 

main : $(objects)
	g++ -o main $(objects)

.PHONY : clean

clean :
	rm main $(objects)


IMAGE_BUILD_VERSION = $(shell cat host/root/version)
IMAGE_BUILD_TAG = $(shell cat host/root/buildtag)
IMAGE_VERSION = $(IMAGE_BUILD_VERSION)$(IMAGE_BUILD_TAG)
IMAGE_DIR = UpdateOS-$(IMAGE_VERSION)


deploy : main
	cp main host/root/mother
	echo "Updating OS to $(IMAGE_VERSION)"
	host/root/scripts/remount-rw.sh
	cp -f host/root/mother.pd /root
	cp -f host/root/mother /root
	cp -f host/root/scripts/* /root/scripts
	cp -f host/root/version /root
	cp -f host/root/buildtag /root
	cp -f host/root/.bash_profile /root
	cp -f host/root/.jwmrc /root
	cp -f host/root/.pdsettings /root
	mkdir -p /root/.ssh
	cp -f host/root/.ssh/environment /root/.ssh/environment
	cp -f host/etc/ssh/sshd_config /etc/ssh/sshd_config
	mkdir -p /root/web
	cp -fr host/root/web/* /root/web
	sync

deployToSD : main
	cp main host/root/mother
	echo "Updating OS to $(IMAGE_VERSION)"
	host/root/scripts/remount-rw.sh
	mkdir -p /sdcard/Firmware/scripts
	cp -f host/root/mother.pd /sdcard/Firmware
	cp -f host/root/mother /sdcard/Firmware
	cp -f host/root/scripts/* /sdcard/Firmware/scripts
	cp -f host/root/version /sdcard/Firmware
	cp -f host/root/buildtag /sdcard/Firmware
	cp -f host/root/.bash_profile /root
	cp -f host/root/.jwmrc /root
	cp -f host/root/.pdsettings /root
	mkdir -p /root/.ssh
	cp -f host/root/.ssh/environment /root/.ssh/environment
	cp -f host/etc/ssh/sshd_config /etc/ssh/sshd_config
	sync 

deployToUSB : main
	cp main host/root/mother
	echo "Updating OS to $(IMAGE_VERSION)"
	/host/root/scripts/remount-rw.sh
	mkdir -p /usbdrive/Firmware/scripts
	cp -f host/root/mother.pd /usbdrive/Firmware
	cp -f host/root/mother /usbdrive/Firmware
	cp -f host/root/scripts/* /usbdrive/Firmware/scripts
	cp -f host/root/version /usbdrive/Firmware
	cp -f host/root/buildtag /usbdrive/Firmware
	cp -f host/root/.bash_profile /root
	cp -f host/root/.jwmrc /root
	cp -f host/root/.pdsettings /root
	mkdir -p /root/.ssh
	cp -f host/root/.ssh/environment /root/.ssh/environment
	cp -f host/etc/ssh/sshd_config /etc/ssh/sshd_config
	sync 


image : main
	@echo creating image $(IMAGE_VERSION) in $(IMAGE_DIR)
	mkdir -p $(IMAGE_DIR)/root
	cp -f host/root/mother.pd $(IMAGE_DIR)/root
	cp -f host/root/mother $(IMAGE_DIR)/root
	cp -f host/root/version $(IMAGE_DIR)/root
	cp -f host/root/buildtag $(IMAGE_DIR)/root
	cp -f host/root/.bash_profile $(IMAGE_DIR)/root
	cp -f host/root/.jwmrc $(IMAGE_DIR)/root
	cp -f host/root/.pdsettings $(IMAGE_DIR)/root
	mkdir -p $(IMAGE_DIR)/scripts
	cp -f host/root/scripts/* $(IMAGE_DIR)/scripts
	mkdir -p $(IMAGE_DIR)/web
	cp -fr host/root/web/* $(IMAGE_DIR)/web
	mkdir -p ${IMAGE_DIR}/.ssh
	cp -f host/root/.ssh/environment $(IMAGE_DIR)/.ssh/environment
	mkdir -p ${IMAGE_DIR}/system/etc/ssh 
	cp -f host/etc/ssh/sshd_config $(IMAGE_DIR)/system/etc/ssh/sshd_config
	cp -f host/etc/nsswitch.conf $(IMAGE_DIR)/system/etc/
	cp -fr host/extra $(IMAGE_DIR)/extra/
	sed "s/XXXXXXXXXX/$(IMAGE_VERSION)/g" < host/deploy.template > $(IMAGE_DIR)/deploy.sh
	sed "s/XXXXXXXXXX/$(IMAGE_VERSION)/g" < host/main.pd.template > $(IMAGE_DIR)/main.pd
	(cd $(IMAGE_DIR) ; find . -type f | sort > manifest ; openssl sha1 `cat manifest` > files.sha1)
	zip -r $(IMAGE_DIR).zip $(IMAGE_DIR)
	rm -rf $(IMAGE_DIR)
	@echo created $(IMAGE_DIR).zip

# Generate with g++ -MM *.c* OSC/*.* 
AppData.o: AppData.cpp AppData.h OledScreen.h
MainMenu.o: MainMenu.cpp MainMenu.h AppData.h OledScreen.h
OledScreen.o: OledScreen.cpp OledScreen.h fonts.h simple_svg_1.0.0.hpp
SLIPEncodedSerial.o: SLIPEncodedSerial.cpp SLIPEncodedSerial.h Serial.h \
  UdpSocket.h Socket.h
Serial.o: Serial.cpp Serial.h
Socket.o: Socket.cpp Socket.h
Timer.o: Timer.cpp Timer.h
UdpSocket.o: UdpSocket.cpp UdpSocket.h Socket.h
main.o: main.cpp OSC/OSCMessage.h OSC/OSCData.h OSC/OSCTiming.h \
  OSC/SimpleWriter.h Serial.h UdpSocket.h Socket.h SLIPEncodedSerial.h \
  OledScreen.h MainMenu.h AppData.h Timer.h
serialdump.o: serialdump.c
test.o: test.cpp
OSCData.o: OSC/OSCData.cpp OSC/OSCData.h OSC/OSCTiming.h
OSCMatch.o: OSC/OSCMatch.c OSC/OSCMatch.h
OSCMessage.o: OSC/OSCMessage.cpp OSC/OSCMessage.h OSC/OSCData.h \
  OSC/OSCTiming.h OSC/SimpleWriter.h OSC/OSCMatch.h
OSCTiming.o: OSC/OSCTiming.cpp OSC/OSCTiming.h
SimpleWriter.o: OSC/SimpleWriter.cpp OSC/SimpleWriter.h
