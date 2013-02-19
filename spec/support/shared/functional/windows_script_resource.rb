#
# Author:: Adam Edwards (<adamed@opscode.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

shared_context Chef::Resource::WindowsScript do
  let(:ohai) do
    ohai_reader = Ohai::System.new
    ohai_reader.require_plugin("os")    
    ohai_reader.require_plugin("windows::platform")
    ohai_reader
  end

  let(:node) do
    new_node = Chef::Node.new
    new_node.consume_external_attrs(ohai.data,{})
    new_node
  end

  let(:run_context) do
    events = Chef::EventDispatch::Dispatcher.new
    
    run_context = Chef::RunContext.new(node, {}, events)    
  end

  let(:script_output_path) do
    File.join(Dir.tmpdir, make_tmpname("windows_script_test"))
  end

  before(:each) do
k    File.delete(script_output_path) if File.exists?(script_output_path)    
  end

  after(:each) do
    File.delete(script_output_path) if File.exists?(script_output_path)
  end
end

describe Chef::Resource::WindowsScript, :windows_only do
  shared_examples_for "a functional Windows script resource", :windows_only do
    include_context Chef::Resource::WindowsScript    
    context "when a Windows script resource run action is invoked " do     
      it "executes the script code" do
        resource.code(script_content + " > #{script_output_path}")
        resource.returns(0)
        resource.run_action(:run)
      end
    end
  end
end
