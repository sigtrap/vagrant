# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: core.proto for package 'hashicorp.vagrant.sdk'

require 'grpc'
require_relative './core_pb'

module Hashicorp
  module Vagrant
    module Sdk
      module MachineService
        # *******************************************************************
        # Machine services
        # ******************************************************************
        class Service

          include GRPC::GenericService

          self.marshal_class_method = :encode
          self.unmarshal_class_method = :decode
          self.service_name = 'hashicorp.vagrant.sdk.MachineService'

          rpc :SetName, ::Hashicorp::Vagrant::Sdk::Machine::SetNameRequest, ::Hashicorp::Vagrant::Sdk::Machine::SetNameResponse
          rpc :GetName, ::Hashicorp::Vagrant::Sdk::Machine::GetNameRequest, ::Hashicorp::Vagrant::Sdk::Machine::GetNameResponse
          rpc :SetID, ::Hashicorp::Vagrant::Sdk::Machine::SetIDRequest, ::Hashicorp::Vagrant::Sdk::Machine::SetIDResponse
          rpc :GetID, ::Hashicorp::Vagrant::Sdk::Machine::GetIDRequest, ::Hashicorp::Vagrant::Sdk::Machine::GetIDResponse
          rpc :Box, ::Hashicorp::Vagrant::Sdk::Machine::BoxRequest, ::Hashicorp::Vagrant::Sdk::Machine::BoxResponse
          rpc :Datadir, ::Hashicorp::Vagrant::Sdk::Machine::DatadirRequest, ::Hashicorp::Vagrant::Sdk::Machine::DatadirResponse
          rpc :LocalDataPath, ::Hashicorp::Vagrant::Sdk::Machine::LocalDataPathRequest, ::Hashicorp::Vagrant::Sdk::Machine::LocalDataPathResponse
          rpc :Provider, ::Hashicorp::Vagrant::Sdk::Machine::ProviderRequest, ::Hashicorp::Vagrant::Sdk::Machine::ProviderResponse
          rpc :VagrantfileName, ::Hashicorp::Vagrant::Sdk::Machine::VagrantfileNameRequest, ::Hashicorp::Vagrant::Sdk::Machine::VagrantfileNameResponse
          rpc :VagrantfilePath, ::Hashicorp::Vagrant::Sdk::Machine::VagrantfilePathRequest, ::Hashicorp::Vagrant::Sdk::Machine::VagrantfilePathResponse
          rpc :UpdatedAt, ::Hashicorp::Vagrant::Sdk::Machine::UpdatedAtRequest, ::Hashicorp::Vagrant::Sdk::Machine::UpdatedAtResponse
          rpc :UI, ::Hashicorp::Vagrant::Sdk::Machine::UIRequest, ::Hashicorp::Vagrant::Sdk::Machine::UIResponse
        end

        Stub = Service.rpc_stub_class
      end
    end
  end
end