# frozen_string_literal: true

# ステートマシン図とコードの対応づけルールの検討用クラス
class Sample
  def play
  end

  private

  def act1(evt, p01)
  end

  def act2(evt, p01)
  end

  def act3(evt, p01)
  end
end

class SampleTest
  def initialize
    @samp01 = Sample.new
  end

  def run
    test01
    test02
    test03
  end

  def test01
  end

  def test02
  end

  def test03
  end
end

if $PROGRAM_NAME == __FILE__
  test = SampleTest.new
  test.run
end
