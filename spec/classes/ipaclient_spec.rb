require 'spec_helper'

describe 'ipaclient' do
  let :default_facts do
    { :is_ipa_server   => false }
  end

  # Minimum needed: join_pw
  context "Without Required Options" do
    let(:facts) {
      default_facts.merge({
        :osfamily        => 'RedHat',
        :operatingsystem => 'Fedora'
      })
    }

    let(:params) { { :mkhomedir => true } }

    it "should fail without required options" do
      expect { subject }.to raise_error(/Require at least a join password/)
    end
  end

  # Only RedHat clones & Fedora are supported
  context 'on unsupported operatingsystem' do
    let :facts do
      {
        :operatingsystem => 'unsupported',
        :osfamily        => 'Linux',
      }
    end

    it 'should fail' do
      expect { subject }.to raise_error(/does not support/)
    end
  end

  # Automatic discovery is when the FreeIPA installer
  # will look at DNS SRV records for installation.
  # This method doesn't configure sudo or anything
  # else.
  context "Fedora - Automatic Install with Discovery" do
    let(:facts) {
      default_facts.merge({
        :osfamily        => 'RedHat',
        :operatingsystem => 'Fedora',
      })
    }

    let(:params) {
      {
        :manual_register => false,
        :mkhomedir       => true,
        :join_pw         => "unicorns",
        :ipa_options     => "--permit",
      }
    }

    it "should have the right package name"  do
      should contain_package('freeipa-client')
    end

    it "should generate the right command" do
      should contain_exec('ipa_installer').
        with_command(/\/usr\/sbin\/ipa-client-install\s+--password unicorns\s+--unattended\s+--force\s+--mkhomedir\s+--permit/)
    end

    it "should not configure sudo" do
      should_not contain_class('ipaclient::sudoers')
    end
  end

  # Manual installation is when the FreeIPA installer
  # does not use DNS SRV records for discovery.  This
  # context also configures sudo via FreeIPA.
  context 'RHEL - Manual Installation with All Features' do
    let(:facts) {
      default_facts.merge({
        :osfamily        => 'RedHat',
        :operatingsystem => 'RedHat',
      })
    }

    let(:params) {
      { 
        :manual_register => true,
        :mkhomedir       => false,
        :join_pw         => "unicorns",
        :join_user       => "rainbows",
        :enrollment_host => "ipa01.pixiedust.com",
        :ipa_server      => "ipa.pixiedust.com",
        :ipa_domain      => "pixiedust.com",
        :ipa_realm       => "PIXIEDUST.COM",
        :replicas        => ["ipa01.pixiedust.com, ipa02.pixiedust.com"],
        :domain_dn       => "dc=pixiedust,dc=com",
        :sudo_bindpw     => "unicorns",
        :enable_sudo     => true,
      }
    }

    it "should install the right package" do
      should contain_package('ipa-client').with({
        'ensure'  => 'installed'
      })
    end

    it "should generate the correct command" do
      should contain_exec('ipa_installer').with_command(/\/usr\/sbin\/ipa-client-install\s+--password\s+unicorns\s+--realm\s+PIXIEDUST.COM\s+--unattended\s+--force\s+--server\s+ipa01.pixiedust.com\s+--domain pixiedust.com\s+--principal\s+rainbows\\@PIXIEDUST.COM\s+/)
    end

    it "should set krb5.conf to use the virutal host" do
      should contain_file('/etc/krb5.conf').with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      }).
        with_content(/kdc = ipa.pixiedust.com:88/).
        with_content(/master_kdc = ipa.pixiedust.com:88/).
        with_content(/admin_server = ipa.pixiedust.com:749/).
        with_content(/default_domain = pixiedust.com/)
    end

      
    it "should configure sudoers" do
      should contain_class('ipaclient::sudoers').with({
        'ipa_domain'  => 'pixiedust.com',
        'replicas'    => ["ipa01.pixiedust.com, ipa02.pixiedust.com"],
        'domain_dn'   => "dc=pixiedust,dc=com",
        'sudo_bindpw' => 'unicorns'
      })
    end
  end

  # Any non-Fedora OS in the Red Hat family gets "ipa-client" package
  context 'RHEL-Compatible Support' do
    let(:facts) {
      default_facts.merge({
        :osfamily        => 'RedHat',
        :operatingsystem => 'Whatever',
      })
    }

    let(:params) {
      {
        :manual_register => false,
        :mkhomedir       => true,
        :join_pw         => "unicorns",
      }
    }

    it "should have the right package name"  do
      should contain_package('ipa-client')
    end
  end

  # Allow $ipa_server to be an array
  context "IPA Server List is Array" do
    let(:facts) {
      default_facts.merge({
        :osfamily        => 'RedHat',
        :operatingsystem => 'Fedora',
      })
    }

    let(:params) {
      {
        :manual_register => false,
        :mkhomedir       => true,
        :ipa_server      => ["ipa01.example.com", "ipa02.example.com"],
        :join_pw         => "unicorns",
        :ipa_options     => "--permit",
      }
    }

    it "should generate the right command" do
      should contain_exec('ipa_installer').
        with_command(/\/usr\/sbin\/ipa-client-install\s+--password unicorns\s+--unattended\s+--force\s+--mkhomedir\s+--server\s+ipa01.example.com\s+--server\s+ipa02.example.com\s+--permit/)
    end
  end

  # Allow $ipa_server to be a string
  context "IPA Server List is String" do
    let(:facts) {
      default_facts.merge({
        :osfamily        => 'RedHat',
        :operatingsystem => 'Fedora',
      })
    }

    let(:params) {
      {
        :manual_register => false,
        :mkhomedir       => true,
        :ipa_server      => "ipa01.example.com", 
        :join_pw         => "unicorns",
        :ipa_options     => "--permit",
      }
    }

    it "should generate the right command" do
      should contain_exec('ipa_installer').
        with_command(/\/usr\/sbin\/ipa-client-install\s+--password unicorns\s+--unattended\s+--force\s+--mkhomedir\s+--server\s+ipa01.example.com\s+--permit/)
    end
  end
end
