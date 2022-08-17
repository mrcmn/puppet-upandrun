If you are using Puppet bolt together with the vagrant machines in this repo, you can use the following example inventory.yaml file. Create a bolt project directory (within the puppet-upandrun directory), copy the inventory.yaml below and replace the directories for the SSH Keyfiles.

## See following for ssh config: ##
```
vagrant ssh-config linux.vm
vagrant ssh-config primary.vm
```

## inventory.yaml ##
```
groups:
  - name: linux
    targets:
      - name: pe
        uri: 192.168.50.4
        config:
          transport: ssh
          ssh:
            private-key: /Users/<path-to>/puppet-upandrun/.vagrant/machines/primary.vm/virtualbox/private_key
      - name: nix
        uri: 192.168.50.6
        config:
          transport: ssh
          ssh:
            private-key: /Users/<path-to>/puppet-upandrun/.vagrant/machines/linux.vm/virtualbox/private_key
  - name: windows
    targets:
      - name: win
        uri: 192.168.50.5
    config:
      transport: winrm
config:
  ssh:
    user: vagrant
    password: vagrant
    host-key-check: false
  winrm:
    user: vagrant
    password: vagrant
    ssl: false
```

## Usage ##
```
bolt command run "echo 1" --targets nix,win,pe
bolt command run "hostname -I" --targets linux
```
