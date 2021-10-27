{
  kevin-nix = builtins.fetchTarball {
    url = "https://github.com/thefloweringash/kevin-nix/archive/fedcf821bca2ff4798e4436b1bc5813962bea8b5.tar.gz";
    sha256 = "05yqasr2a1wg75bjjd2fdxnscnz35hb53gf347i3hbgrfwmvysrl";
  };
  cadmium = builtins.fetchTarball {
    url = "https://github.com/Maccraft123/Cadmium/archive/e405d086dd6579499811436cd9979c392d0fa4e6.tar.gz";
    sha256 = "0wk6m0w7grrfkfqisghax0xa4ykynlz2l5gc0rbzffqlfb92l403";
  };
}
