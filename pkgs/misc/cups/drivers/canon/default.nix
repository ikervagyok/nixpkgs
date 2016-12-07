{stdenv, fetchurl, unzip, autoreconfHook, libtool, makeWrapper, cups, ghostscript, callPackage_i686 }:

let

  i686_NIX_GCC = callPackage_i686 ({gcc}: gcc) {};
  i686_libxml2 = callPackage_i686 ({libxml2}: libxml2) {};
  i686_glibc = callPackage_i686 ({glibc}: glibc) {};

  src_canon = fetchurl {
    url = "http://files.canon-europe.com/files/soft46710/Software/o151en_linux_UFRII_v310.zip";
    sha256 = "1j659nm9v4jpk1ycaf074f4yvw23rns0338q3gzb7sppq5pkvy9k";
  };

in


stdenv.mkDerivation rec {
  name = "canon-cups-ufr2-3.10";
  src = src_canon;

  phases = [ "unpackPhase" "installPhase" ];

  postUnpack = ''
    (cd $sourceRoot; tar -xzf Sources/cndrvcups-common-3.40-1.tar.gz)
    (cd $sourceRoot; tar -xzf Sources/cndrvcups-lb-3.10-1.tar.gz)
  '';

  nativeBuildInputs = [ makeWrapper unzip autoreconfHook libtool ];

  buildInputs = [ cups ];

  installPhase = ''
    ##
    ## cndrvcups-common buildPhase
    ##
    ( cd cndrvcups-common-3.40/buftool
      autoreconf -fi
      ./autogen.sh --prefix=$out --enable-progpath=$out/bin --libdir=$out/lib --disable-shared --enable-static
      make
    )

    ( cd cndrvcups-common-3.40/backend
      ./autogen.sh --prefix=$out --libdir=$out/lib
      make
    )

    ( cd cndrvcups-common-3.40/c3plmod_ipc
      make
    )

    ##
    ## cndrvcups-common installPhase
    ##

    ( cd cndrvcups-common-3.40/buftool
      make install
    )

    ( cd cndrvcups-common-3.40/backend
      make install
    )

    ( cd cndrvcups-common-3.40/c3plmod_ipc
      make install DESTDIR=$out/lib
    )

    ( cd cndrvcups-common-3.40/libs
      chmod 755 *
      mkdir -p $out/lib32
      mkdir -p $out/bin
      cp libcaiowrap.so.1.0.0 $out/lib32
      cp libcaiousb.so.1.0.0 $out/lib32
      cp libc3pl.so.0.0.1 $out/lib32
      cp libcaepcm.so.1.0 $out/lib32
      cp libColorGear.so.0.0.0 $out/lib32
      cp libColorGearC.so.0.0.0 $out/lib32
      cp libcanon_slim.so.1.0.0 $out/lib32
      cp c3pldrv $out/bin
    )

    (cd cndrvcups-common-3.40/data
      chmod 644 *.ICC
      mkdir -p $out/share/caepcm
      cp *.ICC $out/share/caepcm
    )

    (cd $out/lib32
      ln -sf libc3pl.so.0.0.1 libc3pl.so.0
      ln -sf libc3pl.so.0.0.1 libc3pl.so
      ln -sf libcaepcm.so.1.0 libcaepcm.so.1
      ln -sf libcaepcm.so.1.0 libcaepcm.so
      ln -sf libcaiowrap.so.1.0.0 libcaiowrap.so.1
      ln -sf libcaiowrap.so.1.0.0 libcaiowrap.so
      ln -sf libcaiousb.so.1.0.0 libcaiousb.so.1
      ln -sf libcaiousb.so.1.0.0 libcaiousb.so
      ln -sf libcanon_slim.so.1.0.0 libcanon_slim.so.1
      ln -sf libcanon_slim.so.1.0.0 libcanon_slim.so
      ln -sf libColorGear.so.0.0.0 libColorGear.so.0
      ln -sf libColorGear.so.0.0.0 libColorGear.so
      ln -sf libColorGearC.so.0.0.0 libColorGearC.so.0
      ln -sf libColorGearC.so.0.0.0 libColorGearC.so
    )

    (cd $out/lib
      ln -sf libcanonc3pl.so.1.0.0 libcanonc3pl.so
      ln -sf libcanonc3pl.so.1.0.0 libcanonc3pl.so.1
    )

    patchelf --set-rpath "$(cat ${i686_NIX_GCC}/nix-support/orig-cc)/lib" $out/lib32/libColorGear.so.0.0.0
    patchelf --set-rpath "$(cat ${i686_NIX_GCC}/nix-support/orig-cc)/lib" $out/lib32/libColorGearC.so.0.0.0

    patchelf --interpreter "$(cat ${i686_NIX_GCC}/nix-support/dynamic-linker)" --set-rpath "$out/lib32" $out/bin/c3pldrv

    # c3pldrv is programmed with fixed paths that point to "/usr/{bin,lib.share}/..."
    # preload32 wrappes all necessary function calls to redirect the fixed paths
    # into $out.
    mkdir -p $out/libexec
    preload32=$out/libexec/libpreload32.so
    ${i686_NIX_GCC}/bin/gcc -shared ${./preload.c} -o $preload32 -ldl -DOUT=\"$out\" -fPIC
    wrapProgram "$out/bin/c3pldrv" \
      --set PRELOAD_DEBUG 1 \
      --set LD_PRELOAD $preload32 \
      --prefix LD_LIBRARY_PATH : "$out/lib32"



    ##
    ## cndrvcups-lb buildPhase
    ##

    ( cd cndrvcups-lb-3.10/ppd
      ./autogen.sh --prefix=$out
      make
    )

    ( cd cndrvcups-lb-3.10/pstoufr2cpca
      CPPFLAGS="-I$out/include" LDFLAGS=" -L$out/lib" ./autogen.sh --prefix=$out --enable-progpath=$out/bin
      make
    )

    ( cd cndrvcups-lb-3.10/cpca
      autoreconf -fi || true    # TODO: Is it neccessary to run `autoreconf -fi` and ignore it's failure?
      CPPFLAGS="-I$out/include" LDFLAGS=" -L$out/lib" ./autogen.sh --prefix=$out --enable-progpath=$out/bin  --enable-static
      make
    )

    ##
    ## cndrvcups-lb installPhase
    ##

    ( cd cndrvcups-lb-3.10/ppd
      make install
    )

    ( cd cndrvcups-lb-3.10/pstoufr2cpca
      make install
    )

    ( cd cndrvcups-lb-3.10/cpca
      make install
    )

    ( cd cndrvcups-lb-3.10/libs
      chmod 755 *
      mkdir -p $out/lib32
      mkdir -p $out/bin
      cp libcanonufr2.la $out/lib32
      cp libcanonufr2.so.1.0.0 $out/lib32
      cp libufr2filter.so.1.0.0 $out/lib32
      cp libEnoJBIG.so.1.0.0 $out/lib32
      cp libEnoJPEG.so.1.0.0 $out/lib32
      cp libcaiocnpkbidi.so.1.0.0 $out/lib32
      cp libcnlbcm.so.1.0 $out/lib32

      cp cnpkmoduleufr2 $out/bin #maybe needs setuid 4755
      cp cnpkbidi $out/bin
    )

    ( cd $out/lib32
      ln -sf libcanonufr2.so.1.0.0 libcanonufr2.so
      ln -sf libcanonufr2.so.1.0.0 libcanonufr2.so.1
      ln -sf libufr2filter.so.1.0.0 libufr2filter.so
      ln -sf libufr2filter.so.1.0.0 libufr2filter.so.1
      ln -sf libEnoJBIG.so.1.0.0 libEnoJBIG.so
      ln -sf libEnoJBIG.so.1.0.0 libEnoJBIG.so.1
      ln -sf libEnoJPEG.so.1.0.0 libEnoJPEG.so
      ln -sf libEnoJPEG.so.1.0.0 libEnoJPEG.so.1
      ln -sf libcaiocnpkbidi.so.1.0.0 libcaiocnpkbidi.so
      ln -sf libcaiocnpkbidi.so.1.0.0 libcaiocnpkbidi.so.1
      ln -sf libcnlbcm.so.1.0 libcnlbcm.so.1
      ln -sf libcnlbcm.so.1.0 libcnlbcm.so
    )

    ( cd cndrvcups-lb-3.10
      chmod 644 data/CnLB*
      chmod 644 libs/cnpkbidi_info*
      chmod 644 libs/ThLB*
      mkdir -p $out/share/caepcm
      mkdir -p $out/share/cnpkbidi
      mkdir -p $out/share/ufr2filter
      cp data/CnLB* $out/share/caepcm
      cp libs/cnpkbidi_info* $out/share/cnpkbidi
      cp libs/ThLB* $out/share/ufr2filter
    )

    patchelf --set-rpath "$out/lib32:${i686_libxml2.out}/lib" $out/lib32/libcanonufr2.so.1.0.0

    patchelf --interpreter "$(cat ${i686_NIX_GCC}/nix-support/dynamic-linker)" --set-rpath "$out/lib32" $out/bin/cnpkmoduleufr2
    patchelf --interpreter "$(cat ${i686_NIX_GCC}/nix-support/dynamic-linker)" --set-rpath "$out/lib32:${i686_libxml2.out}/lib" $out/bin/cnpkbidi

    makeWrapper "${ghostscript}/bin/gs" "$out/bin/gs" \
      --prefix LD_LIBRARY_PATH ":" "$out/lib" \
      --prefix PATH ":" "$out/bin"
    '';

  meta = {
    description = "CUPS Linux drivers for Canon printers";
    homepage = "http://www.canon.com/";
    license = stdenv.lib.licenses.unfree;
  };
}
