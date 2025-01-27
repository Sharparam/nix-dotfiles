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
  cfg = config.${namespace}.tools.git;
  user = config.${namespace}.user;
  ninetechConfig = {
    user.email = "adam.hellberg@ninetech.com";
  };
in
{
  options.${namespace}.tools.git = with types; {
    enable = mkEnableOption "Git";
    userName = mkOpt str user.fullName "The name to configure Git with.";
    userEmail = mkOpt str user.email "The email to configure Git with.";
    signingKey = mkOpt str "C58C41E27B00AD04" "The GPG key to use for signing commits and tags.";
    credentialHelper = mkOpt (nullOr str) null "The credential helper to use with Git.";
    askPass = mkOpt (nullOr str) null "The askpass program to use with Git.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ghq
      gh
    ];

    programs.git = {
      inherit (cfg) userName userEmail;
      enable = true;
      lfs = enabled;
      signing = {
        key = cfg.signingKey;
        signByDefault = true;
      };
      extraConfig = {
        core = {
          autocrlf = "input";
          askPass = mkIf (cfg.askPass != null) cfg.askPass;
        };
        init.defaultBranch = "main";
        fetch.prune = true;
        pull.ff = "only";
        push = {
          default = "simple";
          autoSetupRemote = true;
        };
        branch = {
          main.mergeoptions = "--no-ff";
          master.mergeoptions = "--no-ff";
          develop.mergeoptions = "--no-ff";
        };
        tag = {
          sort = "version:refname";
        };
        merge.conflictstyle = "zdiff3";
        rerere.enabled = true;
        trailer = {
          where = "after";
          ifexists = "addIfDifferent";
        };
        credential = mkIf (cfg.credentialHelper != null) {
          helper = cfg.credentialHelper;
        };
        github = {
          user = "Sharparam";
          username = "Sharparam";
        };
        ghq.root = "~/repos";
        # Not really using the hub tool anymore since it's deprecated
        hub.protocol = "ssh";
        url = {
          "git@github.com:Sharparam".insteadOf = "https://github.com/Sharparam";
          "git@github.com:SharpWoW".insteadOf = "https://github.com/SharpWoW";
          "git@github.com:chroma-sdk".insteadOf = "https://github.com/chroma-sdk";
          "ssh://git@github.com".pushInsteadOf = "https://github.com";
        };
      };
      includes = [
        {
          condition = "gitdir:~/projects/work/ninetech";
          contents = ninetechConfig;
        }
        {
          condition = "gitdir:~/repos/ssh.dev.azure.com/v3/ToolPal/";
          contents = ninetechConfig;
        }
      ];
    };

    ${namespace}.cli.aliases =
      let
        git = "${pkgs.git}/bin/git";
        gh = "${pkgs.gh}/bin/gh";
      in
      {
        gb = "${git} branch";
        gca = "${git} commit --verbose --all";
        gcaS = "${git} commit --verbose --all --gpg-sign";
        gcam = "${git} commit --all --message";
        gcamS = "${git} commit --all --message --gpg-sign";
        gcm = "${git} commit --message";
        gcmS = "${git} commit --message --gpg-sign";
        gfr = "${git} pull --rebase";
        gp = "${git} push";
        gpf = "${git} push --force-with-lease";
        gpF = "${git} push --force";

        "?" = "${gh} copilot suggeste -t shell";
        "??" = "${gh} copilot explain";
        "?e" = "${gh} copoilot explain";
        "?g" = "${gh} copilot suggest -t git";
        "?gh" = "${gh} copilot suggest -t gh";
      };
  };
}
