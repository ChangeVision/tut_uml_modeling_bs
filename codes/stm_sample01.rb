# frozen_string_literal: true

# ステートマシン図とコードの対応づけルールの検討用クラス
class Sample # <1>
end

class SampleTest # <2>
end

if $PROGRAM_NAME == __FILE__ # <3>
  test = SampleTest.new
end
