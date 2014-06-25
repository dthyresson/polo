require 'spec_helper'

describe NullChoice, "title" do
  it "has an empty title" do
    null_choice = NullChoice.new
    expect(null_choice.title).to be_empty
  end

  it "ordered" do
    expect(NullChoice.new.ordered).to eq([])
  end
end
