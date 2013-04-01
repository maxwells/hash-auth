require File.expand_path('../../spec_helper', __FILE__)

describe HashAuth::Railtie do

  it "includes HashAuth in ActionController::Base" do
    ActionController::Base.included_modules.include?(HashAuth).should == true
  end

end