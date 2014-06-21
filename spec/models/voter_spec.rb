require 'spec_helper'

describe Voter, "validations" do
  it { should validate_presence_of :phone_number } 
end

describe Voter, "normalize_phone_number" do
  it "will normalize a phone number to the US" do
    voter = create(:voter, phone_number: "6175550001")
    expect(voter.phone_number).to eq("16175550001")
  end
end

describe Voter, "phony_formatted" do
  it "will format a phone number to US style" do
    voter = create(:voter, phone_number: "6175550001")
    expect(voter.phone_number.phony_formatted(:spaces => '-')).to eq("617-555-0001")
  end
end
