require 'test_helper.rb'

class KnowledgeTest < ActiveSupport::TestCase

  test "dictionary" do
    reps = get_reps
    know = Knowledge.new(reps)
    dict = know.dictionary

    assert_equal 1, dict['h1n1']['disease']
    assert_equal 1, dict['flu']['disease']
    assert_equal 1, dict[3]['number']
    assert_equal 2, dict[5]['number']
    assert_equal 1, dict['yes']['confirmed']
    assert_equal 1, dict['no']['confirmed']
  end

  test "labels" do
    reps = get_reps
    know = Knowledge.new(reps)
    labels = know.labels

    assert_equal 3, labels.length
    assert_true labels.include?('disease')
    assert_true labels.include?('number')
    assert_true labels.include?('confirmed')
  end

  test "types" do
    reps = get_reps
    know = Knowledge.new(reps)
    types = know.types

    assert_equal :string, types['disease']
    assert_equal :string, types['confirmed']
    assert_equal :integer, types['number']
  end

  test "label_positions" do
    reps = get_reps
    know = Knowledge.new(reps)
    dict = know.label_positions

    assert_equal 2, dict[0]['disease']
    assert_equal 0, dict[1]['disease']
    assert_equal 0, dict[2]['disease']

    assert_equal 0, dict[0]['number']
    assert_equal 1, dict[1]['number']
    assert_equal 2, dict[2]['number']

    assert_equal 1, dict[0]['confirmed']
    assert_equal 0, dict[1]['confirmed']
    assert_equal 1, dict[2]['confirmed']
  end

  test "types integer and decimal is decimal" do
    reps = reports(
      'disease: 6',
      'disease: 6.0')
    know = Knowledge.new(reps)
    types = know.types

    assert_equal :decimal, types['disease']
  end

  test "types string and integer is mixed" do
    reps = reports(
      'disease: H1N1',
      'disease: 6')
    know = Knowledge.new(reps)
    types = know.types

    assert_equal :mixed, types['disease']
  end

  test "types string and decimal is mixed" do
    reps = reports(
      'disease: H1N1',
      'disease: 6.0')
    know = Knowledge.new(reps)
    types = know.types

    assert_equal :mixed, types['disease']
  end

  test "rule label followed by value" do
    reps = get_reps
    know = Knowledge.new(reps)

    rep = report('disease H1N1 confirmed yes')
    know.apply_to(rep)

    assert_value 'disease', 'H1N1', rep[0]
    assert_value 'confirmed', 'yes', rep[1]
  end

  test "rule value followed by label" do
    reps = get_reps
    know = Knowledge.new(reps)

    rep = report('H1N1 disease yes confirmed')
    know.apply_to(rep)

    assert_value 'disease', 'H1N1', rep[0]
    assert_value 'confirmed', 'yes', rep[1]
  end

  test "rule value found in labels" do
    reps = get_reps
    know = Knowledge.new(reps)

    rep = report('H1N1, yes')
    know.apply_to(rep)

    assert_value 'disease', 'H1N1', rep[0]
    assert_value 'confirmed', 'yes', rep[1]
  end

  test "rule last unlabelled value has only a single label choice" do
    reps = get_reps
    know = Knowledge.new(reps)

    rep = report('disease: H1N1, confirmed: yes, 20')
    know.apply_to(rep)

    assert_value 'disease', 'H1N1', rep[0]
    assert_value 'confirmed', 'yes', rep[1]
    assert_value 'number', 20, rep[2]
  end

  test "rule last unalabelled values' types match remaining labels' types" do
    reps = get_reps
    know = Knowledge.new(reps)

    rep = report('disease: H1N1, 30, maybe')
    know.apply_to(rep)

    assert_value 'disease', 'H1N1', rep[0]
    assert_value 'number', 30, rep[1]
    assert_value 'confirmed', 'maybe', rep[2]
  end

  test "rule last unlabelled value has only a single label choice learns" do
    reps = get_reps
    know = Knowledge.new(reps)

    # Here we learn that 'ari' is a disease
    rep = report('confirmed: no, number:30, ari')
    assert_true know.apply_to(rep)

    # so if 'ari' is a disease, maybe is a confirmed value and 40 is the number
    # (uses rule 1.6.1 for this later case)
    rep = report('maybe, 40, ari')
    know.apply_to(rep)

    assert_value 'confirmed', 'maybe', rep[0]
    assert_value 'number', 40, rep[1]
    assert_value 'disease', 'ari', rep[2]
  end

  test "rule last unalabelled values' types match remaining labels' types learns" do
    reps = get_reps
    know = Knowledge.new(reps)

    rep = report('disease: H1N1, 30, maybe')
    assert_true know.apply_to(rep)

    rep = report('maybe, 40, ari')
    know.apply_to(rep)

    assert_value 'confirmed', 'maybe', rep[0]
    assert_value 'number', 40, rep[1]
    assert_value 'disease', 'ari', rep[2]
  end

  test "rule only value of given type and only label of given type" do
    reps = get_reps
    know = Knowledge.new(reps)

    rep = report('one, two, 40')
    assert_true know.apply_to(rep)

    assert_value 'number', 40, rep[2]
  end

  test "rule match by position" do
    reps = get_reps
    know = Knowledge.new(reps)

    rep = report('hiv, 20, maybe')
    assert_true know.apply_to(rep)

    assert_value 'disease', 'hiv', rep[0]
    assert_value 'number', 20, rep[1]
    assert_value 'confirmed', 'maybe', rep[2]
  end

  test "bug loop 1" do
    reps = reports('disase: H1N1, confirmed: yes, number: 3')
    know = Knowledge.new(reps)
    assert_false know.apply_to(reps[0])
  end

  test "unify labels" do
    reps = reports('one, two, three', 'one, two, three')
    know = Knowledge.new(reps)
    know.unify_labels reps

    (0..2).each do |i|
      assert_equal reps[0][i].label, reps[1][i].label
    end
  end

  test "bug1" do
    reps = reports('unit (pallet)')
    know = Knowledge.new(reps)
  end

  def get_reps
    reports(
      'disease: H1N1, number: 3, confirmed: yes',
      'Disease: Flu, 6, no',
      'Cholera, yes, 6',
      'confirmed: no, Cholera, number: 5',
      'no, Cholera, number: 5',
      'H1N1, 3, no',
      'Flu, no, 3')
  end

end
