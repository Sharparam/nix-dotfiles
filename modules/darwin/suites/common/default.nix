{
  lib,
  pkgs,
  namespace,
  options,
  config,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.common;
in
{
  options.${namespace}.suites.common = with types; {
    enable = mkEnableOption "Whether or not to enable the common configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      snix.scripts
      catppuccin-cursors.frappeDark
    ];

    programs.zsh = enabled;

    catppuccin = {
      enable = true;
      flavor = "frappe";
    };

    ${namespace} = {
      nix = enabled;

      system = {
        interface = enabled;
      };

      security = {
        age = enabled;
        gpg = enabled;
      };

      services = {
        openssh = enabled;
      };
    };
  };
}
