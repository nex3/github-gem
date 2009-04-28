require File.dirname(__FILE__) + '/spec_helper'

describe GitHub::Command do
  before(:each) do
    @command = GitHub::Command.new(proc { |x| puts x })
  end

  it "should return a GitHub::Helper" do
    @command.helper.should be_instance_of(GitHub::Helper)
  end

  it "should call successfully" do
    @command.should_receive(:puts).with("test").once
    @command.call("test")
  end

  it "should return options" do
    GitHub.should_receive(:options).with().once.and_return({:ssh => true})
    @command.options.should == {:ssh => true}
  end

  it "should successfully call out to the shell" do
    unguard(Kernel, :fork)
    unguard(Kernel, :exec)

    hi = @command.sh("echo hi")
    hi.should == "hi"
  end

  it "should return the results of a git operation" do
    IO.should_receive(:popen).with("git rev-parse master").once.and_return("sha1")
    @command.git("rev-parse master").should == "sha1"
  end

  it "should print the results of a git operation" do
    IO.should_receive(:popen).with("git rev-parse master").once.and_return("sha1")
    @command.should_receive(:puts).with("sha1").once
    @command.pgit("rev-parse master")
  end

  it "should exec a git command" do
    @command.should_receive(:exec).with("git rev-parse master").once
    @command.git_exec "rev-parse master"
  end

  it "should die" do
    @command.should_receive(:puts).once.with("=> message")
    @command.should_receive(:exit!).once
    @command.die "message"
  end
end
