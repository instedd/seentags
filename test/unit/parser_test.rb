require 'test_helper.rb'

class ParserTest < ActiveSupport::TestCase

  test "label and value separated by colon" do
		rep = report("foo: bar")
		assert_equal 1, rep.length
		assert_value "foo", "bar", rep[0]
  end

  test "label and value separated by equals" do
		rep = report("foo = bar")
		assert_equal 1, rep.length
		assert_value "foo", "bar", rep[0]
  end

  test "many label and value separated by colon" do
		rep = report("foo: bar, one: 12")
		assert_equal 2, rep.length
		assert_value "foo", "bar", rep[0]
		assert_value "one", 12, rep[1]
  end

  test "pairs" do
		rep = report("name jack, age 25")
		assert_equal 3, rep.length
		assert_value "?", "name", rep[0]
		assert_value "?", "jack", rep[1]
		assert_value "age", 25, rep[2]
  end

   test "no pairs" do
		rep = report("name jack fever high")
		assert_equal 4, rep.length
		assert_value "?", "name", rep[0]
		assert_value "?", "jack", rep[1]
		assert_value "?", "fever", rep[2]
		assert_value "?", "high", rep[3]
  end

  test "no labels" do
		rep = report("john 25 m")
		assert_equal 3, rep.length
		assert_value "?", "john", rep[0]
		assert_value "?", 25, rep[1]
		assert_value "?", "m", rep[2]
  end

  test "no labels 2" do
		rep = report("john m 25")
		assert_equal 3, rep.length
		assert_value "?", "john", rep[0]
		assert_value "?", "m", rep[1]
		assert_value "?", 25, rep[2]
  end

  test "many label and value separated by dot" do
		rep = report("Nc 13.Dc 1.Dy 8")
		assert_equal 3, rep.length
		assert_value "Nc", 13, rep[0]
		assert_value "Dc", 1, rep[1]
		assert_value "Dy", 8, rep[2]
  end

  test "many label and value separated by dot inverted" do
		rep = report("13Nc.1Dc.8Dy")
		assert_equal 3, rep.length
		assert_value "Nc", 13, rep[0]
		assert_value "Dc", 1, rep[1]
		assert_value "Dy", 8, rep[2]
  end

  test "many label and value separated by spaces" do
		rep = report("Nc 13 Dc 1 Dy 8")
		assert_equal 3, rep.length
		assert_value "Nc", 13, rep[0]
		assert_value "Dc", 1, rep[1]
		assert_value "Dy", 8, rep[2]
  end

  test "many label and value separated by spaces 2" do
		rep = report("13 Nc 1 Dc 8 Dy")
		assert_equal 3, rep.length
		assert_value "Nc", 13, rep[0]
		assert_value "Dc", 1, rep[1]
		assert_value "Dy", 8, rep[2]
  end

  test "nested 1" do
		rep = report("foo[1/2]")

		assert_equal 1, rep.length
		assert_value "foo", nil, rep[0]

		nested = rep[0].nested
		assert_not_nil nested

		assert_value '?', 1, nested[0]
		assert_value '?', 2, nested[1]
  end

  test "nested 2" do
		rep = report("16001011 24112009 C[2/13/20] A[5/8/22] P[0/2]")
		assert_equal 5, rep.length
  end

  test "many label and value bug 1" do
		rep = report("10 ore, 20 wood 30 stone")
		assert_equal 3, rep.length
		assert_value "ore", 10, rep[0]
		assert_value "wood", 20, rep[1]
		assert_value "stone", 30, rep[2]
  end

  test "many label and value bug 2" do
		rep = report("10 ore, wood 20 stone 30")
		assert_equal 3, rep.length
		assert_value "ore", 10, rep[0]
		assert_value "wood", 20, rep[1]
		assert_value "stone", 30, rep[2]
  end

  test "parse from to_s" do
		rep = report("{foo: bar}")
		assert_equal 1, rep.length
		assert_value "foo", "bar", rep[0]
  end

  test "no split quoted text" do
		rep = report('from: "sms://42524", to: "mailto://jdoe@domain.com", 25')
		assert_equal 3, rep.length
		assert_value "from", '"sms://42524"', rep[0]
		assert_value "to", '"mailto://jdoe@domain.com"', rep[1]
		assert_value "?", 25, rep[2]
  end

  test "no split wrong quoted text" do
		rep = report('from: "sms://42524", to: "mailto://jdoe@domain.com')
		assert_equal 2, rep.length
		assert_value "from", '"sms://42524"', rep[0]
		assert_value "to", '"mailto://jdoe@domain.com', rep[1]
  end

  test "parse many reports before" do
    reps = reports("a: 1, b:2, a:3, b:4, c:5")
    assert_equal 2, reps.length

    assert_equal 3, reps[0].length
    assert_value "a", 1, reps[0][0]
    assert_value "b", 2, reps[0][1]
    assert_value "c", 5, reps[0][2]

    assert_equal 3, reps[1].length
    assert_value "a", 3, reps[1][0]
    assert_value "b", 4, reps[1][1]
    assert_value "c", 5, reps[1][2]
  end

  test "parse many reports after" do
    reps = reports("c:5, a: 1, b:2, a:3, b:4")
    assert_equal 2, reps.length

    assert_equal 3, reps[0].length
    assert_value "c", 5, reps[0][0]
    assert_value "a", 1, reps[0][1]
    assert_value "b", 2, reps[0][2]

    assert_equal 3, reps[1].length
    assert_value "c", 5, reps[1][0]
    assert_value "a", 3, reps[1][1]
    assert_value "b", 4, reps[1][2]
  end

  test "parse many reports between" do
    reps = reports("c:5, a: 1, b:2, a:3, b:4, d:6")
    assert_equal 2, reps.length

    assert_equal 4, reps[0].length
    assert_value "c", 5, reps[0][0]
    assert_value "a", 1, reps[0][1]
    assert_value "b", 2, reps[0][2]
    assert_value "d", 6, reps[0][3]

    assert_equal 4, reps[1].length
    assert_value "c", 5, reps[1][0]
    assert_value "a", 3, reps[1][1]
    assert_value "b", 4, reps[1][2]
    assert_value "d", 6, reps[0][3]
  end

  test "bug 1" do
    report('ONE=,')
  end
end
