# frozen_string_literal: true

# ステートマシン図とコードの対応づけルールの検討用クラス
class Sample
  def play # <1>
  end

  private # <2>

  def act1(evt, p01)
  end

  def act2(evt, p01)
  end

  def act3(evt, p01)
  end
end

class SampleTest
  def run  # <3>
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
  test.run # <4>
end
