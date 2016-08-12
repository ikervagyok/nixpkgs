{ stdenv, fetchFromGitHub, jdk, ant, autoconf, automake, libtool }:

stdenv.mkDerivation rec {
  name = "jna";

  src = fetchFromGitHub {
    owner = "java-native-access";
    repo = "jna";
    rev = "4bcc6191c5467361b5c1f12fb5797354cc3aa897";
    sha256 = "0s5pzgxxpl6xghmfnr4bbvv63m5fsylsyddp3n04br850m3x1n2m";
  };

  buildInputs = [ jdk ant autoconf automake libtool ];

  LD_LIBRARY_PATH = "${jdk}/include";

  JAVA_HOME=jdk;
  JAVA="${jdk}/bin/java";

  buildPhase = ''
    sed -r -i -e 's|(<available file=")\$\{java.home}(/include"/>)|\1${jdk}\2|' build.xml
    sed -r -i -e 's|||' build.xml
    ant
'';

  meta = {
    homepage = "https://github.com/java-native-access/jna";
    description = "";
    license = stdenv.lib.licenses.lgpl21;
    platforms = stdenv.lib.platforms.linux;
  };

}
