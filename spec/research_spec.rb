require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require "/Users/rayk/RubymineProjects/shakespeare/app/controllers/mdms_controller"

describe MdmsController, :type => :controller do
  describe "GET index" do
    it "has a 200 status code" do
      get 'index'
      response.code.should eq("200")
    end
  end
end