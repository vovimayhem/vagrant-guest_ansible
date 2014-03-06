# vagrant-guest_ansible Provisioner

Run ansible provisioning from Vagrant inside the guest machine.

This provider is a mix between the original Ansible provisioner bundled with
Vagrant, and the Shell provisioner which is also bundled in Vagrant.

The Ansible hosts file is generated in the shared folder (like the Ansible plugin) if no 
hosts inventory file is given.

It uses a modified shell script file (see credits) that's uploaded to
the guest machine, installs any dependencies (Git, ansible, etc) and then
runs the ansible provisioning scripts locally (at the guest machine).

## Installation

Use the Vagrant plugin installer:

```bash
$ vagrant plugin install vagrant-guest_ansible
```

## Usage

In the Vagrantfile:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provision :guest_ansible do |guest_ansible|
    guest_ansible.playbook = main_playbook
    guest_ansible.extra_vars = extra_vars
    guest_ansible.sudo = false
  end
end
```

This provisioner is actually more useful in Windows hosts, where ansible is not supported nor available.
A typical Vagrantfile that works in windows may look like this:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  if Vagrant::Util::Platform.windows?
    config.vm.provision :guest_ansible do |guest_ansible|
      guest_ansible.playbook = "any_playbook.yml"
      guest_ansible.sudo = false
    end
  else
    config.vm.provision :ansible do |ansible|
      ansible.playbook = "any_playbook.yml"
    end
  end
end
```

## Credits

The shell script that is run in the guest machine was based on:

- https://github.com/KSid/windows-vagrant-ansible
- https://github.com/geerlingguy/JJG-Ansible-Windows

## Contributing

1. Fork it ( http://github.com/vovimayhem/vagrant-guest_ansible/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
