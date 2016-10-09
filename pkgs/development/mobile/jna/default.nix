{stdenv, fetchurl, jre, makeWrapper }:

let
  version = "4.2.2";
  name = "jna-${version}";

in stdenv.mkDerivation {

  name = "${name}";

  jar = fetchurl {
    url = "https://maven.java.net/content/repositories/releases/net/java/dev/jna/jna/${version}/${name}.jar";
    sha256 = "1gmx27mxsfa6ncki31xlvmfylbcm5c2jrfirpxnnyvkcw1aayf0z";
  };

  buildInputs = [ makeWrapper ];

  phases = "installPhase";

  installPhase = ''
    mkdir -p $out/share/java
    ln -s $jar $out/share/java/jna.jar
    makeWrapper ${jre}/bin/java $out/bin/jna --add-flags "-jar $out/share/java/jna.jar"
  '';

  meta = {
    description = "";
#   homepage = ;
#   license = stdenv.lib.licenses.bsd3;
  };
}
