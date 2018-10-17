module VagrantPlugins
  module GuestAnsible
    class Provisioner < Vagrant.plugin("2", :provisioner)

      def initialize(machine, config)
        super
      end

      def provision

        args = [
          config.playbook,
          File.basename(self.setup_inventory_file),
          format_extra_vars(config.extra_vars),
          "#{config.galaxy_command}",
          config.galaxy_role_file,
          config.galaxy_roles_path
        ].join(' ')

        command = "chmod +x #{config.upload_path} && #{config.upload_path} #{args}"

        with_script_file do |path|

          # Upload the script to the machine
          @machine.communicate.tap do |comm|
            # Reset upload path permissions for the current ssh user
            user = @machine.ssh_info[:username]
            comm.sudo("chown -R #{user} #{config.upload_path}",
                      :error_check => false)

            comm.upload(path.to_s, config.upload_path)

            @machine.ui.info(I18n.t("vagrant.provisioners.shell.running",
                                      script: path.to_s))

            # Execute it with sudo
            comm.execute(command, sudo: config.sudo) do |type, data|
              if [:stderr, :stdout].include?(type)
                # Output the data with the proper color based on the stream.
                color = type == :stdout ? :green : :red

                options = {
                  new_line: false,
                  prefix: false,
                }
                options[:color] = color if !config.keep_color

                @machine.env.ui.info(data, options)
              end
            end
          end
        end
      end

      protected

      # converts the extra_vars to a properly formatted string
      def format_extra_vars(extra_vars)
        if extra_vars.kind_of?(String)
          extra_vars.strip
        elsif extra_vars.kind_of?(Hash)
          "\"#{extra_vars.to_json.gsub('"', '\"')}\""
        end
      end

      # This method yields the path to a script to upload and execute
      # on the remote server. This method will properly clean up the
      # script file if needed.
      def with_script_file
        script = nil

        if config.remote?
          download_path = @machine.env.tmp_path.join("#{@machine.id}-remote-script")
          download_path.delete if download_path.file?

          Vagrant::Util::Downloader.new(config.path, download_path).download!
          script = download_path.read

          download_path.delete
        elsif config.path
          # Just yield the path to that file...
          root_path = @machine.env.root_path
          script = Pathname.new(config.path).expand_path(root_path).read
        else
          # The script is just the inline code...
          script = config.inline
        end

        # Replace Windows line endings with Unix ones unless binary file
        script.gsub!(/\r\n?$/, "\n") if !config.binary

        # Otherwise we have an inline script, we need to Tempfile it,
        # and handle it specially...
        file = Tempfile.new('vagrant-shell')

        # Unless you set binmode, on a Windows host the shell script will
        # have CRLF line endings instead of LF line endings, causing havoc
        # when the guest executes it. This fixes [GH-1181].
        file.binmode

        begin
          file.write(script)
          file.fsync
          file.close
          yield file.path
        ensure
          file.close
          file.unlink
        end
      end

      # Auto-generate "safe" inventory file based on Vagrantfile,
      # unless inventory_path is explicitly provided
      def setup_inventory_file
        return config.inventory_path if config.inventory_path

        ssh = @machine.ssh_info

        generated_inventory_file =
          @machine.env.root_path.join("vagrant_ansible_inventory_#{machine.name}")

        generated_inventory_file.open('w') do |file|
          file.write("# Generated by Vagrant\n\n")
          file.write("#{machine.name} ansible_ssh_host=#{ssh[:host]} ansible_ssh_port=#{ssh[:port]}\n")

          # Write out groups information.  Only include current
          # machine and its groups to avoid Ansible errors on
          # provisioning.
          groups_of_groups = {}
          included_groups = []

          config.groups.each_pair do |gname, gmembers|
            if gname.end_with?(":children")
              groups_of_groups[gname] = gmembers
            elsif gmembers.include?("#{machine.name}")
              included_groups << gname
              file.write("\n[#{gname}]\n")
              file.write("#{machine.name}\n")
            end
          end

          groups_of_groups.each_pair do |gname, gmembers|
            unless (included_groups & gmembers).empty?
              file.write("\n[#{gname}]\n")
              gmembers.each do |gm|
                file.write("#{gm}\n") if included_groups.include?(gm)
              end
            end
          end
        end

        return generated_inventory_file.to_s
      end

    end
  end
end
