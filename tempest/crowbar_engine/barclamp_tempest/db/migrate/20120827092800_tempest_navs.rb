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
#
class TempestNavs < ActiveRecord::Migration
  def self.up
    Nav.find_or_create_by_item :item=>'tempest_dashboard', :parent_item=>'utils', :name=>'nav.tempest', :description=>'nav.tempest_description', :path=>'\'"/tempest/dashboard/", { :link => { :target => "_blank" } }\'', :order=>500
  end

  def self.down
    Nav.delete_by_item 'tempest_dashboard'
  end
end
