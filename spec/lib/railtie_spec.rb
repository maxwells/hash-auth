require_relative '../spec_helper'

describe HashAuth::Railtie do

  it "includes HashAuth in ActionController::Base" do
    ActionController::Base.included_modules.include?(HashAuth).should == true
  end

end