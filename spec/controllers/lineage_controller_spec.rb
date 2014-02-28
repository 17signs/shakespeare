require 'spec_helper'

describe LineageController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'expand'" do
    it "returns http success" do
      get 'expand'
      response.should be_success
    end
  end

  describe "GET 'collapse'" do
    it "returns http success" do
      get 'collapse'
      response.should be_success
    end
  end

end
