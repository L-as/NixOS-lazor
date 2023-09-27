{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "qrtr";
  version = "unstable";

  src = (import ./sources.nix { inherit fetchFromGitHub; }).qrtr;

  makeFlags = [ "prefix=$(out)" ];
}
