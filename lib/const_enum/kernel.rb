# coding: utf-8

module Kernel
  # 無名の定数クラスを作成して返します
  # 与えたブロック内で以下のように記述することで定数とラベルを定義できます
  # CLAZZNAME = const_enum do
  #   HOGE 1, "ほげ"
  #   FUGA 2, "ふが"
  #   PIYO 3, "ぴよ"
  # end
  # puts CLAZZNAME::HOGE # 1
  # puts CLAZZNAME[2] # ふが
  def const_enum(&block)
    clazz = Class.new(ConstEnum::Base)
    clazz.singleton_class.__send__(:define_method, :method_missing) do |name, *args|
      /\A[A-Z][a-zA-Z_0-9]*\z/ === name.to_s ? define_const(name, *args) : super
    end
    clazz.class_eval &block
    clazz.singleton_class.__send__(:remove_method, :method_missing)
    clazz
  end
end