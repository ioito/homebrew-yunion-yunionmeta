class YunionYunionmeta < Formula
  desc "Yunion Cloud Meta Controller Service"
  homepage "YunionMeta"
  version_scheme 1
  head "https://quxuan@git.yunion.io/scm/cloud/yunionmeta.git",
    :branch      => "master"
  
  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    (buildpath/"src/yunion.io/x/yunionmeta").install buildpath.children
    cd buildpath/"src/yunion.io/x/yunionmeta" do
      system "make", "GOOS=darwin", "cmd/yunionmeta"
      bin.install "_output/bin/yunionmeta"
      prefix.install_metafiles
    end

    (buildpath/"yunionmeta.conf").write yunionmeta_conf
    etc.install "yunionmeta.conf"
  end

  def post_install
    (var/"log/region").mkpath
  end

  def yunionmeta_conf; <<~EOS
  region = 'Yunion'
  address = '127.0.0.1'
  port = 8787
  auth_uri = 'https://127.0.0.1:35357/v3'
  admin_user = 'sysadmin'
  admin_password = 'sysadmin'
  admin_tenant_name = 'system'
  sql_connection = 'mysql+pymysql://yunionmeta:uFhm1KNVdBmMdoRM@127.0.0.1:3306/yunionmeta?charset=utf8'
  enable_ssl = false
  ssl_certfile = '/opt/yunionsetup/config/keys/yunionmeta/region-full.crt'
  ssl_keyfile = '/opt/yunionsetup/config/keys/yunionmeta/region.key'
  ssl_ca_certs = '/opt/yunionsetup/config/keys/yunionmeta/ca.crt'
  EOS
  end

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>RunAtLoad</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/yunionmeta</string>
        <string>--conf</string>
        <string>#{etc}/yunionmeta.conf</string>
        <string>--auto-sync-table</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/yunionmeta/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/yunionmeta/output.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system "false"
  end
end
