{
  kevin-nix = builtins.fetchTarball {
    url = "https://github.com/thefloweringash/kevin-nix/archive/fedcf821bca2ff4798e4436b1bc5813962bea8b5.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };
  cadmium = pkgs.fetchFromGitHub {
    owner = "Maccraft123";
    repo = "Cadmium";
    rev = "e405d086dd6579499811436cd9979c392d0fa4e6";
    sha256 = "AxAq0nIUO/dXBuwVKj61fnqiOugKPh2xmy7ndzioZnI=";
  };
}
