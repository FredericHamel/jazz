#! /bin/sh

GSTREAMER=/c/gstreamer/1.0/x86

if [ -d gstreamer ]; then
  rm -r gstreamer
fi

mkdir gstreamer


#
# lib
#

cpbundle() {
    cp $GSTREAMER/lib/$1.dll gstreamer/lib/$1.dll
}

cpshared() {
    cp $GSTREAMER/bin/$1.dll gstreamer/bin/$1.dll
}

cplink() {
    cp $GSTREAMER/lib/$1.a gstreamer/lib/$1.a
}

mkdir gstreamer/bin
mkdir gstreamer/lib
mkdir gstreamer/lib/gstreamer-1.0
cpbundle gstreamer-1.0/libgstalpha
cpbundle gstreamer-1.0/libgstapp
cpbundle gstreamer-1.0/libgstaudioconvert
cpbundle gstreamer-1.0/libgstaudiofx
cpbundle gstreamer-1.0/libgstaudioparsers
cpbundle gstreamer-1.0/libgstaudioresample
cpbundle gstreamer-1.0/libgstaudiotestsrc
cpbundle gstreamer-1.0/libgstautodetect
cpbundle gstreamer-1.0/libgstavi
cpbundle gstreamer-1.0/libgstcoreelements
cpbundle gstreamer-1.0/libgstd3d
cpbundle gstreamer-1.0/libgstdeinterlace
cpbundle gstreamer-1.0/libgstdirectsound
cpbundle gstreamer-1.0/libgstdirectsoundsrc
cpbundle gstreamer-1.0/libgstisomp4
cpbundle gstreamer-1.0/libgstjpeg
cpbundle gstreamer-1.0/libgstlibav
cpbundle gstreamer-1.0/libgstmatroska
cpbundle gstreamer-1.0/libgstogg
cpbundle gstreamer-1.0/libgstopus
cpbundle gstreamer-1.0/libgstplayback
cpbundle gstreamer-1.0/libgstsubparse
cpbundle gstreamer-1.0/libgsttypefindfunctions
cpbundle gstreamer-1.0/libgstvideoconvert
cpbundle gstreamer-1.0/libgstvideofilter
cpbundle gstreamer-1.0/libgstvideoparsersbad
cpbundle gstreamer-1.0/libgstvideorate
cpbundle gstreamer-1.0/libgstvideoscale
cpbundle gstreamer-1.0/libgstvideotestsrc
cpbundle gstreamer-1.0/libgstvolume
cpbundle gstreamer-1.0/libgstvorbis
cpbundle gstreamer-1.0/libgstvpx
cpbundle gstreamer-1.0/libgstwasapi
cpbundle gstreamer-1.0/libgstwavparse
cpbundle gstreamer-1.0/libgstwinks
cpbundle gstreamer-1.0/libgstwinscreencap
cpbundle gstreamer-1.0/libgstx264
cpshared libbz2
cpshared libffi-7
cpshared libgio-2.0-0
cpshared libglib-2.0-0
cpshared libgmodule-2.0-0
cpshared libgobject-2.0-0
cpshared libgraphene-1.0-0
cpshared libgstallocators-1.0-0
cpshared libgstapp-1.0-0
cpshared libgstaudio-1.0-0
cpshared libgstbase-1.0-0
cpshared libgstcodecparsers-1.0-0
cpshared libgstfft-1.0-0
cpshared libgstgl-1.0-0
cpshared libgstpbutils-1.0-0
cpshared libgstreamer-1.0-0
cpshared libgstriff-1.0-0
cpshared libgstrtp-1.0-0
cpshared libgsttag-1.0-0
cpshared libgstvideo-1.0-0
cpshared libintl-8
cpshared libjpeg-8
cpshared libogg-0
cpshared libopus-0
cpshared liborc-0.4-0
cpshared libpng16-16
cpshared libvorbis-0
cpshared libvorbisenc-2
cpshared libwinpthread-1
cpshared libx264-148
cpshared libz-1
cplink libgstapp-1.0.dll
cplink libgstbase-1.0.dll
cplink libgstpbutils-1.0.dll
cplink libgstreamer-1.0.dll
cplink libgobject-2.0.dll
cplink libglib-2.0.dll
cplink libintl.dll


#
# libexec
#

mkdir gstreamer/libexec
mkdir gstreamer/libexec/gstreamer-1.0
cp $GSTREAMER/libexec/gstreamer-1.0/gst-plugin-scanner gstreamer/libexec/gstreamer-1.0


#
# include
#

mkdir gstreamer/include
cp -r $GSTREAMER/include/gstreamer-1.0 gstreamer/include
cp -r $GSTREAMER/include/glib-2.0 gstreamer/include
cp -r $GSTREAMER/lib/glib-2.0 gstreamer/lib
