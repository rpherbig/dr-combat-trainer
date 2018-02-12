require 'minitest/autorun'
require 'timecop'
require 'yaml'
require 'ostruct'
load 'test/test_harness.rb'

include Harness

class Room
  def self.current
    Map.new
  end
end

class Map
  def id
    1
  end
end

class TestAfk < Minitest::Test
  def setup
    $history.clear
    self.dead = false
    self.health = 100
    self.spirit = 100
    sent_messages.clear
  end

  def setup_settings(settings)
    $test_settings = OpenStruct.new(YAML.load_file('profiles/base.yaml').merge(settings))
  end

  def test_exits_if_dead_with_default_settings
    setup_settings({})
    expected_messages = ['exit']
    self.dead = true

    run_script('afk')

    Timecop.return

    assert_sends_messages(expected_messages)
  end

  def test_departs_if_dead_with_depart_on_death_enabled
    setup_settings('depart_on_death' => 'true')
    expected_messages = ['depart item', 'exit']
    self.dead = true

    run_script('afk')

    Timecop.return

    assert_sends_messages expected_messages
  end

  def test_exits_if_low_health
    setup_settings({})
    $history = ['You continue to braid your vines.', 'You are attacked by a Grue! Your injuries are severe.']
    expected_messages = ['health', 'avoid all', 'exit']

    run_script('afk')

    next until $history.empty?
    self.health = 20

    Timecop.return

    assert_sends_messages expected_messages
  end

  def test_exits_if_low_spirit
    setup_settings({})
    $history = ['You continue to braid your vines.', 'You are attacked by a Grue! Your injuries are severe.']
    expected_messages = ['health', 'avoid all', 'exit']
    self.spirit = 100

    run_script('afk')

    next until $history.empty?
    self.spirit = 20

    Timecop.return

    assert_sends_messages expected_messages
  end
end
