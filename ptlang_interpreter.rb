# ptlang_interpreter.rb

module PTLang
  @@変数 = {}

  def self.足す(*args)
    args.map { |arg| (@@変数[arg] || arg.to_i) }.reduce(:+)
  end

  def self.引く(*args)
    args.reverse.map { |arg| (@@変数[arg] || arg.to_i) }.reduce(:-)
  end

  def self.かける(*args)
    args.map { |arg| (@@変数[arg] || arg.to_i) }.reduce(:*)
  end

  def self.割る(*args)
    args.reverse.map { |arg| (@@変数[arg] || arg.to_f) }.reduce(:/)
  end

  def self.表示(*args)
    puts args.map { |arg| @@変数[arg] || arg }.join(" ")
  end

  class << self
    alias_method :h, :表示
  end

  def self.中置からrpnへ(式)
    操作 = { '+' => :足す, '-' => :引く, '*' => :かける, '/' => :割る }
    優先順位 = { '+' => 1, '-' => 1, '*' => 2, '/' => 2 }
    スタック = []
    出力 = []

    式.split(/\s+/).each do |トークン|
      if 操作.keys.include?(トークン)
        while スタック.any? && 操作.keys.include?(スタック.last) && 優先順位[トークン] <= 優先順位[スタック.last]
          出力 << スタック.pop
        end
        スタック << トークン
      elsif トークン == '('
        スタック << トークン
      elsif トークン == ')'
        スタック.pop while スタック.last != '('
        スタック.pop
      else
        出力 << トークン.to_i
      end
    end

    出力 += スタック.reverse
    出力
  end

  def self.rpnを評価(式)
    操作 = { '+' => :足す, '-' => :引く, '*' => :かける, '/' => :割る }
    スタック = []

    式.each do |トークン|
      if 操作.keys.include?(トークン)
        引数2 = スタック.pop
        引数1 = スタック.pop
        結果 = self.send(操作[トークン], 引数1, 引数2)
        スタック.push(結果)
      else
        スタック.push(トークン)
      end
    end

    スタック.pop
  end

  def self.解釈(ファイル名)
    コード = File.read(ファイル名)
    コード.each_line.with_index do |行, 行番号|
      行 = 行.chomp if 行  # 行がnilでない場合にchompを呼び出す
      if 行.include?("=")
        変数名, 値 = 行.split("=").map(&:strip)
        値 = 値.start_with?("\"") && 値.end_with?("\"") ? 値[1..-2] : 値.to_i
        値 = 値.to_f if 値.include?(".")
        @@変数[変数名] = 値
      elsif 行.start_with?("h(") || 行.include?("表示(")
        評価する式 = 行[/h\((.*)\)/, 1] if 行.start_with?("h(")
        評価する式 = 行[/表示\((.*)\)/, 1] if 行.include?("表示(")
        rpn式 = 中置からrpnへ(評価する式)
        結果 = rpnを評価(rpn式)
        puts 結果
      else
        puts "無効な命令です"
      end
    end
  end
end

PTLang.解釈(ARGV[0]) # コマンドライン引数としてファイル名を受け取る
