{
  programs.zsh.initExtra =
    let
      proxy = "internet.ford.com:83/";
      no_proxy = "127.0.0.1,localhost,.ford.com,ford.com,.login.microsoftonline.com,.aadcdn.msftauth.net,.logincdn.msftauth.net,.login.live.com,.msauth.net,.aac
   dn.microsoftonline-p.com,.microsoftonline-p.com,.aadcdn.msauth.cn,.aadcdn.msftauth.cn,.microsoftonline.cn,.azure.cn,.microsoft.cn,.chinacloudapi.cn,.trafficmanager.
   cn,.windowsazure.cn";
      proxy_file = "$XDG_CACHE_HOME/my.should.proxy";
    in
    ''
      enable_proxy() {
        export http_proxy="http://${proxy}"
        export https_proxy="http://${proxy}"
        export ftp_proxy="ftp://${proxy}"
        export no_proxy="${no_proxy}"
        export HTTP_PROXY="http://${proxy}"
        export HTTPS_PROXY="http://${proxy}"
        export FTP_PROXY="ftp://${proxy}"
        export NO_PROXY="${no_proxy}"
        if [ ! -e ${proxy_file} ]; then
          echo '
          [Service]
          Environment=http_proxy=http://${proxy}
          Environment=https_proxy=http://${proxy}
          Environment=ftp_proxy=ftp://${proxy}
          Environment=no_proxy=${no_proxy}
          Environment=HTTP_PROXY=http://${proxy}
          Environment=HTTPS_PROXY=http://${proxy}
          Environment=FTP_PROXY=ftp://${proxy}
          Environment=NO_PROXY=${no_proxy}
          ' | sudo tee /etc/systemd/system/nix-daemon.service.d/override.conf > /dev/null

          echo '
          Acquire::http::Proxy "http://${proxy}";
          Acquire::https::Proxy "http://${proxy}";
          Acquire::ftp::Proxy "ftp://${proxy}";
          Acquire::http::Proxy {
            apl900359.hosts.cloud.ford.com DIRECT;
            apl900361.hosts.cloud.ford.com DIRECT;
          }
          DPkg::Options { "--force-confdef"; "--force-confold"; }
          ' | sudo tee /etc/apt/apt.conf.d/95ford-custom > /dev/null

          echo '
          {
            "proxies": {
              "http-proxy": "http://${proxy}",
              "https-proxy": "http://${proxy}",
              "no-proxy": "${no_proxy}"
            }
          }
          ' | sudo tee /etc/docker/daemon.json > /dev/null

          echo '
          {
            "proxies": {
              "default": {
                "http-proxy": "http://${proxy}",
                "https-proxy": "http://${proxy}",
                "no-proxy": "${no_proxy}"
              }
            }
          }
          ' | sudo tee ~/.docker/config.json > /dev/null
          
          gsettings set org.gnome.system.proxy mode auto

          sudo systemctl daemon-reload
          sudo systemctl restart nix-daemon.service
          sudo systemctl restart docker.service

          sudo snap set system "proxy.http=$HTTP_PROXY"
          sudo snap set system "proxy.https=$HTTPS_PROXY"
        fi
        touch ${proxy_file} > /dev/null || true
      }
      disable_proxy() {
        rm -f ${proxy_file} > /dev/null || true
        unset http_proxy
        unset https_proxy
        unset ftp_proxy
        unset no_proxy
        unset HTTP_PROXY
        unset HTTPS_PROXY
        unset FTP_PROXY
        unset NO_PROXY
        sudo rm /etc/systemd/system/nix-daemon.service.d/override.conf /etc/apt/apt.conf.d/95ford-custom
        sudo rm ~/.docker/config.json /etc/docker/daemon.json
        gsettings set org.gnome.system.proxy mode none

        sudo systemctl daemon-reload
        sudo systemctl restart nix-daemon.service
        sudo systemctl restart docker.service

        sudo snap set system "proxy.http=$HTTP_PROXY"
        sudo snap set system "proxy.https=$HTTPS_PROXY"
      }

      if [ -e ${proxy_file} ]; then
        enable_proxy
      fi
    '';
}
