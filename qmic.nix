{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "qmic";
  version = "unstable";

  src = (import ./sources.nix { inherit fetchFromGitHub; }).qmic;

  makeFlags = [ "prefix=$(out)" ];
}
