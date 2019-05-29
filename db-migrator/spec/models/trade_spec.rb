describe "User" do
  before do
    User.destroy_all
  end

  after do
    # User.destroy_all
  end

  it "should be able to register" do
    User.register! "hlxwell@gmail.com", "123321"
    User.count.should be 1
  end
end
