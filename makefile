ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))


CONTROLLER=ruby bots_controller.rb


.PHONY: stop start restart clean build opus

all: stop clean build start


# MAKEFILE COMMANDS

clean:
	rm -f temp
	rm -rf ffmpeg-source ffmpeg-include ffmpeg-build

force-clean: clean
	rm ffmpeg


stop:
	$(CONTROLLER) stop
	rm -f *.pid

start:
	$(CONTROLLER) start


restart: stop start


build: ffmpeg
	bundle install
	




# TARGETS

ffmpeg:
	make ffmpeg-source
	make opus
	cd ffmpeg-source; PKG_CONFIG_PATH="$(ROOT_DIR)/ffmpeg-include/lib/pkgconfig" ./configure --prefix="$(ROOT_DIR)/ffmpeg-build" --extra-cflags="-I$(ROOT_DIR)/ffmpeg-include/include" --extra-ldflags="-L$(ROOT_DIR)/ffmpeg-include/lib" --bindir="$(ROOT_DIR)/" --prefix=/opt/ffmpeg --as=yasm --extra-version=tessus  --enable-gpl --enable-libmp3lame --enable-libopus --disable-libvo-aacenc --enable-libvorbis --disable-ffplay --disable-indev=qtkit --disable-indev=x11grab_xcb
	cd ffmpeg-source; make
	cp ffmpeg-source/ffmpeg
	rm -rf ffmpeg-source ffmpeg-include ffmpeg-build

ffmpeg-source: 
	git clone --depth 1 --branch master git://source.ffmpeg.org/ffmpeg.git ffmpeg-source


opus:
	cd ffmpeg-source; curl http://downloads.xiph.org/releases/opus/opus-1.0.3.tar.gz > opus.tar.gz
	cd ffmpeg-source; tar xzvf opus.tar.gz
	cd ffmpeg-source/opus-1.0.3; ./configure --prefix="$(ROOT_DIR)/ffmpeg-include" --disable-shared
	cd ffmpeg-source/opus-1.0.3; make
	cd ffmpeg-source/opus-1.0.3; make install
	cd ffmpeg-source/opus-1.0.3; make distclean















