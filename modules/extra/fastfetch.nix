{
  config,
  lib,
  ...
}:

lib.module config "fastfetch" true {
    home-manager.sharedModules = [
      {
        programs.fastfetch = {
          enable = true;
          settings = {
            logo = {
              type = "none";
            };
            display = {
              separator = " ";
              key = {
                width = 6;
              };
            };
            modules = [
              "break"
              {
                type = "custom";
                format = "{#yellow}SYSTEM{#}";
              }
              "break"
              {
                type = "title";
                key = "USR";
                keyColor = "red";
              }
              {
                type = "command";
                key = "AGE";
                keyColor = "green";
                text = "birth=$(stat -c %W /); if [ \"$birth\" -eq 0 ]; then birth=$(stat -c %Y /); fi; diff=$(($(date +%s) - birth)); echo \"$((diff / 86400))D $(((diff % 86400) / 3600))H $(((diff % 3600) / 60))M\"";
              }
              {
                type = "os";
                key = "OPS";
                keyColor = "yellow";
                format = "{pretty-name}";
              }
              {
                type = "command";
                key = "KRN";
                keyColor = "blue";
                text = "uname -sr | cut -d'-' -f1";
              }
              {
                type = "packages";
                key = "PKG";
                keyColor = "magenta";
                format = "{all}";
              }
              {
                type = "wm";
                key = "WDM";
                keyColor = "cyan";
                format = "{pretty-name}";
              }
              {
                type = "terminal";
                key = "TER";
                keyColor = "red";
                format = "{pretty-name}";
              }
              {
                type = "shell";
                key = "SHL";
                keyColor = "green";
                format = "{pretty-name}";
              }
              "break"
              {
                type = "custom";
                format = "{#yellow}HARDWARE{#}";
              }
              "break"
              {
                type = "cpu";
                key = "CPU";
                keyColor = "yellow";
              }
              {
                type = "gpu";
                key = "GPU";
                keyColor = "blue";
                hideType = "integrated";
                format = "{name}";
              }
              {
                type = "memory";
                key = "MEM";
                keyColor = "magenta";
              }
              {
                type = "uptime";
                key = "UPT";
                keyColor = "cyan";
              }
            ];
          };
        };
      }
    ];}