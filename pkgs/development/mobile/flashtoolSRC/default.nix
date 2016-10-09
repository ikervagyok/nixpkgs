{ stdenv, fetchFromGitHub, jdk, libusb1, platformTools, gtk2, glib, libXtst, swt, makeWrapper, unyaffs, jna, ant }:

assert stdenv.isLinux;

let

  CP = "$(find -iname \"*.jar\" | xargs | tr ' ' ':')";
  SWT = "${swt}/jars/swt.jar";

  ARCH = if stdenv.system == "i686-linux" then "32" else "64";

  version = "0.9.22.3";

in

stdenv.mkDerivation rec {
  name = "flashtool-${version}";

  src = fetchFromGitHub {
    owner = "Androxyde";
    repo = "Flashtool";
    rev = "ba0404400a256ee9c0debecdebecf3fec292ea64";
    sha256 = "115z1c1wqax2318azwvrykqa5zpf25ixw8hznzc1g6xb01p7yhkx";
  };

  buildInputs = [ jdk swt makeWrapper unyaffs jna ant ];

  patchPhase = ''
    sed -i '53,62d' ant/setup-linux.xml
  '';

  buildPhase = ''
    mkdir bin
    ant -buildfile ant/deploy-release.xml
    ant -buildfile ant/setup-linux.xml binaries

    rm ../Deploy/FlashTool/x10flasher_lib/{adb,fastboot}.linux.*
    ln -s ${platformTools}/platform-tools/adb ../Deploy/FlashTool/x10flasher_lib/adb.linux.${ARCH}
    ln -s ${platformTools}/platform-tools/fastboot ../Deploy/FlashTool/x10flasher_lib/fastboot.linux.${ARCH}
    ln -s ${libusb1.out}/lib/libusb-1.0.so.0 ../Deploy/FlashTool/x10flasher_lib/linux/lib${ARCH}/libusbx-1.0.so
  '';

  installPhase = ''
    rm ../Deploy/FlashTool/FlashTool
    cp -r ../Deploy/FlashTool $out/

    cd $out
    makeWrapper ${jdk}/bin/java $out/FlashTool \
      --set JAVA_HOME "${jdk}" \
      --set LD_LIBRARY_PATH "${libXtst}/lib:${glib}/lib:${gtk2}/lib:${libusb1}/lib:${swt}/lib:$out/x10flasher_lib/linux/lib${ARCH}:\$LD_LIBRARY_PATH" \
      --add-flags "-classpath $out/x10flasher.jar:${CP}:${SWT} -Xms128m -Xmx512m -Duser.country=US -Duser.language=en -Djsse.enableSNIExtension=false gui.Main"
    sed -i 's|Main.*$|Main|' $out/FlashTool
    sed -i "s|./x10flasher_lib|$out/x10flasher_lib|g" $out/FlashTool
  '';

# preFixup = ''
#   chmod -x "$out/custom"
# '';

# postFixup = ''
#   chmod +x "$out/custom"
# '';

  meta = {
    homepage = "http://www.flashtool.net/";
    description = "S1 flashing software for Sony phones from X10 to Xperia Z Ultra";
    license = stdenv.lib.licenses.unfreeRedistributableFirmware; 
    platforms = stdenv.lib.platforms.linux;
    hydraPlatforms = stdenv.lib.platforms.none;
  };
}
