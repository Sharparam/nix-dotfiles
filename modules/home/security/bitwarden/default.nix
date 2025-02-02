{
  lib,
  pkgs,
  namespace,
  config,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.security.bitwarden;
  is-linux = pkgs.stdenv.isLinux;
  is-darwin = pkgs.stdenv.isDarwin;
in
{
  options.${namespace}.security.bitwarden = with types; {
    enable = mkEnableOption "Enable Bitwarden";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        bitwarden-cli
      ]
      ++ optional is-linux bitwarden-desktop;

    homebrew.casks = mkIf is-darwin [ "bitwarden" ];
  };
}
