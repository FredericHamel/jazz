#! /bin/sh

if [ -d include ]; then
  rm -r include
fi

if [ -d lib ]; then
  rm -r lib
fi

cp -r /usr/local/Cellar/freetype/2.9.1/include/freetype2 include

mkdir lib
cp /usr/local/Cellar/freetype/2.9.1/lib/libfreetype.6.dylib lib/libfreetype.6.dylib
chmod 755 lib/libfreetype.6.dylib
