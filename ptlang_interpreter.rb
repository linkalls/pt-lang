# ptlang_interpreter.rb

module PTLang
  @@変数 = {}

  def self.足す(*args)
    if args.any? { |arg| (@@変数[arg] || arg).is_a?(String) }
      args.map { |arg| @@変数[arg] || arg }.join
    else
      args.map { |arg| (@@変数[arg] || arg.to_i) }.reduce(:+)
    end
  end

  def self.引く(*args)
    args.map { |arg| (@@変数[arg] || arg.to_i) }.reduce(:-)
  end

  def self.かける(*args)
    args.map { |arg| (@@変数[arg] || arg.to_i) }.reduce(:*)
  end

  def self.割る(*args)
    args.map { |arg| (@@変数[arg] || arg.to_f) }.reduce(:/)
  end

  def self.表示(*args)
    puts args.map { |arg| @@変数[arg] || arg }.join(" ")
  end

  class << self
    alias_method :h, :表示
  end

  def self.解釈(ファイル名)
    コード = File.read(ファイル名)
    コード.each_line.with_index do |行, 行番号|
      行 = 行.chomp if 行  # 行がnilでない場合にchompを呼び出す
      if 行.include?("=")
        変数名, 値 = 行.split("=").map(&:strip)
        @@変数[変数名] = 値.start_with?("\"") && 値.end_with?("\"") ? 値[1..-2] : 値.to_i
      elsif 行.start_with?("表示 ", "h ") || 行.include?(" を表示") || 行.start_with?("表示(\"")
        評価する式 = 行.split(" ", 2)[1].gsub("\"", "") if 行.start_with?("表示 ", "h ")
        評価する式 = 行.split(" を表示", 2)[0].gsub("\"", "") if 行.include?(" を表示")
        評価する式 = 行[/表示\("(.*)"\)/, 1] if 行.start_with?("表示(\"")
        表示(評価する式)
      elsif 行.start_with?("h(") || 行.include?("表示(")
        評価する式 = 行[/h\((.*)\)/, 1] if 行.start_with?("h(")
        評価する式 = 行[/表示\((.*)\)/, 1] if 行.include?("表示(")
        操作, *引数 = 評価する式.split(/[\s,()]+/)
        結果 = self.send(操作, *引数) if self.respond_to?(操作)
        puts 結果
      else
        puts "無効な命令です"
      end
    end
  end
end

PTLang.解釈(ARGV[0]) # コマンドライン引数としてファイル名を受け取る
