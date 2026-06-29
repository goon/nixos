{
  config,
  lib,
  ...
}:
lib.module config "starship" false {
  homeManager = {
    programs.starship = {
      enable = true;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        format = "$username$hostname$directory$git_branch$cmd_duration$line_break$character";
        add_newline = false;
        directory.style = "blue";
        character = {
          success_symbol = "[❯](purple)";
          error_symbol = "[❯](red)";
          vimcmd_symbol = "[❮](green)";
        };
        git_branch = {
          format = "[$branch]($style)";
          style = "bright-black";
        };
        cmd_duration = {
          format = "[$duration]($style) ";
          style = "yellow";
        };
      };
    };
  };
}
