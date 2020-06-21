#! /bin/sh

# Don't commit the following line
GSTREAMER=$PWD/gst-build-1.16.2/pkg/usr/local
GSTREAMER_LIB="$GSTREAMER/lib"

if [ -d gstreamer ]; then
  rm -r gstreamer
fi

mkdir gstreamer


#
# lib
#

cpplugin() {
    test -r $GSTREAMER_LIB/$1.so && echo Copying plugin $1 || echo Failed plugin $1
    cp $GSTREAMER_LIB/$1.so gstreamer/lib/$1.so
    patchelf --set-rpath '$ORIGIN/..' gstreamer/lib/$1.so
}

cpshared() {
    if test -r $GSTREAMER_LIB/$1.$2; then
      echo "Copying $1.$2 from $GSTREAMER_LIB"
      cp $GSTREAMER_LIB/$1.$2 gstreamer/lib/$1.$2
    else
      for lib in $GSTREAMER_LIB/$1.*; do
        if test -r "$lib"; then
          echo "*** Found version $lib"
          exit 1
        fi
      done

      if test -r /usr/lib/$1.$2; then
        echo "Copying $1.$2 from /usr/lib"
        cp /usr/lib/$1.$2 gstreamer/lib/$1.$2
      else
        echo "Failed copying shared library $1.$2"
        exit 1
      fi
    fi

    patchelf --set-rpath '$ORIGIN' gstreamer/lib/$1.$2
    ln -sr gstreamer/lib/$1.$2 gstreamer/lib/$1
}

mkdir gstreamer/lib
mkdir gstreamer/lib/gstreamer-1.0

cpplugin gstreamer-1.0/libgstalpha
cpplugin gstreamer-1.0/libgstalsa
cpplugin gstreamer-1.0/libgstapp
cpplugin gstreamer-1.0/libgstaudioconvert
cpplugin gstreamer-1.0/libgstaudiofx
cpplugin gstreamer-1.0/libgstaudioparsers
cpplugin gstreamer-1.0/libgstaudioresample
cpplugin gstreamer-1.0/libgstaudiotestsrc
cpplugin gstreamer-1.0/libgstautodetect
cpplugin gstreamer-1.0/libgstavi
cpplugin gstreamer-1.0/libgstcoreelements
cpplugin gstreamer-1.0/libgstdeinterlace
cpplugin gstreamer-1.0/libgstisomp4
cpplugin gstreamer-1.0/libgstjpeg
cpplugin gstreamer-1.0/libgstlibav
cpplugin gstreamer-1.0/libgstmatroska
cpplugin gstreamer-1.0/libgstogg
cpplugin gstreamer-1.0/libgstplayback
cpplugin gstreamer-1.0/libgstpulseaudio
cpplugin gstreamer-1.0/libgstsubparse
cpplugin gstreamer-1.0/libgsttypefindfunctions
cpplugin gstreamer-1.0/libgstvideoconvert
cpplugin gstreamer-1.0/libgstvideofilter
cpplugin gstreamer-1.0/libgstvideoparsersbad
cpplugin gstreamer-1.0/libgstvideorate
cpplugin gstreamer-1.0/libgstvideoscale
cpplugin gstreamer-1.0/libgstvideotestsrc
cpplugin gstreamer-1.0/libgstvideo4linux2
cpplugin gstreamer-1.0/libgstvolume
cpplugin gstreamer-1.0/libgstvorbis
cpplugin gstreamer-1.0/libgstwavparse
cpplugin gstreamer-1.0/libgstx264
cpplugin gstreamer-1.0/libgstximagesrc

cpshared libc.so 6
cpshared libdl.so 2
cpshared libffi.so 7
cpshared libgio-2.0.so 0
cpshared libglib-2.0.so 0
cpshared libgmodule-2.0.so 0
cpshared libgobject-2.0.so 0
cpshared libgraphene-1.0.so 0
cpshared libgstallocators-1.0.so 0
cpshared libgstapp-1.0.so 0
cpshared libgstaudio-1.0.so 0
cpshared libgstbase-1.0.so 0
cpshared libgstcodecparsers-1.0.so 0
cpshared libgstfft-1.0.so 0
cpshared libgstgl-1.0.so 0
cpshared libgstpbutils-1.0.so 0
cpshared libgstreamer-1.0.so 0
cpshared libgstriff-1.0.so 0
cpshared libgstrtp-1.0.so 0
cpshared libgsttag-1.0.so 0
cpshared libgstvideo-1.0.so 0
cpshared libjpeg.so 8
cpshared libm.so 6
cpshared libogg.so 0
cpshared libpcre.so 1
cpshared libpng16.so 16
cpshared libvorbis.so 0
cpshared libvorbisenc.so 2
cpshared libx264.so 159
cpshared libz.so 1


#
# libexec
#

mkdir gstreamer/libexec
mkdir gstreamer/libexec/gstreamer-1.0
cp -v $GSTREAMER/libexec/gstreamer-1.0/gst-plugin-scanner gstreamer/libexec/gstreamer-1.0
patchelf --set-rpath '$ORIGIN/../../lib' gstreamer/libexec/gstreamer-1.0/gst-plugin-scanner


#
# include
#

mkdir gstreamer/include
[ -r $GSTREAMER/include/gstreamer-1.0 ] && \
  cp -r $GSTREAMER/include/gstreamer-1.0 gstreamer/include || \
  echo 'Failed copying gstreamer include files'

[ -r /usr/include/glib-2.0 ] && \
  cp -r /usr/include/glib-2.0 gstreamer/include || \
  echo 'Failed copying glib-2.0 include files'

[ -r /usr/lib/glib-2.0 ] && \
  cp -r /usr/lib/glib-2.0 gstreamer/lib || \
  echo 'Failed copying glib-2.0 lib files'
