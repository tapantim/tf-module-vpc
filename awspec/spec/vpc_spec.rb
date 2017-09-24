require 'spec_helper'

describe vpc('test-vpc') do
  it {should exist}
  its(:cidr_block) {should eq '10.0.0.0/16'}
  its(:instance_tenancy) {should eq 'default'}
  it {should have_tag('Name').value('test-vpc')}
  it { should have_route_table('test-public-route-table') }
  it { should have_route_table('test-private-route-table-eu-west-1a') }
  it { should have_route_table('test-private-route-table-eu-west-1b') }
  it { should have_route_table('test-private-route-table-eu-west-1c') }
end

describe internet_gateway('test-igw') do
  it { should exist }
  it { should be_attached_to('test-vpc') }
end

describe subnet('test-public-subnet-eu-west-1a') do
  it { should exist }
  it { should be_available }
  it { should belong_to_vpc('test-vpc') }
  its(:availability_zone) {should eq 'eu-west-1a'}
  its(:cidr_block) { should eq '10.0.0.0/19' }
  its(:map_public_ip_on_launch) {should eq true}
end

describe subnet('test-public-subnet-eu-west-1b') do
  it { should exist }
  it { should be_available }
  it { should belong_to_vpc('test-vpc') }
  its(:availability_zone) {should eq 'eu-west-1b'}
  its(:cidr_block) { should eq '10.0.32.0/19' }
  its(:map_public_ip_on_launch) {should eq true}
end

describe subnet('test-public-subnet-eu-west-1c') do
  it { should exist }
  it { should be_available }
  it { should belong_to_vpc('test-vpc') }
  its(:availability_zone) {should eq 'eu-west-1c'}
  its(:cidr_block) { should eq '10.0.64.0/19' }
  its(:map_public_ip_on_launch) {should eq true}
end

describe subnet('test-private-subnet-eu-west-1a') do
  it { should exist }
  it { should be_available }
  it { should belong_to_vpc('test-vpc') }
  its(:availability_zone) {should eq 'eu-west-1a'}
  its(:cidr_block) { should eq '10.0.96.0/19' }
  its(:map_public_ip_on_launch) {should eq false}
end

describe subnet('test-private-subnet-eu-west-1b') do
  it { should exist }
  it { should be_available }
  it { should belong_to_vpc('test-vpc') }
  its(:availability_zone) {should eq 'eu-west-1b'}
  its(:cidr_block) { should eq '10.0.128.0/19' }
  its(:map_public_ip_on_launch) {should eq false}
end

describe subnet('test-private-subnet-eu-west-1c') do
  it { should exist }
  it { should be_available }
  it { should belong_to_vpc('test-vpc') }
  its(:availability_zone) {should eq 'eu-west-1c'}
  its(:cidr_block) { should eq '10.0.160.0/19' }
  its(:map_public_ip_on_launch) {should eq false}
end

describe route_table('test-private-route-table-eu-west-1c') do
  it { should exist }
  it { should belong_to_vpc('test-vpc') }
  it { should have_route('10.0.0.0/16').target(gateway: 'local') }
  #it { should have_route('0.0.0.0/0').target(nat: 'nat') }
end

describe route_table('test-private-route-table-eu-west-1a') do
  it { should exist }
  it { should belong_to_vpc('test-vpc') }
  it { should have_route('10.0.0.0/16').target(gateway: 'local') }
  #it { should have_route('0.0.0.0/0').target(nat: 'nat-0883e5d59f21014da') }
end

describe route_table('test-public-route-table') do
  it { should exist }
  it { should belong_to_vpc('test-vpc') }
  it { should have_route('10.0.0.0/16').target(gateway: 'local') }
  #it { should have_route('0.0.0.0/0').target(gateway: 'igw-a90c0ecd') }
  it { should have_subnet('test-public-subnet-eu-west-1a') }
  it { should have_subnet('test-public-subnet-eu-west-1c') }
  it { should have_subnet('test-public-subnet-eu-west-1b') }
end

describe route_table('test-private-route-table-eu-west-1b') do
  it { should exist }
  it { should belong_to_vpc('test-vpc') }
  it { should have_route('10.0.0.0/16').target(gateway: 'local') }
  #it { should have_route('0.0.0.0/0').target(nat: 'nat-06a62d720cbd40a73') }
end