# Copyright 2013, Dell 
# 
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#  http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 
# 

class BarclampNeutron::Barclamp < Barclamp

  def initialize(thelogger)
    @bc_name = "neutron"
    @logger = thelogger
  end

# Turn off multi proposal support till it really works and people ask for it.
  def self.allow_multiple_proposals?
    false
  end

  def proposal_dependencies(role)
    answer = []
    if role.default_attributes["neutron"]["use_gitrepo"]
      answer << { "barclamp" => "git", "inst" => role.default_attributes["neutron"]["git_instance"] }
    end
    answer << { "barclamp" => "database", "inst" => role.default_attributes["neutron"]["database_instance"] }
    answer << { "barclamp" => "rabbitmq", "inst" => role.default_attributes["neutron"]["rabbitmq_instance"] }
    answer << { "barclamp" => "keystone", "inst" => role.default_attributes["neutron"]["keystone_instance"] }
    answer
  end

  def create_proposal
    base = super

    nodes = NodeObject.all
    nodes.delete_if { |n| n.nil? or n.admin? }

    base["attributes"][@bc_name]["git_instance"] = ""
    begin
      gitService = GitService.new(@logger)
      gits = gitService.list_active[1]
      if gits.empty?
        # No actives, look for proposals
        gits = gitService.proposals[1]
      end
      unless gits.empty?
        base["attributes"]["neutron"]["git_instance"] = gits[0]
      end
    rescue
      @logger.info("#{@bc_name} create_proposal: no git found")
    end


    base["attributes"]["neutron"]["database_instance"] = ""
    begin
      databaseService = DatabaseService.new(@logger)
      # Look for active roles
      dbs = databaseService.list_active[1] 
      if dbs.empty? 
        # No actives, look for proposals
        dbs = databaseService.proposals[1]
      end
      if dbs.empty?
        @logger.info("Neutron create_proposal: no database proposal found") 
      else 
        base["attributes"]["neutron"]["database_instance"] = dbs[0] 
        @logger.info("Neutron create_proposal: using database proposal: '#{dbs[0]}'")
      end
    rescue
      @logger.info("Neutron create_proposal: no database proposal found") 
    end

    if base["attributes"]["neutron"]["database_instance"] == ""
      raise(I18n.t('model.service.dependency_missing', :name => @bc_name, :dependson => "database")) 
    end

    base["deployment"]["neutron"]["elements"] = {
        "neutron-server" => [ nodes.first[:fqdn] ]
    } unless nodes.nil? or nodes.length ==0

    base["attributes"]["neutron"]["service_password"] = '%012d' % rand(1e12)

    insts = ["Keystone", "Rabbitmq"]

    insts.each do |inst|
      base["attributes"][@bc_name]["#{inst.downcase}_instance"] = ""
      begin
        instService = eval "#{inst}Service.new(@logger)"
        instes = instService.list_active[1]
        if instes.empty?
          # No actives, look for proposals
          instes = instService.proposals[1]
        end
        base["attributes"][@bc_name]["#{inst.downcase}_instance"] = instes[0] unless instes.empty?
      rescue
        @logger.info("#{@bc_name} create_proposal: no #{inst.downcase} found")
      end

      if base["attributes"][@bc_name]["#{inst.downcase}_instance"] == ""
        raise(I18n.t('model.service.dependency_missing', :name => @bc_name, :dependson => "#{inst.downcase}"))
      end
    end

    base
  end

  def validate_proposal_after_save proposal
    super
    @logger.debug("validating neutron proposal: #{proposal.inspect}")

    if proposal["attributes"][@bc_name]["use_gitrepo"]
      gitService = GitService.new(@logger)
      gits = gitService.list_active[1].to_a
      if not gits.include?proposal["attributes"][@bc_name]["git_instance"]
        raise(I18n.t('model.service.dependency_missing', :name => @bc_name, :dependson => "git"))
      end
    end

    if proposal["attributes"]["neutron"]["networking_plugin"] == "linuxbridge" and
        proposal["attributes"]["neutron"]["networking_mode"] != "vlan"
        raise Chef::Exceptions::ValidationFailed.new("The \"linuxbridge\" plugin only supports the mode: \"vlan\"")
    end
  end

  def apply_role_pre_chef_call(old_role, role, all_nodes)
    @logger.debug("Neutron apply_role_pre_chef_call: entering #{all_nodes.inspect}")
    return if all_nodes.empty?

    net_svc = NetworkService.new @logger
    network_proposal = ProposalObject.find_proposal(net_svc.bc_name, "default")
    if network_proposal["attributes"]["network"]["networks"]["os_sdn"].nil?
      raise I18n.t("barclamp.neutron.deploy.missing_os_sdn_network")
    end

    tnodes = role.override_attributes["neutron"]["elements"]["neutron-server"]
    unless tnodes.nil? or tnodes.empty?
      tnodes.each do |n|
        net_svc.allocate_ip "default", "public", "host",n
        if role.default_attributes["neutron"]["networking_mode"] == "gre"
          net_svc.allocate_ip "default","os_sdn","host", n
        else
          net_svc.enable_interface "default", "nova_fixed", n
          if role.default_attributes["neutron"]["networking_mode"] == "vlan"
            # Force "use_vlan" to false in VLAN mode (linuxbridge and ovs). We
            # need to make sure that the network recipe does NOT create the
            # VLAN interfaces (ethX.VLAN) 
            node = NodeObject.find_node_by_name n
            if node.crowbar["crowbar"]["network"]["nova_fixed"]["use_vlan"]
              @logger.info("Forcing use_vlan to false for the nova_fixed network on node #{n}")
              node.crowbar["crowbar"]["network"]["nova_fixed"]["use_vlan"] = false
              node.save
            end
          end
        end
      end
    end
    @logger.debug("Neutron apply_role_pre_chef_call: leaving")
  end

end
