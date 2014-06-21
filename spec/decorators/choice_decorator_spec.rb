require 'spec_helper'

describe ChoiceDecorator, "to_percentage" do

  it "formats popularity as a 0 percentage" do
    choice = create :choice, popularity: 0
    expect(choice.decorate.to_percentage).to eq("0%")
  end

  it "formats popularity as a whole percentage" do
    choice = create :choice, popularity: 1.0
    expect(choice.decorate.to_percentage).to eq("100%")
  end

  it "formats popularity as a whole percentage" do
    choice = create :choice, popularity: 0.55
    expect(choice.decorate.to_percentage).to eq("55%")
  end

  it "formats popularity as a decimal percentage" do
    choice = create :choice, popularity: 0.555
    expect(choice.decorate.to_percentage).to eq("55.5%")
  end

  it "formats popularity as a decimal percentage" do
    choice = create :choice, popularity: 0.5559
    expect(choice.decorate.to_percentage).to eq("55.6%")
  end

  it "formats popularity as a decimal percentage if a rational number" do
    choice = create :choice, popularity: 1.to_f / 3
    expect(choice.decorate.to_percentage).to eq("33.3%")
  end
end
