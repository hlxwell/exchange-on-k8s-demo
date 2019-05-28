describe "User" do
  before do
    User.destroy_all
  end

  after do
  end

  it "should be able to register" do
    User.register! "hlxwell@gmail.com", "123321"
  end

  it "should be able to register" do
    User.register! "hlxwell@gmail.com", "123321"
  end
end
