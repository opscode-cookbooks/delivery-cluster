#
# Cookbook Name:: delivery-cluster
# Spec:: helpers_spec
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe DeliveryCluster::Helpers do
  let(:node) { Chef::Node.new }

  before do
    node.default['delivery-cluster'] = cluster_data
    allow_any_instance_of(Chef::Node).to receive(:save).and_return(true)
    allow(DeliveryCluster::Helpers).to receive(:node).and_return(node)
  end

  it 'should return the cluster_id' do
    expect(described_class.delivery_cluster_id(node)).to eq 'chefspec'
  end

  it 'should return false if cluster_data_dir is not a link' do
    expect(described_class.cluster_data_dir_link?).to eq false
  end

  it 'should return the cluster_data_dir' do
    expect(described_class.cluster_data_dir(node)).to eq File.join(Chef::Config.chef_repo_path, '.chef', 'delivery-cluster-data-chefspec')
  end

  it 'should return the current_dir that is the chef_repo_path' do
    expect(described_class.current_dir).to eq Chef::Config.chef_repo_path
  end

  context 'when cluster_id' do
    context 'is specified' do
      it 'should return the delivery_cluster_id' do
        expect(described_class.delivery_cluster_id(node)).to eq 'chefspec'
      end
    end
    context 'is NOT specified' do
      before { node.default['delivery-cluster']['id'] = nil }

      it 'should create a delivery_cluster_id and return it' do
        expect(described_class.delivery_cluster_id(node)).not_to be nil
        expect(described_class.delivery_cluster_id(node).class).to be String
      end
    end
  end

  context 'when license_file' do
    context 'is specified' do
      it 'should NOT raise an error' do
        expect { described_class.validate_license_file(node) }.not_to raise_error
      end
    end
    context 'is NOT specified' do
      before { node.default['delivery-cluster']['delivery']['license_file'] = nil }

      it 'should raise an error' do
        expect { described_class.validate_license_file(node) }.to raise_error(RuntimeError)
      end
    end
  end

  context 'when driver' do
    context 'SSH is specified' do
      before do
        node.default['delivery-cluster']['driver'] = 'ssh'
        node.default['delivery-cluster']['ssh'] = ssh_data
        DeliveryCluster::Helpers.instance_variable_set :@provisioning, nil
      end

      it 'use_private_ip_for_ssh should return ' do
        expect(described_class.use_private_ip_for_ssh(node)).to eq nil
      end

      it 'should return the username' do
        expect(described_class.username(node)).to eq 'ubuntu'
      end

      it 'should return the ip address' do
        expect(described_class.get_ip(node, chef_node)).to eq '10.1.1.1'
      end

      it 'should return the provisioning instance' do
        expect(described_class.provisioning(node).class).to eq DeliveryCluster::Provisioning::Ssh
      end
    end

    context 'AWS is specified' do
      before do
        node.default['delivery-cluster']['driver'] = 'aws'
        node.default['delivery-cluster']['aws'] = aws_data
        DeliveryCluster::Helpers.instance_variable_set :@provisioning, nil
      end

      it 'use_private_ip_for_ssh should return ' do
        expect(described_class.use_private_ip_for_ssh(node)).to eq true
      end

      it 'should return the username' do
        expect(described_class.username(node)).to eq 'ubuntu'
      end

      it 'should return the ip address' do
        expect(described_class.get_ip(node, supermarket_node)).to eq '10.1.1.3'
      end

      it 'should return the provisioning instance' do
        expect(described_class.provisioning(node).class).to eq DeliveryCluster::Provisioning::Aws
      end
    end

    context 'VAGRANT is specified' do
      before do
        node.default['delivery-cluster']['driver'] = 'vagrant'
        node.default['delivery-cluster']['vagrant'] = vagrant_data
        DeliveryCluster::Helpers.instance_variable_set :@provisioning, nil
      end

      it 'use_private_ip_for_ssh should return ' do
        expect(described_class.use_private_ip_for_ssh(node)).to eq false
      end

      it 'should return the username' do
        expect(described_class.username(node)).to eq 'vagrant'
      end

      it 'should return the ip address' do
        expect(described_class.get_ip(node, delivery_node)).to eq '10.1.1.2'
      end

      it 'should return the provisioning instance' do
        expect(described_class.provisioning(node).class).to eq DeliveryCluster::Provisioning::Vagrant
      end
    end

    context 'is NOT specified' do
      it 'should raise and error trying to access use_private_ip_for_ssh' do
        expect { described_class.use_private_ip_for_ssh(node) }.to raise_error(RuntimeError)
      end

      it 'should raise and error trying to access username' do
        expect { described_class.username(node) }.to raise_error(RuntimeError)
      end

      it 'should raise and error trying to access get_ip' do
        expect { described_class.get_ip(node, analytics_node) }.to raise_error(RuntimeError)
      end

      it 'should raise and error trying to access provisioning' do
        expect { described_class.provisioning(node) }.to raise_error(RuntimeError)
      end
    end
  end

  it 'should return return knife variables' do
    expect(described_class.knife_variables(node)).to eq(
      chef_server_url: 'https://chef-server.chef.io/organizations/chefspec',
      client_key: File.join(Chef::Config.chef_repo_path, '.chef', 'delivery-cluster-data-chefspec', 'delivery.pem'),
      analytics_server_url: '',
      supermarket_site: ''
    )
  end
end
