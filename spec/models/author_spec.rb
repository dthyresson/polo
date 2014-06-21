require 'spec_helper'

describe Author, "associations" do
  it { should have_many :devices }
end

describe Author, "validations" do
  it { should validate_presence_of :name }
end

describe Author, "normalize_phone_number" do
  it "will normalize a phone number to the US" do
    author = create(:author, phone_number: "6175551212")
    expect(author.phone_number).to eq("16175551212")
  end
end

describe Author, "phony_formatted" do
  it "will format a phone number to US style" do
    author = create(:author, phone_number: "6175551212")
    expect(author.phone_number.phony_formatted(:spaces => '-')).to eq("617-555-1212")
  end
end

describe Author, "device_id" do
  it "finds the first device id of the author" do
    author = create :author_with_device
    device = author.devices.first
    expect(author.device_id).to eq(device.device_id)
  end
end
