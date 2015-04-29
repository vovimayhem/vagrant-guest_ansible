require "vagrant"

module VagrantPlugins
  module GuestAnsible
    class Plugin < Vagrant.plugin("2")
      name "vagrant-guest_ansible"
      description <<-DESC
Provides support for provisioning your virtual machines with
Ansible playbooks on host environments without ansible (Windows).
DESC

      config(:guest_ansible, :provisioner) do
        require File.expand_path("../config", __FILE__)
        Config
      end

      provisioner(:guest_ansible) do
        require File.expand_path("../provisioner", __FILE__)
        Provisioner
      end
    end

  end
end
