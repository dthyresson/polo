require 'spec_helper'

describe Device, "associations" do
  it { should belong_to :author }
end

describe Device, "validations" do
  it { should validate_presence_of :device_id }
end
