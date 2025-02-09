# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

Vagrant.require 'pathname'

Vagrant.require 'vagrant'
Vagrant.require 'vagrant/util/presence'
Vagrant.require 'vagrant/util/subprocess'

require_relative "base"

module VagrantPlugins
  module Chef
    module Provisioner
      # This class implements provisioning via chef-client, allowing provisioning
      # with a chef server.
      class ChefClient < Base
        include Vagrant::Util::Presence

        def configure(root_config)
          raise ChefError, :server_validation_key_required if @config.validation_key_path.nil?
          raise ChefError, :server_validation_key_doesnt_exist if !File.file?(validation_key_path)
          raise ChefError, :server_url_required if @config.chef_server_url.nil?
        end

        def provision
          install_chef
          verify_binary(chef_binary_path("chef-client"))
          chown_provisioning_folder
          create_client_key_folder
          upload_validation_key
          upload_encrypted_data_bag_secret
          setup_json
          setup_server_config
          run_chef_client
          delete_encrypted_data_bag_secret
        end

        def cleanup
          if @config.delete_node
            delete_from_chef_server("node")
          end

          if @config.delete_client
            delete_from_chef_server("client")
          end
        end

        def create_client_key_folder
          @machine.ui.info I18n.t("vagrant.provisioners.chef.client_key_folder")
          path = Pathname.new(guest_client_key_path)

          if windows?
            @machine.communicate.sudo("mkdir ""#{path.dirname}"" -f")
          else
            @machine.communicate.sudo("mkdir -p #{path.dirname}")
          end
        end

        def upload_validation_key
          @machine.ui.info I18n.t("vagrant.provisioners.chef.upload_validation_key")
          @machine.communicate.upload(validation_key_path, guest_validation_key_path)
        end

        def setup_server_config
          setup_config("provisioners/chef_client/client", "client.rb", {
            chef_server_url: @config.chef_server_url,
            validation_client_name: @config.validation_client_name,
            validation_key: guest_validation_key_path,
            client_key: guest_client_key_path,
          })
        end

        def run_chef_client
          if @config.run_list && @config.run_list.empty?
            @machine.ui.warn(I18n.t("vagrant.chef_run_list_empty"))
          end

          command = CommandBuilder.command(:client, @config,
            windows: windows?,
            colored: @machine.env.ui.color?,
          )
          
          still_active = 259 #provisioner has asked chef to reboot 
          
          @config.attempts.times do |attempt|
            exit_status = 0
            while exit_status == 0 || exit_status == still_active 
              if @machine.guest.capability?(:wait_for_reboot)
                @machine.guest.capability(:wait_for_reboot)
              elsif attempt > 0
                sleep 10
                @machine.communicate.wait_for_ready(@machine.config.vm.boot_timeout)
              end
              if attempt == 0
                @machine.ui.info I18n.t("vagrant.provisioners.chef.running_client")
              else
                @machine.ui.info I18n.t("vagrant.provisioners.chef.running_client_again")
              end

              opts = { error_check: false, elevated: true }
              exit_status = @machine.communicate.sudo(command, opts) do |type, data|
                # Output the data with the proper color based on the stream.
                color = type == :stdout ? :green : :red

                data = data.chomp
                next if data.empty?

                @machine.ui.info(data, color: color)
              end

              # There is no need to run Chef again if it converges
              return if exit_status == 0
            end
          end

          # If we reached this point then Chef never converged! Error.
          raise ChefError, :no_convergence
        end

        def validation_key_path
          File.expand_path(@config.validation_key_path, @machine.env.root_path)
        end

        def guest_client_key_path
          if !@config.client_key_path.nil?
            return @config.client_key_path
          end

          if windows?
            "C:/chef/client.pem"
          else
            "/etc/chef/client.pem"
          end
        end

        def guest_client_rb_path
          File.join(guest_provisioning_path, "client.rb")
        end

        def guest_validation_key_path
          File.join(guest_provisioning_path, "validation.pem")
        end

        def delete_from_chef_server(deletable)
          node_name = @config.node_name

          if !present?(node_name)
            @machine.ui.warn(I18n.t("vagrant.provisioners.chef.missing_node_name",
              deletable: deletable,
            ))
            return
          end

          @machine.ui.info(I18n.t("vagrant.provisioners.chef.deleting_from_server",
            deletable: deletable, name: node_name))

          command =  "knife #{deletable} delete #{node_name}"
          command << " --config '#{guest_client_rb_path}'"
          command << " --yes"

          output = []
          result = @machine.communicate.sudo(command, error_check: false) do |_, data|
            output << data
          end

          if result != 0
            @machine.ui.error("There were errors removing the #{deletable} from the Chef Server:")
            @machine.ui.error("")
            @machine.ui.error(output.join("\n"))
            @machine.ui.error("")
            @machine.ui.error("Vagrant will continue destroying the virtual machine, but you may need")
            @machine.ui.error("to manually delete the #{deletable} from the Chef Server!")
          end
        end
      end
    end
  end
end
