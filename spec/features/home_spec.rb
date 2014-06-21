require 'spec_helper'

describe "Home" do
  it "shoes the home view" do
    visit_home
    expect(page).to have_content("Polo")
  end
end

